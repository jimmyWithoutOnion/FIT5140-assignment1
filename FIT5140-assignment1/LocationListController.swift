//
//  LocationListController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 24/8/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol newLocationDelegate {
    func didSaveLocation(name: String, description: String, pathOfPicture: String, latitudeOfAnimal: Double, longtitudeOfAnimal: Double)
}


class LocationListController: UITableViewController, newLocationDelegate {

    var mapViewController: MapViewController?
    var animalList: [Animal] = []
    var currentAnimal: Animal?
    
    
    private var managedObjectContext: NSManagedObjectContext
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        
    
        super.init(coder: aDecoder)
        
        
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let location: FencedAnnotation = FencedAnnotation (newTitle: "Tiger", newSubtitle: "haha", lat: -37.877, long: 145.045)
        
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animal")
        do {
            let animals = try managedObjectContext.fetch(fetchRequest) as! [Animal]
            print(animals)
            print(animals.count)
            
            if animals.count == 0 {
                
                addInitialAnimalToData()
                
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
        
        //add annotation on the map section
        
        //self.mapViewController?.addAnnotation(annotation: location)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func addInitialAnimalToData() {
        var animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Tiger"
        animal.descriptionOfAnimal = "The tiger is the largest cat species, most recognizable for its pattern of dark vertical stripes on reddish-orange fur with a lighter underside. "
        animal.latitudeOfAnimal = -37.877167
        animal.longtitudeOfAnimal = 145.045262
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Elephent"
        animal.descriptionOfAnimal = "All elephants have several distinctive features, the most notable of which is a long trunk (also called a proboscis), used for many purposes, particularly breathing, lifting water, and grasping objects. "
        animal.latitudeOfAnimal = -37.874255
        animal.longtitudeOfAnimal = 145.047467
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Penguin"
        animal.descriptionOfAnimal = "Penguins are a group of aquatic, flightless birds. They live almost exclusively in the Southern Hemisphere, with only one species, the Galapagos penguin, found north of the equator. "
        animal.latitudeOfAnimal = -37.876753
        animal.longtitudeOfAnimal = 145.033955
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Kangaroo"
        animal.descriptionOfAnimal = "Kangaroos are indigenous to Australia. The Australian government estimates that 34.3 million kangaroos lived within the commercial harvest areas of Australia in 2011, up from 25.1 million one year earlier. "
        animal.latitudeOfAnimal = -37.871939
        animal.longtitudeOfAnimal = 145.039291
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Monkey"
        animal.descriptionOfAnimal = "Monkeys are non-hominoid simians, generally possessing tails and consisting of about 260 known living species. Many monkey species are tree-dwelling (arboreal), although there are species that live primarily on the ground, such as baboons. "
        animal.latitudeOfAnimal = -37.882645
        animal.longtitudeOfAnimal = 145.044537
        
        //save data to the database
        do {
            try managedObjectContext.save()
        }
        catch let error {
            print("Could not save Core Data: \(error)")
        }
    }
    

    
    func didSaveLocation(name: String, description: String, pathOfPicture: String, latitudeOfAnimal: Double, longtitudeOfAnimal: Double) {
        
        var newAnimal: Animal!
        newAnimal.name = name
        newAnimal.descriptionOfAnimal = description
        newAnimal.latitudeOfAnimal = latitudeOfAnimal
        newAnimal.longtitudeOfAnimal = longtitudeOfAnimal
        
        self.animalList.append(newAnimal)
        
        var animalEntity = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animalEntity.name = name
        animalEntity.descriptionOfAnimal = description
        animalEntity.latitudeOfAnimal = latitudeOfAnimal
        animalEntity.longtitudeOfAnimal = longtitudeOfAnimal
        
        saveData()
        
        //self.mapViewController?.addAnnotation(annotation: animal as! MKAnnotation)
        self.tableView.reloadData()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return animalList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        //let animal: Animal = self.animalList(at: indexPath.row) as! Animal
        cell.textLabel!.text = animalList[indexPath.row].name
        cell.detailTextLabel!.text = "Lat: \(animalList[indexPath.row].latitudeOfAnimal) Long: \(animalList[indexPath.row].longtitudeOfAnimal)"

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mapViewController?.focusOn(annotation: self.animalList[indexPath.row] as! MKAnnotation)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let deleteAnimal = animalList.remove(at: indexPath.row)
            
            managedObjectContext.delete(deleteAnimal)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
            
            saveData()
            
        }
    }
    
    func saveData() {
        do {
            try managedObjectContext.save()
        }
        catch let error {
            print("Could not save Core Data: \(error)")
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    //MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "AddLocation") {
            let controller = segue.destination as! NewLocationController
            controller.delegate = self
        }
        
    }
    

}
