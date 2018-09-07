//
//  AnimalDetailViewController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 6/9/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var animalName: UILabel!
    @IBOutlet weak var animalImageVIew: UIImageView!
    @IBOutlet weak var animalDescription: UILabel!
    @IBOutlet weak var animalAddress: UILabel!
    
    var animal: Animal?
    
    var incomeAnimalName: String?
    
    var managedObjectContext: NSManagedObjectContext
    var animalList: [Animal] = []
    
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        
        
        print(incomeAnimalName)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animal")
        do {
            let animals = try managedObjectContext.fetch(fetchRequest) as! [Animal]
            
            if animals.count == 0 {
                
                //refetch the data from the database
                let newAnimals = try managedObjectContext.fetch(fetchRequest) as! [Animal]
                animalList = newAnimals
                
            } else {
                animalList = animals
                
            }
        }
        catch {
            fatalError("Failed to fetch teams: \(error)")
        }
        
        
        for newAnimal in animalList {
            if newAnimal.name == incomeAnimalName! {
                animal = newAnimal
            }
        }
        
        
        animalName.text = animal?.name
        animalDescription.text = animal?.descriptionOfAnimal
        
        
        let location = CLLocation(latitude: (animal?.latitudeOfAnimal)!, longitude: (animal?.longtitudeOfAnimal)!)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                
                //print(firstLocation!.name, firstLocation!.locality, firstLocation?.administrativeArea, firstLocation!.postalCode)
                
                self.animalAddress.text = "\((firstLocation!.name)!), \((firstLocation!.locality)!), \((firstLocation!.administrativeArea)!), \((firstLocation!.postalCode)!)"
                
                //completionHandler(firstLocation)
            } else {
                //completionHandler(nil)
            }
        })
        
        
        do {
            
            if (animal?.photoPath != "") {
                //print(filteredAnimalList[indexPath.row].name)
                try animalImageVIew!.image = loadImageData(fileName: (animal?.photoPath!)!)
                
            } else {
                let animalName = animal?.name?.lowercased()
                print(animalName!)
                try animalImageVIew!.image = UIImage(named: "\(animalName!)")
            }
            
        } catch let error {
            print("Could not load image: \(error)")
        }
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
