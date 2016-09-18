//
//  WeatherInfoTableViewController.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class  WeatherInfoTableViewController: UITableViewController
{
    
    var weatherInfoFetchedResultsController:NSFetchedResultsController?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WeatherInfoTableViewController viewDidLoad")
        
        let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects
        print("fetchedObjects", fetchedObjects)
        
        for pin in fetchedObjects! {
            print(pin)
            //self.getLatLon(pin as! Pin)
        }

        
    }
}
