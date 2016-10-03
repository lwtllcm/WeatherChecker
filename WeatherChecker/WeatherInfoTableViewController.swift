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
    
    var weatherDetailsArray:NSMutableArray = []
    var weatherDetailsDictionary:NSMutableDictionary = [:]
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WeatherInfoTableViewController viewDidLoad")
        
        //https://gkbrown.org/2015/12/07/displaying-an-activity-indicator-while-loading-data-in-the-background/
       
        tableView.backgroundView = activityIndicator
        
        if Reachability.isConnectedToNetwork() {
            print("Connected")
        }
        else {
            print("not Connected")
        }
        
        let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects

        for pin in fetchedObjects! {
      
            
            let thisPin = pin as! Pin
            print(thisPin.location)
            let weatherDetailsDictionary = NSMutableDictionary()
            weatherDetailsDictionary.setObject(thisPin.location!, forKey: "location")
            weatherDetailsDictionary.setObject(thisPin.latitude!, forKey: "latitude")
            weatherDetailsDictionary.setObject(thisPin.longitude!, forKey: "longitude")
            weatherDetailsArray.addObject(weatherDetailsDictionary)

            
        }
    }
        
    override func viewWillAppear(animated: Bool) {
   
        super.viewWillAppear(animated)
        print("WeatherInfoTableViewController viewDidLoad")
        print(weatherDetailsArray)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        activityIndicator.startAnimating()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        activityIndicator.stopAnimating()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        
        let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects
        print(fetchedObjects?.count)
        return (fetchedObjects?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pinCell = tableView.dequeueReusableCellWithIdentifier("PinCell") as UITableViewCell!
       
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        let fetchedObjects = self.weatherInfoFetchedResultsController?.fetchedObjects
        let thisPin = fetchedObjects![indexPath.row] as! Pin
        print("thisPin",thisPin.location)
        
        let thisDictionary = self.weatherDetailsArray[indexPath.row]
        pinCell.textLabel?.text = thisDictionary.valueForKey("location") as! String
            
        DBClient.sharedInstance().getWeatherData (thisDictionary.valueForKey("latitude") as! String, lon: thisDictionary.valueForKey("longitude") as! String) {(results, error) in
  
            
           
        print("taskForGetMethod")
            
        if (error != nil) {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                let errorMsg  = error?.localizedDescription
                    
                let uiAlertController = UIAlertController(title: "download error", message: errorMsg, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                uiAlertController.addAction(defaultAction)
                self.presentViewController(uiAlertController, animated: true, completion: nil)
                }
            }
            
            
            else {
                
                
                let thisWeatherDescription = results.valueForKey("weather")?.valueForKey("description") as! NSArray
                
                
                self.weatherDetailsDictionary.setObject(thisWeatherDescription[0], forKey: "description")
                print(self.weatherDetailsDictionary.valueForKey("description"))

                thisDictionary.setObject(results.valueForKey("weather")?.valueForKey("description"), forKey: "description")
                thisDictionary.setObject((results.valueForKey("main")?.valueForKey("humidity"))!, forKey: "humidity")
                thisDictionary.setObject((results.valueForKey("main")?.valueForKey("pressure"))!, forKey: "pressure")
                thisDictionary.setObject((results.valueForKey("main")?.valueForKey("temp"))!, forKey: "temp")
                thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunrise"))!, forKey: "sunrise")
                thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")
                print(self.weatherDetailsArray[indexPath.row])
                
                dispatch_async(dispatch_get_main_queue()) {


                pinCell.detailTextLabel?.text = thisWeatherDescription[0] as? String
                    
                }
                
            }
        }
    })
        
        return pinCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath")
        
        let weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        print(weatherDetailsDictionary)
        
        let weatherDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("WeatherDetailViewController") as! WeatherDetailViewController
        weatherDetailViewController.weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        navigationController?.pushViewController(weatherDetailViewController, animated: true)
        

    }

    
}
