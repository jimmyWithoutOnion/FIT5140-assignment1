//
//  NewLocationController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 24/8/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit
import MapKit


class NewLocationController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {
    
    var delegate: newLocationDelegate?
    var locationManger: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    

    
    
    @IBAction func saveCurrentLocation(_ sender: Any) {
        
        
        //change to readable address and display
        
        
        self.locationTextField.text = "\(currentLocation!.latitude),\(currentLocation!.longitude)"
        
    }
    @IBAction func saveNewLocation(_ sender: Any) {
        
        let splitLocation = locationTextField.text!.components(separatedBy: ",")
        
        let nameText = nameTextField.text!
        let descriptionText = descriptionTextView.text!
        
        let lat = Double(splitLocation[0])!
  
        let long = Double(splitLocation[1])!
     
        
        addNewLocation(name: nameText, description: descriptionText, lat: lat, long: long)
        
        
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
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Please type your description here"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc: CLLocation = locations.last!
        currentLocation = loc.coordinate
    }
    

    
    func addNewLocation(name: String, description: String, lat: Double, long: Double) {
        
        let location: FencedAnnotation = FencedAnnotation(newTitle: name, newSubtitle: description, lat: lat, long: long)
        delegate?.didSaveLocation(location)
        self.navigationController?.popViewController(animated: true)
        
    }

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
