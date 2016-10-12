//
//  WeatherDetailViewController.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/22/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class  WeatherDetailViewController: UIViewController {
    
    var weatherLocation:String = ""
    var weatherDetailsDictionary:NSMutableDictionary = [:]
    
    @IBOutlet weak var detailViewTitle: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    
    @IBOutlet weak var sunsetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WeatherDetailViewController")
        detailViewTitle.text = weatherLocation
        
        print(weatherDetailsDictionary)
        
        detailViewTitle.text = weatherDetailsDictionary.value(forKey: "location") as? String
        
        if let convertTemp = weatherDetailsDictionary.value(forKey: "temp") {
        print(convertTemp)
        tempLabel.text =  String(describing: convertTemp)
        }
        
        if let convertHumidity =  weatherDetailsDictionary.value(forKey: "humidity") {
        print(convertHumidity)
        humidityLabel.text =  String(describing: convertHumidity)
        }
        
        if let convertPressure = weatherDetailsDictionary.value(forKey: "pressure") {
        print(convertPressure)
        pressureLabel.text =  String(describing: convertPressure)
        }
        
        if let convertSunrise = weatherDetailsDictionary.value(forKey: "sunrise") {
            print(convertSunrise)
            sunriseLabel.text =  String(describing: convertSunrise)
        }

        
        if let convertSunset = weatherDetailsDictionary.value(forKey: "sunset") {
            print(convertSunset)
            
            sunsetLabel.text =  String(describing: convertSunset)
        }

        self.reloadInputViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("WeatherDetailViewController viewWillAppear")
        
    }
}
