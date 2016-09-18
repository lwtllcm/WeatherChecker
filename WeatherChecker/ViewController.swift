//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func weatherInfoButtonPressed(sender: AnyObject) {
        print("WeatherInfo button pressed")
        print(mapTextField.text)

        
    }
}

