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

        }
        
    
    
    override func viewWillAppear(animated: Bool) {
   
        super.viewWillAppear(animated)
        print("WeatherInfoTableViewController viewDidLoad")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        activityIndicator.startAnimating()
        
        let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects
        print("fetchedObjects", fetchedObjects)
        
        for pin in fetchedObjects! {
            print(pin)
            
        }
        
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
        
        pinCell.textLabel?.text = thisPin.location
        
        
        DBClient.sharedInstance().getWeatherData (thisPin.latitude!, lon: thisPin.longitude!) {(results, error) in
            print("taskForGetMethod")
           // print("results from taskForGETMethod", results)
           // print("error from taskForGETMethod", error)
            
            if (error != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    let errorMsg  = error?.localizedDescription
                    
                    let uiAlertController = UIAlertController(title: "download error", message: errorMsg, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    uiAlertController.addAction(defaultAction)
                    self.presentViewController(uiAlertController, animated: true, completion: nil)
                }
            }
            //}
            else {
                
                let thisWeatherDescription = results.valueForKey("weather")?.valueForKey("description") as! NSArray
                print(thisWeatherDescription[0])
                
                let weatherDetailsDictionary = NSMutableDictionary()
                weatherDetailsDictionary.setObject(results.valueForKey("name")!, forKey: "name")
                weatherDetailsDictionary.setObject((results.valueForKey("main")?.valueForKey("humidity"))!, forKey: "humidity")
                weatherDetailsDictionary.setObject((results.valueForKey("main")?.valueForKey("pressure"))!, forKey: "pressure")
                weatherDetailsDictionary.setObject((results.valueForKey("main")?.valueForKey("temp"))!, forKey: "temp")
                weatherDetailsDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunrise"))!, forKey: "sunrise")
                weatherDetailsDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")


                print(weatherDetailsDictionary)
                
                self.weatherDetailsArray.addObject(weatherDetailsDictionary)
                print(self.weatherDetailsArray)
                
                
                dispatch_async(dispatch_get_main_queue()) {

                pinCell.textLabel?.text = thisPin.location
                pinCell.detailTextLabel?.text = (thisWeatherDescription[0] as! String)
                    
                }
                
            }
            }
        })
        
        return pinCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath")
        print(weatherDetailsArray)
        print(weatherDetailsArray[indexPath.row])
        
        weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        print(weatherDetailsDictionary)
        
        let weatherDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("WeatherDetailViewController") as! WeatherDetailViewController
        weatherDetailViewController.weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        navigationController?.pushViewController(weatherDetailViewController, animated: true)
        

    }

    
}
