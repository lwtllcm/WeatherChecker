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
    
    var weatherDetailsArray:NSMutableArray = []
    var weatherDetailsDictionary:NSMutableDictionary = [:]
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
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
        
        if let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects {

        for pin in fetchedObjects {
      
            
            let thisPin = pin as! Pin
            print(thisPin.location)
            let weatherDetailsDictionary = NSMutableDictionary()
            weatherDetailsDictionary.setObject(thisPin.location!, forKey: "location" as NSCopying)
            weatherDetailsDictionary.setObject(thisPin.latitude!, forKey: "latitude" as NSCopying)
            weatherDetailsDictionary.setObject(thisPin.longitude!, forKey: "longitude" as NSCopying)
            weatherDetailsArray.add(weatherDetailsDictionary)

            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
   
        super.viewWillAppear(animated)
        print("WeatherInfoTableViewController viewDidLoad")
        print(weatherDetailsArray)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        activityIndicator.startAnimating()
        
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
        
        let fetchedObjects = weatherInfoFetchedResultsController?.fetchedObjects
        print(fetchedObjects?.count)
        return (fetchedObjects?.count)!
    }
 
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pinCell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath as IndexPath)
        print("after dequeue")
        
        //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0).asynchronously(execute: {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pinCell = tableView.dequeueReusableCellWithIdentifier("PinCell") as UITableViewCell!
        
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
    */
            
            
            let fetchedObjects = self.weatherInfoFetchedResultsController?.fetchedObjects
            let thisPin = fetchedObjects![indexPath.row] 
            print("thisPin",thisPin.location)
            
            let thisDictionary = self.weatherDetailsArray[indexPath.row] as! NSMutableDictionary
            pinCell.textLabel?.text = thisDictionary.value(forKey: "location") as? String
            
            //DBClient.sharedInstance().getWeatherData (lat: thisDictionary.value(forKey: "latitude") as! String, lon: thisDictionary.value(forKey: "longitude") as! String) {(results, error) in
             
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
                    print("thisWeatherDescriptionArray",thisWeatherDescriptionArray)
                    
                    
                    if let thisWeatherDescription = (thisWeatherDescriptionArray[0] as AnyObject).value(forKey: "description")   {
                        print("thisWeatherDescription", thisWeatherDescription)
                            let thisWeatherDescriptionString = thisWeatherDescription
                            print("thisWeatherDescriptionString", thisWeatherDescriptionString)
                        
                
                        
                    //self.weatherDetailsDictionary.setObject(thisWeatherDescription, forKey: "description" as NSString)
                        //self.weatherDetailsDictionary["description"] =  thisWeatherDescription
                     self.weatherDetailsDictionary.setValue(thisWeatherDescriptionString, forKey: "description")

                    print("weatherDetailsDictionary forKey description", self.weatherDetailsDictionary.value(forKey: "description"))
                    
                        //thisDictionary.setObject(thisWeatherDescriptionArray, forKey: "description" as NSCopying)
                    
                    thisDictionary["description"] = self.weatherDetailsDictionary["description"]
                    print("thisDictionary for key description", thisDictionary["description"])
                        }
                    }
                        
                    let thisWeatherMain = results?.value(forKey: "main") as AnyObject
                    print(thisWeatherMain)
                    
                    
                    // http://stackoverflow.com/questions/33908212/converting-nsobject-anyobject-to-string-anyobject-in-swift
                    
                    let thisWeatherMainDictionary = thisWeatherMain as? [String:AnyObject]
                    print("thisWeatherMainDictionary", thisWeatherMainDictionary)
                    
                    
                    if let thisWeatherMainHumidity = thisWeatherMainDictionary?["humidity"] {
                    
                    print("humidity", thisWeatherMainHumidity )
                        
                   thisDictionary.setObject(thisWeatherMainHumidity, forKey: "humidity" as NSCopying)
                    }
                    
                    if let thisWeatherMainPressure = thisWeatherMainDictionary?["pressure"] {
                        
                        print("pressure", thisWeatherMainPressure )
                        
                        thisDictionary.setObject(thisWeatherMainPressure, forKey: "pressure" as NSCopying)
                    }
                    
                    
                    if let stringTemp = thisWeatherMainDictionary?["temp"] {
                        print(stringTemp)
                        let numTemp = stringTemp as! Int
                        print(numTemp)
                        thisDictionary.setObject(numTemp, forKey: "temp" as NSCopying)
                        
                    }
                    else {
                        thisDictionary.setObject(thisWeatherMainDictionary?["temp"], forKey: "temp" as NSCopying)
                    }

                    let thisWeatherSys = results?.value(forKey: "sys") as AnyObject
                    print(thisWeatherSys)
                    
                    let thisWeatherSysDictionary = thisWeatherSys as? [String:AnyObject]
                    print("thisWeatherSysDictionary", thisWeatherSysDictionary)
                    
                    if let numSunrise = thisWeatherSysDictionary?["sunrise"] {
                        print(numSunrise)
                        let stringSunrise = String(describing: numSunrise)
                        
                        print(stringSunrise)
                        let numSunrise  = Double(stringSunrise)
                        print(numSunrise)
                        let utcFormattedSunrise = NSDate(timeIntervalSince1970: numSunrise!)
                        print(utcFormattedSunrise)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunrise = formatter.string(from: utcFormattedSunrise as Date)
                        print(formattedSunrise)
                        thisDictionary.setObject(formattedSunrise, forKey: "sunrise" as NSCopying)
                    }
                        
                    else {
                        thisDictionary.setObject(thisWeatherSysDictionary?["sunrise"], forKey: "sunrise" as NSCopying)
                        
                    }
                    
                    if let numSunset = thisWeatherSysDictionary?["sunset"] {
                        print(numSunset)
                        let stringSunset = String(describing: numSunset)
                        
                        print(stringSunset)
                        let numSunset  = Double(stringSunset)
                        print(numSunset)
                        let utcFormattedSunset = NSDate(timeIntervalSince1970: numSunset!)
                        print(utcFormattedSunset)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunset = formatter.string(from: utcFormattedSunset as Date)
                        print(formattedSunset)
                        thisDictionary.setObject(formattedSunset, forKey: "sunset" as NSCopying)
                    }
                        
                    else {
                        thisDictionary.setObject(thisWeatherSysDictionary?["sunset"], forKey: "sunset" as NSCopying)
                        
                    }

                    
                    //thisDictionary.setObject((results.valueForKey("main")?.valueForKey("humidity"))!, forKey: "humidity")


                    
                    //let thisWeatherDescription = (results?.value(forKey: "weather")? as AnyObject).value("description") as! NSArray
                    
                    //self.weatherDetailsDictionary.setObject(thisWeatherDescription[0], forKey: "description")
                    
                    //print(self.weatherDetailsDictionary.valueForKey("description"))
                    
                    //thisDictionary.setObject(results.valueForKey("weather")?.valueForKey("description"), forKey: "description")
                    
                    
                  /*
                    thisDictionary.setObject((results.valueForKey("main")?.valueForKey("humidity"))!, forKey: "humidity")
                    thisDictionary.setObject((results.valueForKey("main")?.valueForKey("pressure"))!, forKey: "pressure")
                    
                    if let stringTemp = results.valueForKey("main")?.valueForKey("temp") {
                        print(stringTemp)
                        let numTemp = stringTemp as! Int
                        print(numTemp)
                        thisDictionary.setObject(numTemp, forKey: "temp")
                        
                    }
                    else {
                        thisDictionary.setObject((results.valueForKey("main")?.valueForKey("temp"))!, forKey: "temp")
                    }
                    
                    
                    if let numSunrise = results.valueForKey("sys")?.valueForKey("sunrise") {
                        print(numSunrise)
                        let stringSunrise = String(numSunrise)
                        
                        print(stringSunrise)
                        let numSunrise  = Double(stringSunrise)
                        print(numSunrise)
                        let utcFormattedSunrise = NSDate(timeIntervalSince1970: numSunrise!)
                        print(utcFormattedSunrise)
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunrise = formatter.stringFromDate(utcFormattedSunrise)
                        print(formattedSunrise)
                        thisDictionary.setObject(formattedSunrise, forKey: "sunrise")
                    }
                        
                    else {
                        thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunrise"))!, forKey: "sunrise")
                        
                    }
                    
                    
                    if let numSunset = results.valueForKey("sys")?.valueForKey("sunset") {
                        print(numSunset)
                        let stringSunset = String(numSunset)
                        
                        print(stringSunset)
                        let numSunset  = Double(stringSunset)
                        print(numSunset)
                        let utcFormattedSunset = NSDate(timeIntervalSince1970: numSunset!)
                        print(utcFormattedSunset)
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "hh.mm a"
                        let formattedSunset = formatter.stringFromDate(utcFormattedSunset)
                        print(formattedSunset)
                        thisDictionary.setObject(formattedSunset, forKey: "sunset")
                    }
                        
                    else {
                        thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")
                        
                    }
                    
                    
                    
                    // thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunrise"))!, forKey: "sunrise")
                    // thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")
                    print(self.weatherDetailsArray[indexPath.row])
 */
                    //DispatchQueue.main.asynchronously() {
                    
                    
                    DispatchQueue.main.async {
                        
                        
                        //pinCell.detailTextLabel?.text = thisWeatherDescription[0] as? String
                        pinCell.detailTextLabel?.text = thisDictionary.value(forKey: "description") as! String?
                    }
                  
                }
            }
        } //)
        
        return pinCell
    }
    
    
    
    /*
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pinCell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath as IndexPath)
       print("after dequeue")
        
        //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0).asynchronously(execute: {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        

        let fetchedObjects = self.weatherInfoFetchedResultsController?.fetchedObjects
        let thisPin = fetchedObjects![indexPath.row] as! Pin
        print("thisPin",thisPin.location)
        
        let thisDictionary:NSMutableDictionary = self.weatherDetailsArray[indexPath.row] as! NSMutableDictionary
       
            // pinCell?.textLabel?.text = (thisDictionary as AnyObject).value("location") as! String
            //pinCell?.textLabel?.text = thisDictionary.value(forKey: "location") as! String?
            print("thisDictionary", thisDictionary)
            pinCell.textLabel?.text = thisDictionary.value(forKey: "location") as! String?


            
        //DBClient.sharedInstance().getWeatherData (lat: (thisDictionary as AnyObject).value(forKey: "latitude") as! String, lon: (thisDictionary as AnyObject).value("longitude") as! String) {(results, error) in
  
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
                
                
                //let thisWeatherDescription = (results?.value(forKey: "weather")? as AnyObject).value("description") as! NSArray
            print(results?.value(forKey: "weather"))
            
            
           // let thisWeather = results?.value(forKey: "weather") as! NSDictionary
           // let thisWeatherDescription = thisWeather.value(forKey: "desciption") as! NSArray
            let thisWeatherDescription = results?.value(forKey: "weather")
                
                
              //  self.weatherDetailsDictionary.setObject(thisWeatherDescription[0], forKey: "description" as NSCopying)
                print(self.weatherDetailsDictionary.value(forKey: "description"))

                //(thisDictionary as AnyObject).setObject((results?.value(forKey: "weather")? as AnyObject).value("description"), forKey: "description")
            thisDictionary.setValue(self.weatherDetailsDictionary.value(forKey: "description"), forKey: "description")
            
            //(thisDictionary as AnyObject).set(((results?.value(forKey: "main") as AnyObject).value("humidity"))!, forKey: "humidity")
            
            let thisWeatherMain = results?.value(forKey: "main") as AnyObject
            print("thisWeatherMain", thisWeatherMain)
            
            
           // thisDictionary.setValue((results?.value(forKey: "main") as AnyObject).value(forKey: "humidity"), forKey:"humidity")
         
            
            if let thisWeatherHumidity = thisWeatherMain.value(forKey: "humidity")  {
            print(thisWeatherHumidity as! String)
           
            thisDictionary.setValue(thisWeatherMain.value(forKey: "humidity"), forKey:"humidity")
                
            }
            //(((results?.value(forKey: "main") as AnyObject).value("humidity"))!, forKey: "humidity")
            
            
               // (thisDictionary as AnyObject).setObject(((results?.valueForKey("main") as AnyObject).value("pressure"))!, forKey: "pressure")
            
            thisDictionary.setValue((results?.value(forKey: "main") as AnyObject).value(forKey: "pressure"), forKey: "pressure")

            
            
            if let stringTemp = (results?.value(forKey: "main") as AnyObject).value(forKey: "temp") {
                print(stringTemp)
                let numTemp = stringTemp as! Int
                print(numTemp)
                thisDictionary.setValue(numTemp, forKey: "temp")
                
            }
            else {
                //thisDictionary.setValue((results?.value(forKey("main") as AnyObject).value(forKey: "temp"), forKey: "temp")
                thisDictionary.setValue((results?.value(forKey: "main") as AnyObject).value(forKey: "temp"), forKey: "temp")
            }
            
            
            if let numSunrise = (results?.value(forKey: "sys") as AnyObject).value(forKey: "sunrise") {
                print(numSunrise)
                let stringSunrise = String(describing: numSunrise)
                
                print(stringSunrise)
                let numSunrise  = Double(stringSunrise)
                print(numSunrise)
                let utcFormattedSunrise = NSDate(timeIntervalSince1970: numSunrise!)
                print(utcFormattedSunrise)
              
                let formatter = DateFormatter()
                formatter.dateFormat = "hh.mm a"
                let formattedSunrise = formatter.string(from: utcFormattedSunrise as Date)
                print(formattedSunrise)
                thisDictionary.setValue(formattedSunrise, forKey: "sunrise")
                }
                
            else {

                thisDictionary.setValue((results?.value(forKey: "sys") as AnyObject).value(forKey: "sunrise"), forKey: "sunrise")

            }
            
            
            if let numSunset = (results?.value(forKey: "sys") as AnyObject).value(forKey: "sunset") {
                print(numSunset)
                let stringSunset = String(describing: numSunset)
                
                print(stringSunset)
                let numSunset  = Double(stringSunset)
                print(numSunset)
                let utcFormattedSunset = NSDate(timeIntervalSince1970: numSunset!)
                print(utcFormattedSunset)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "hh.mm a"
                let formattedSunset = formatter.string(from: utcFormattedSunset as Date)
                print(formattedSunset)
                thisDictionary.setValue(formattedSunset, forKey: "sunset")
            }
                
            else {
                //thisDictionary.setValue((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")
                thisDictionary.setValue((results?.value(forKey: "sys") as AnyObject).value(forKey: "sunset"), forKey: "sunset")

                
            }
            

            
               // thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunrise"))!, forKey: "sunrise")
               // thisDictionary.setObject((results.valueForKey("sys")?.valueForKey("sunset"))!, forKey: "sunset")
                print(self.weatherDetailsArray[indexPath.row])
                
                DispatchQueue.main.async() {


               // pinCell.detailTextLabel?.text = thisWeatherDescription[0] as? String
                    
                }
                
            }
        }
    } //)
        
        return pinCell
    }
 
 */
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    <#code#>
   // }
    //  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        
        print("didSelectRowAtIndexPath")
        
        let weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        print(weatherDetailsDictionary)
        
        let weatherDetailViewController = storyboard?.instantiateViewController(withIdentifier: "WeatherDetailViewController") as! WeatherDetailViewController
        weatherDetailViewController.weatherDetailsDictionary = weatherDetailsArray[indexPath.row] as! NSMutableDictionary
        navigationController?.pushViewController(weatherDetailViewController, animated: true)
        

    }

    
}
