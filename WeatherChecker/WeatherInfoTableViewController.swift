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

    var weatherInfoFetchedResultsController:NSFetchedResultsController<Pin>?
    
    var fetchedObjects = [Pin]()
    
    var weatherDetailsArray:NSMutableArray = []
    var weatherDetailsDictionary:NSMutableDictionary = [:]
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var fetchedResultsController:NSFetchedResultsController<Pin>? {
        didSet {
            executeSearch()
        }
    }
    
    func executeSearch() {
        print("executeSearch")
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
                
            }
            catch {
                print ("error in performFetch")
            }
        }
    }

    
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
        

        fetchedObjects = (weatherInfoFetchedResultsController?.fetchedObjects)!
        
        for pin in fetchedObjects {
      
            
            let thisPin = pin 
           // print(thisPin.location)
            let weatherDetailsDictionary = NSMutableDictionary()
            weatherDetailsDictionary.setObject(thisPin.location!, forKey: "location" as NSCopying)
            weatherDetailsDictionary.setObject(thisPin.latitude!, forKey: "latitude" as NSCopying)
            weatherDetailsDictionary.setObject(thisPin.longitude!, forKey: "longitude" as NSCopying)
            weatherDetailsArray.add(weatherDetailsDictionary)

            }
       // }
    }
        
    override func viewWillAppear(_ animated: Bool) {
   
        super.viewWillAppear(animated)
        print("WeatherInfoTableViewController viewDidLoad")
        //print(weatherDetailsArray)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        activityIndicator.startAnimating()
        
        
            fetchedObjects = (weatherInfoFetchedResultsController?.fetchedObjects)!
            
            for pin in fetchedObjects {
                
                
                let thisPin = pin
                print(thisPin.location)
                let weatherDetailsDictionary = NSMutableDictionary()
                weatherDetailsDictionary.setObject(thisPin.location!, forKey: "location" as NSCopying)
                weatherDetailsDictionary.setObject(thisPin.latitude!, forKey: "latitude" as NSCopying)
                weatherDetailsDictionary.setObject(thisPin.longitude!, forKey: "longitude" as NSCopying)
                weatherDetailsArray.add(weatherDetailsDictionary)
                
            }
      //  }

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        activityIndicator.stopAnimating()
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        print("fetchedObjects.count", fetchedObjects.count)
        
        return (fetchedObjects.count)
    }
 
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pinCell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath as IndexPath)
        print("after dequeue")
        
        print("fetchedObjects.count", self.fetchedObjects.count)

        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            
            self.fetchedObjects = (self.weatherInfoFetchedResultsController?.fetchedObjects)!
            let thisPin = self.fetchedObjects[indexPath.row]
            
            let thisDictionary = self.weatherDetailsArray[indexPath.row] as! NSMutableDictionary
            pinCell.textLabel?.text = thisDictionary.value(forKey: "location") as? String
            
            
            DBClient.sharedInstance().getWeatherData (lat: thisDictionary.value(forKey: "latitude") as! String, lon: thisDictionary.value(forKey: "longitude") as! String) {(results, error) in
                    

                
                
                print("taskForGetMethod")
                
                if (error != nil) {
                    OperationQueue.main.addOperation {
                        
                        let errorMsg  = error?.localizedDescription
                        
                        let uiAlertController = UIAlertController(title: "download error", message: errorMsg, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        uiAlertController.addAction(defaultAction)
                        self.present(uiAlertController, animated: true, completion: nil)
                    }
                }
                    
                    
                else {
                    
                    
                    
                    
                    
                    if let thisWeatherDescriptionArray = results?.value(forKey: "weather") as? NSArray {
                    
                    
                    if let thisWeatherDescription = (thisWeatherDescriptionArray[0] as AnyObject).value(forKey: "description")   {
                            let thisWeatherDescriptionString = thisWeatherDescription

                        self.weatherDetailsDictionary.setValue(thisWeatherDescriptionString, forKey: "description")

                    
                    thisDictionary["description"] = self.weatherDetailsDictionary["description"]

                        }
                    }
                        
                    let thisWeatherMain = results?.value(forKey: "main") as AnyObject
                    print(thisWeatherMain)
                    
                    
                    // http://stackoverflow.com/questions/33908212/converting-nsobject-anyobject-to-string-anyobject-in-swift
                    
                    let thisWeatherMainDictionary = thisWeatherMain as? [String:AnyObject]
                    
                    
                    if let thisWeatherMainHumidity = thisWeatherMainDictionary?["humidity"] {
                    
                        
                   thisDictionary.setObject(thisWeatherMainHumidity, forKey: "humidity" as NSCopying)
                    }
                    
                    if let thisWeatherMainPressure = thisWeatherMainDictionary?["pressure"] {
                        
                        
                        thisDictionary.setObject(thisWeatherMainPressure, forKey: "pressure" as NSCopying)
                    }
                    
                    
                    if let stringTemp = thisWeatherMainDictionary?["temp"] {
                        let numTemp = stringTemp as! Int
                        print(numTemp)
                        
                    }
                    else {
                        thisDictionary.setObject(thisWeatherMainDictionary?["temp"], forKey: "temp" as NSCopying)
                    }

                    let thisWeatherSys = results?.value(forKey: "sys") as AnyObject
                    
                    let thisWeatherSysDictionary = thisWeatherSys as? [String:AnyObject]
                    print("thisWeatherSysDictionary", thisWeatherSysDictionary)
                    
                    if let numSunrise = thisWeatherSysDictionary?["sunrise"] {

                        let stringSunrise = String(describing: numSunrise)
                        
                        let numSunrise  = Double(stringSunrise)

                        let utcFormattedSunrise = NSDate(timeIntervalSince1970: numSunrise!)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunrise = formatter.string(from: utcFormattedSunrise as Date)

                        thisDictionary.setObject(formattedSunrise, forKey: "sunrise" as NSCopying)
                    }
                        
                    else {
                        thisDictionary.setObject(thisWeatherSysDictionary?["sunrise"], forKey: "sunrise" as NSCopying)
                        
                    }
                    
                    if let numSunset = thisWeatherSysDictionary?["sunset"] {

                        let stringSunset = String(describing: numSunset)
                        
                        let numSunset  = Double(stringSunset)

                        let utcFormattedSunset = NSDate(timeIntervalSince1970: numSunset!)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunset = formatter.string(from: utcFormattedSunset as Date)
                        thisDictionary.setObject(formattedSunset, forKey: "sunset" as NSCopying)
                    }
                        
                    else {
                        thisDictionary.setObject(thisWeatherSysDictionary?["sunset"], forKey: "sunset" as NSCopying)
                        
                    }

                    
                    
                    
                    DispatchQueue.main.async {
                        
                        
                        pinCell.detailTextLabel?.text = thisDictionary.value(forKey: "description") as! String?
                    }
                  
                }
            }
        } //)
        
        return pinCell
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("didSelectRowAtIndexPath")
        
        let weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        
        let weatherDetailViewController = storyboard?.instantiateViewController(withIdentifier: "WeatherDetailViewController") as! WeatherDetailViewController
        weatherDetailViewController.weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        navigationController?.pushViewController(weatherDetailViewController, animated: true)
        

    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("commitEditingStyle")
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            print("ready to delete")
            
           
            fetchedObjects = (weatherInfoFetchedResultsController?.fetchedObjects)!
            
            let thisFetchedObject = fetchedObjects[indexPath.row]
            print(thisFetchedObject)
            
            print("count before save",fetchedObjects.count)
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack

            stack.context.delete(thisFetchedObject)
            
            
            do {
                try stack.save()
                print("after stack.save")
                print("fetchedObjects.count", fetchedObjects.count)

                let fr:NSFetchRequest<Pin> = Pin.fetchRequest()  as! NSFetchRequest<Pin>
                fr.sortDescriptors = [NSSortDescriptor(key: "location", ascending:  true)]
                
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedObjects = (fetchedResultsController?.fetchedObjects)!
                
                print(fetchedObjects.count)
                self.tableView.reloadData()
                self.tableView.reloadInputViews()
            }catch{
                print("error while saving")
            }
        
            self.tableView.reloadData()
            

            
        }
        
        
    }
}
