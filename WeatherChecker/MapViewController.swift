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

class MapViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherInfoButton: UIButton!
    
    @IBOutlet weak var mapTextField: UITextField!
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    
    let textFieldDelegate = TextFieldDelegate()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0

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
        print("viewDidLoad")
        super.viewDidLoad()
        mapView.delegate = self
        self.activityIndicator.isHidden = true

        
     }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapTextField.text = " "

        setTextFields(textField: mapTextField)
        
        subscribeToKeyboardNotifications()
        subscribeToKeyboardWillHideNotifications()
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        let fr:NSFetchRequest<Pin> = Pin.fetchRequest()  as! NSFetchRequest<Pin>
        fr.sortDescriptors = [NSSortDescriptor(key: "location", ascending:  true)]
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            print("no fetched results")
            
        }
        else {
            
            for pin in (fetchedResultsController?.fetchedObjects)! {
                
                print("fetchedObjects")
                print(pin)
                //self.setAnnotations(pin: pin )
                self.mapView.reloadInputViews()
                self.setAnnotations(pin: pin )
                
                
            }
        }


        
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setTextFields(textField:UITextField) {
        print("setTextFields")
        
        textField.textAlignment = NSTextAlignment.center
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = textFieldDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addPinButtonPressed(_ sender: AnyObject) {
 
        print("addPin button pressed")
        print(mapTextField.text)
        
        let geocoder = CLGeocoder()
        
        self.activityIndicator.isHidden = false

        self.activityIndicator.startAnimating()
        
        
        geocoder.geocodeAddressString(mapTextField.text!, completionHandler: {placemarks, error in
            
            if Reachability.isConnectedToNetwork() != true {
              
                let uiAlertController = UIAlertController(title: "geocoding error", message: "Your internet is disconnected, please try again", preferredStyle: .alert)
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                uiAlertController.addAction(defaultAction)
                self.present(uiAlertController, animated: true, completion: nil)
            }
            
            if (error != nil) {
                print("geocoding error")
                print(error?.localizedDescription)
                let errorMsg  = error?.localizedDescription
                let uiAlertController = UIAlertController(title: "geocoding error", message: errorMsg, preferredStyle: .alert)
                
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                uiAlertController.addAction(defaultAction)
                self.present(uiAlertController, animated: true, completion: nil)
                
            }
            else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.mapTextField.resignFirstResponder()
            


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
                
                _ = 1000 as CLLocationDistance
                self.mapView.delegate = self
                
                                //let fr = NSFetchRequest(entityName: "Pin")
                let fr = Pin.fetchRequest() as! NSFetchRequest<Pin>

                fr.sortDescriptors = [NSSortDescriptor(key: "location", ascending:  true)]
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.addPin(location: self.mapTextField.text!, latitude: "\(self.latitude)", longitude: "\(self.longitude)")
                self.mapTextField.text = " "


            }
    
        })
    }
    

    @IBAction func weatherInfoButtonPressed(_ sender: AnyObject) {
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
        
        annotation.title = pin.location
      
        
        self.mapView.addAnnotation(annotation)
        
    }
    
    func addPin(location:String, latitude:String, longitude:String) {
        
        let pin = Pin(location: location, latitude: latitude, longitude: longitude, context: fetchedResultsController!.managedObjectContext)
        print("addPin", pin)
        
        do {
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            
            try stack.save()
        }catch{
            print("error while saving")
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        print("prepareForSegue")
        
    
        
        if segue.identifier == "showWeatherInfo" {
            if let weatherInfoTableViewController = segue.destination as? WeatherInfoTableViewController {
                
                
                let fr = Pin.fetchRequest() as! NSFetchRequest<Pin>

                fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending:  true), NSSortDescriptor(key: "longitude", ascending:  true)]
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                
             
             fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                
             print("testFetchedResultsController.fetchedObjects in prepareForSegue", fetchedResultsController!.fetchedObjects)
                
             weatherInfoTableViewController.weatherInfoFetchedResultsController = fetchedResultsController
               
                
            }
            
        }
        
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        print("keyboardWillShow")

    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide")
            view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(_ notification:NSNotification) -> CGFloat {
        print("getKeyboardHeight")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        print("subscribeToKeyboardNotifications")
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func subscribeToKeyboardWillHideNotifications() {
        print("subscribeToKeyboardNotifications")
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        print("unsubscribeFromKeyboardNotifications")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardWillHideNotifications() {
        print("unsubscribeFromKeyboardNotifications")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
 
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            
            let url = NSURL(string: ((view.annotation?.subtitle)!)!)!
            UIApplication.shared.openURL(url as URL)
            
            
        }
    }
    
    
}

