//
//  Pin+CoreDataProperties.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/18/16.
//  Copyright © 2016 Student. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var location: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?

}
