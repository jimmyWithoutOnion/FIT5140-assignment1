//
//  NewLocationController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 24/8/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import ImagePicker


class NewLocationController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, ImagePickerDelegate {
    
    var delegate: newLocationDelegate?
    var locationManger: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    var managedObjectContext: NSManagedObjectContext
    
    let regionRadius: CLLocationDistance = 1200
    
    var animalLatitude: Double?
    var animalLongtitude: Double?
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
        
    }
    
    @IBAction func takePictureForAnimal(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        animalImageView.image = image
        dismiss(animated: true, completion: nil)
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func saveCurrentLocation(_ sender: Any) {
        
        
        //change to readable address and display
        
        
        //self.locationTextField.text = "\(currentLocation!.latitude),\(currentLocation!.longitude)"
        
        
        locationMapView.removeAnnotations(locationMapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: (currentLocation!.latitude), longitude: (currentLocation!.longitude))
        //Set title and subtitle if you want
        annotation.title = "Here"
        annotation.subtitle = "subtitle"
        self.locationMapView.addAnnotation(annotation)
        
        
        let location = CLLocation(latitude: (currentLocation!.latitude), longitude: (currentLocation!.longitude))
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                
                //print(firstLocation!.name, firstLocation!.locality, firstLocation?.administrativeArea, firstLocation!.postalCode)
                
                self.locationLabel.text = "\((firstLocation!.name)!), \((firstLocation!.locality)!)"
                
            } else {
                self.locationLabel.text = "Sorry we cannot recognize this location!"
            }
        })
        
        self.animalLatitude = currentLocation!.latitude
        self.animalLongtitude = currentLocation!.longitude
    }
    
    @IBAction func saveNewLocation(_ sender: Any) {
        
        //let splitLocation = locationTextField.text!.components(separatedBy: ",")
        
        let nameText = nameTextField.text!
        let descriptionText = descriptionTextView.text!
        
        //let lat = Double(splitLocation[0])!
        let lat = self.animalLatitude
        //let long = Double(splitLocation[1])!
        let long = self.animalLongtitude
        
        guard let image = animalImageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        
        let dateOfPicture = UInt(Date().timeIntervalSince1970)
        var dataOfImage = Data()
        dataOfImage = UIImageJPEGRepresentation(image, 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(dateOfPicture)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            
            fileManager.createFile(atPath: filePath, contents: dataOfImage, attributes: nil)
            
            var animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
                as! Animal
            
            animal.name = nameText
            animal.descriptionOfAnimal = descriptionText
            animal.photoPath = "\(dateOfPicture)"
            animal.latitudeOfAnimal = lat!
            animal.longtitudeOfAnimal = long!
            
            
            //save data to the database
            do {
                try managedObjectContext.save()
            }
            catch let error {
                print("Could not save Core Data: \(error)")
            }
            
            navigationController?.popViewController(animated: true)
            //addNewLocation(name: nameText, description: descriptionText, lat: lat, long: long)
            
        }
    }
    
    func displayMessage(_ message: String, _ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
        
        
        locationManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManger.distanceFilter = 10
        
        locationManger.delegate = self
        
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
        //locationManger.stopUpdatingLocation()
        
        let initialLocation = CLLocation(latitude: -37.877, longitude: 145.045)
        centerMapOnLocation(location: initialLocation)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.locationMapView.addGestureRecognizer(longPressGesture)

        
    }
    
    //reference from https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.locationMapView)
            let coordinate = self.locationMapView.convert(point, toCoordinateFrom: self.locationMapView)
            //print(coordinate)
            
            locationMapView.removeAnnotations(locationMapView.annotations)
            
            //Now use this coordinate to add annotation on map.
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Set title and subtitle if you want
            annotation.title = "Here"
            annotation.subtitle = "subtitle"
            self.locationMapView.addAnnotation(annotation)
            
            
            let location = CLLocation(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude))
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    
                    print(firstLocation!.name, firstLocation!.locality, firstLocation?.administrativeArea, firstLocation!.postalCode)
                    
                    self.locationLabel.text = "\((firstLocation!.name)!), \((firstLocation!.locality)!)"
                    
                    //completionHandler(firstLocation)
                } else {
                    self.locationLabel.text = "Sorry we cannot recognize this location!"
                }
            })
            
            self.animalLatitude = annotation.coordinate.latitude
            self.animalLongtitude = annotation.coordinate.longitude
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        locationMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Please type animal description here"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc: CLLocation = locations.last!
        currentLocation = loc.coordinate
    }
    

    
//    func addNewLocation(name: String, description: String, lat: Double, long: Double) {
//
//        let location: FencedAnnotation = FencedAnnotation(newTitle: name, newSubtitle: description, lat: lat, long: long)
//        delegate?.didSaveLocation(location)
//        self.navigationController?.popViewController(animated: true)
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
