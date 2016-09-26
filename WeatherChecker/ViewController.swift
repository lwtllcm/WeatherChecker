//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherInfoButton: UIButton!
    
    @IBOutlet weak var mapTextField: UITextField!
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0

    var fetchedResultsController:NSFetchedResultsController? {
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
        mapView.delegate = self
        
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "location", ascending:  true)]
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            print("no fetched results")
            
        }
        else {
            for pin in (fetchedResultsController?.fetchedObjects)! {
                print(pin)
                self.setAnnotations(pin as! Pin)
                self.mapView.reloadInputViews()
                
            }
        }

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addPinButtonPressed(sender: AnyObject) {
 
        print("addPin button pressed")
        print(mapTextField.text)
        
        let geocoder = CLGeocoder()
        
        
        geocoder.geocodeAddressString(mapTextField.text!, completionHandler: {placemarks, error in
            
            
            if (error != nil) {
                print("geocoding error")
                print(error?.localizedDescription)
                let errorMsg  = error?.localizedDescription
                let uiAlertController = UIAlertController(title: "geocoding error", message: errorMsg, preferredStyle: .Alert)
                
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                uiAlertController.addAction(defaultAction)
                self.presentViewController(uiAlertController, animated: true, completion: nil)
                
            }
            else {
                
                let thisPlacemark = placemarks![0]
                print(thisPlacemark)
                print(thisPlacemark.location)
                let thisCoordinate:CLLocationCoordinate2D = (thisPlacemark.location?.coordinate)!
                
                self.latitude = thisCoordinate.latitude
                self.longitude = thisCoordinate.longitude
                
                print("thisCoordinate",thisCoordinate)
                
                
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = thisCoordinate
                
                self.mapView.addAnnotation(annotation)
                
                let regionRadius: CLLocationDistance = 1000
                
                
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(thisCoordinate, regionRadius * 2.0, regionRadius * 2.0)
                
                self.mapView.delegate = self
                
                
                let fr = NSFetchRequest(entityName: "Pin")
                fr.sortDescriptors = [NSSortDescriptor(key: "location", ascending:  true)]
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let stack = delegate.stack
                
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.addPin(self.mapTextField.text!, latitude: "\(self.latitude)", longitude: "\(self.longitude)")
                

            }
    
        })
    }
    

    @IBAction func weatherInfoButtonPressed(sender: AnyObject) {
        print("WeatherInfo button pressed")
        
    }
    
    
    func setAnnotations (pin:Pin) {
        print("setAnnotations")
        
        let lat1 = CLLocationDegrees(pin.latitude!)
        print(lat1)
        let long1 = CLLocationDegrees(pin.longitude!)
        print(long1)
        let coordinate1 = CLLocationCoordinate2D(latitude: lat1!, longitude: long1!)
        print(coordinate1)
  
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate1
        
        
        self.mapView.addAnnotation(annotation)
        
        
    }
    
    func addPin(location:String, latitude:String, longitude:String) {
        
        let pin = Pin(location: location, latitude: latitude, longitude: longitude, context: fetchedResultsController!.managedObjectContext)
        print("addPin", pin)
        
        do {
            
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            
            try stack.save()
        }catch{
            print("error while saving")
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue")
        
        if segue.identifier == "showWeatherInfo" {
            if let weatherInfoTableViewController = segue.destinationViewController as? WeatherInfoTableViewController {
                
                
                let fr = NSFetchRequest(entityName: "Pin")
                fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending:  true), NSSortDescriptor(key: "longitude", ascending:  true)]
                
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let stack = delegate.stack
                
             
             fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                
             print("testFetchedResultsController.fetchedObjects in prepareForSegue", fetchedResultsController!.fetchedObjects)
                
             weatherInfoTableViewController.weatherInfoFetchedResultsController = fetchedResultsController
               
                
            }
            
        }
        
    }
}

