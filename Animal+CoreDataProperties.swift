//
//  Animal+CoreDataProperties.swift
//  FIT5140-assignment1
//
//  Created by jimmy on 30/8/18.
//  Copyright © 2018 jimmy. All rights reserved.
//
//

import Foundation
import CoreData


extension Animal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Animal> {
        return NSFetchRequest<Animal>(entityName: "Animal")
    }

    @NSManaged public var name: String?
    @NSManaged public var descriptionOfAnimal: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var latitudeOfAnimal: Double
    @NSManaged public var longtitudeOfAnimal: Double

}
