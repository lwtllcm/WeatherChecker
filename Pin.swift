//
//  Pin.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/18/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(location: String, latitude: String, longitude: String, context: NSManagedObjectContext) {
        
        if let pin = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity:pin, insertIntoManagedObjectContext: context)
            self.location = location
            self.latitude = latitude
            self.longitude = longitude
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}
