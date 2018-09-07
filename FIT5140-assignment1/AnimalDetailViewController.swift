//
//  AnimalDetailViewController.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 6/9/18.
//  Copyright © 2018 jimmy. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {

    @IBOutlet weak var animalName: UILabel!
    @IBOutlet weak var animalImageVIew: UIImageView!
    @IBOutlet weak var animalDescription: UILabel!
    
    var animal: Animal?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        
        
        
        animalName.text = animal?.name
        animalDescription.text = animal?.descriptionOfAnimal
        
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
