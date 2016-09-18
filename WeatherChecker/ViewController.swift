//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherInfoButton: UIButton!
    @IBOutlet weak var mapTextField: UITextField!
    @IBOutlet weak var addPinButton: UIButton!
    
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribeToKeyboardNotifications()
        //subscribeToKeyboardWillHideNotifications()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                //self.activityIndicator.alpha = 0.0
                //self.activityIndicator.stopAnimating()
                
                
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
                self.mapView.setRegion(coordinateRegion, animated: true)
                self.mapView.centerCoordinate = thisCoordinate


            }
    
        })
    }
    

    @IBAction func weatherInfoButtonPressed(sender: AnyObject) {
        print("WeatherInfo button pressed")
        
    }
}

