//
//  MapViewController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 24/8/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    
    var selectedAnimalName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set initial location in monash caulfield campus
        let initialLocation = CLLocation(latitude: -37.877, longitude: 145.045)
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        print("addanno", annotation.title, annotation.subtitle)
        self.mapView.addAnnotation(annotation)
    }
    
    func focusOn(annotation: MKAnnotation) {
        
        print("focusanno", annotation.title, annotation.subtitle)
        
        
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.showAnnotations([annotation], animated: true)
        self.mapView.selectAnnotation(annotation, animated: true)
        
    }
    
    func removeAnnotationFromMap(annotation: MKAnnotation) {
        self.mapView.removeAnnotation(annotation)
    }
    
    func removeAnnotations() {
        self.mapView.removeAnnotations(mapView.annotations)
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reUseId = "annotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reUseId)
        
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reUseId)
        
        annotationView?.annotation = annotation
        
        var icon: UIImage?
        annotationView?.canShowCallout = true
     
        let imagePath = annotation.subtitle as! String
        print(imagePath)
        
        if imagePath == "" {
            let pathForOriginal = annotation.title as! String
            icon = convertImage(image: UIImage(named: pathForOriginal.lowercased())!, scaledToSize: CGSize(width: 30.0, height: 30.0))
        } else {
            icon = convertImage(image: loadImageData(fileName: imagePath)!, scaledToSize: CGSize(width: 30.0, height: 30.0))
        }
        UIGraphicsEndImageContext()
        
        annotationView?.image = icon
        
        //show informatin icon on the right side
        let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton as? UIView
        
        return annotationView
    }
    
    func convertImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let converteredImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return converteredImage
    }
    
    //load image from local storage
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//        if control == view.rightCalloutAccessoryView {
//            performSegue(withIdentifier: "toTheMoon", sender: self)
//
//            print("jump to the detail page")
//
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //print(view.annotation?.title)
            selectedAnimalName = (view.annotation?.title)!
            performSegue(withIdentifier: "animalDetailSegue", sender: self)
        }
    }
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "animalDetailSegue" {
            
//            let masterVC = self.splitViewController?.viewControllers.first
//            let detailVC = ((self.splitViewController?.viewControllers.count)! > 1) ? self.splitViewController?.viewControllers[1] : nil
            
            

//            print(view.annotation?.title)
            
//            let detailAnimal = filteredAnimalList[(self.tableView.indexPathForSelectedRow?.row)!]
//
            let controller = segue.destination as! AnimalDetailViewController
            controller.incomeAnimalName = selectedAnimalName
            
        }
        
        
    }
 

}
