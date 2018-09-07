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


class LocationListController: UITableViewController, newLocationDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {

    var mapViewController: MapViewController?
    var animalList: [Animal] = []
    
    //filteredlist for search
    var filteredAnimalList: [Animal] = []
    var currentAnimal: Animal?
    
    //geofencing variable
    var geoLocation: CLCircularRegion?
    var locationManger: CLLocationManager = CLLocationManager()
    

    private var managedObjectContext: NSManagedObjectContext
    
    
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animal")
        do {
            let animals = try managedObjectContext.fetch(fetchRequest) as! [Animal]
//            print(animals)
//            print(animals.count)
            
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
        
        for animalLocation in animalList {
            
            let location: FencedAnnotation = FencedAnnotation(newTitle: animalLocation.name!, newSubtitle: "", lat: animalLocation.latitudeOfAnimal, long: animalLocation.longtitudeOfAnimal)
            
            self.mapViewController?.addAnnotation(annotation: location)
            
            //
            geoLocation = CLCircularRegion(center: location.coordinate, radius: 100, identifier: location.title!)
            geoLocation!.notifyOnEntry = true
            geoLocation!.notifyOnExit = true
            
            locationManger.delegate = self
            locationManger.requestAlwaysAuthorization()
            locationManger.startMonitoring(for: geoLocation!)
        }
        
        //init filtered list
        filteredAnimalList = animalList
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search animal"
        navigationItem.searchController = searchController
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Normal","Ascending", "Descending"]
        searchController.searchBar.delegate = self

        

    }
    
    //alert when user entry
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Wellcome", message: "You have entered the animal area!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //alert when user left
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "See you", message: "You have left the animal area!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //refresh data after add new animal
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Animal")
        do {
            let animals = try managedObjectContext.fetch(fetchRequest) as! [Animal]
       
            filteredAnimalList = animals
            
        }
        catch {
            fatalError("Failed to fetch teams: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //init default animal to database
    func addInitialAnimalToData() {
        var animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Tiger"
        animal.descriptionOfAnimal = "The tiger is the largest cat species, most recognizable for its pattern of dark vertical stripes on reddish-orange fur with a lighter underside. "
        animal.latitudeOfAnimal = -37.877167
        animal.longtitudeOfAnimal = 145.045262
        animal.photoPath = ""
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Elephent"
        animal.descriptionOfAnimal = "All elephants have several distinctive features, the most notable of which is a long trunk (also called a proboscis), used for many purposes, particularly breathing, lifting water, and grasping objects. "
        animal.latitudeOfAnimal = -37.874255
        animal.longtitudeOfAnimal = 145.047467
        animal.photoPath = ""
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Penguin"
        animal.descriptionOfAnimal = "Penguins are a group of aquatic, flightless birds. They live almost exclusively in the Southern Hemisphere, with only one species, the Galapagos penguin, found north of the equator. "
        animal.latitudeOfAnimal = -37.876753
        animal.longtitudeOfAnimal = 145.033955
        animal.photoPath = ""
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Kangaroo"
        animal.descriptionOfAnimal = "Kangaroos are indigenous to Australia. The Australian government estimates that 34.3 million kangaroos lived within the commercial harvest areas of Australia in 2011, up from 25.1 million one year earlier. "
        animal.latitudeOfAnimal = -37.871939
        animal.longtitudeOfAnimal = 145.039291
        animal.photoPath = ""
        
        animal = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
            as! Animal
        
        animal.name = "Monkey"
        animal.descriptionOfAnimal = "Monkeys are non-hominoid simians, generally possessing tails and consisting of about 260 known living species. Many monkey species are tree-dwelling (arboreal), although there are species that live primarily on the ground, such as baboons. "
        animal.latitudeOfAnimal = -37.882645
        animal.longtitudeOfAnimal = 145.044537
        animal.photoPath = ""
        
        //save data to the database
        do {
            try managedObjectContext.save()
        }
        catch let error {
            print("Could not save Core Data: \(error)")
        }
    }
    

    
    func didSaveLocation(name: String, description: String, pathOfPicture: String, latitudeOfAnimal: Double, longtitudeOfAnimal: Double) {
        
//        var newAnimal: Animal!
//        newAnimal.name = name
//        newAnimal.descriptionOfAnimal = description
//        newAnimal.latitudeOfAnimal = latitudeOfAnimal
//        newAnimal.longtitudeOfAnimal = longtitudeOfAnimal
//
//        self.animalList.append(newAnimal)
//
//        var animalEntity = NSEntityDescription.insertNewObject(forEntityName: "Animal", into: managedObjectContext)
//            as! Animal
//        
//        animalEntity.name = name
//        animalEntity.descriptionOfAnimal = description
//        animalEntity.latitudeOfAnimal = latitudeOfAnimal
//        animalEntity.longtitudeOfAnimal = longtitudeOfAnimal
//
//        saveData()
        
        //self.mapViewController?.addAnnotation(annotation: animal as! MKAnnotation)
        
        self.tableView.reloadData()
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
    

    //MARK: search result updating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredAnimalList.count
        //return animalList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath) as! AnimalTableViewCell
        

        cell.nameLabel!.text = filteredAnimalList[indexPath.row].name
        cell.descriptionLabel!.text = filteredAnimalList[indexPath.row].descriptionOfAnimal
        do {

            if (filteredAnimalList[indexPath.row].photoPath != "") {
                print(filteredAnimalList[indexPath.row].name)
                try cell.animalImageView!.image = loadImageData(fileName: filteredAnimalList[indexPath.row].photoPath!)

            } else {
                let animalName = filteredAnimalList[indexPath.row].name?.lowercased()
                print(animalName!)
                try cell.animalImageView!.image = UIImage(named: "\(animalName!)")
            }

        } catch let error {
            print("Could not load image: \(error)")
        }
        

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        let animal: Animal = self.filteredAnimalList[indexPath.row]
        let locationAnnotation = FencedAnnotation(newTitle: animal.name!, newSubtitle: "", lat: animal.latitudeOfAnimal, long: animal.longtitudeOfAnimal)
        
        //detailedAnimal = animal
        
        self.mapViewController?.focusOn(annotation: locationAnnotation)
        
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
            
            let deleteAnimal = filteredAnimalList.remove(at: indexPath.row)
            
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
            
        } else if (segue.identifier == "AnimalDetailSegue") {
            let detailAnimal = filteredAnimalList[(self.tableView.indexPathForSelectedRow?.row)!]
            
            let controller = segue.destination as! AnimalDetailViewController
            controller.animal = detailAnimal
            
        }
        
    }
    
}

extension LocationListController: UISearchBarDelegate {

    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Normal") {
        
        print(searchText, scope)
        
        if (searchText != "") {
            filteredAnimalList = animalList.filter({(animal: Animal) -> Bool in
                return (animal.name?.contains(searchText))!
            })
        } else {
            filteredAnimalList = animalList
        }
        
        switch scope {
        case "Ascending":
            filteredAnimalList.sort(by: { $0.name! < $1.name!})
            
            break
        case "Descending":
            filteredAnimalList.sort(by: { $0.name! > $1.name!})
            
            break
        default:
            break
        }
        
        print(filteredAnimalList)
        
        
        tableView.reloadData()
        
    }
    
    
}



