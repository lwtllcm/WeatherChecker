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
    
    @IBOutlet weak var detailViewTitle: UITextField!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    
    @IBOutlet weak var sunsetLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WeatherDetailViewController")
        //detailViewTitle.text = weatherLocation
        
        print(weatherDetailsDictionary)
        detailViewTitle.text = weatherDetailsDictionary.valueForKey("name") as? String
        let convertTemp = String(weatherDetailsDictionary.valueForKey("temp"))
        print(convertTemp)
        tempLabel.text =  String(convertTemp)
        
        let convertHumidity = String(weatherDetailsDictionary.valueForKey("humidity"))
        print(convertHumidity)
        humidityLabel.text =  String(convertHumidity)

        
        let convertPressure = String(weatherDetailsDictionary.valueForKey("pressure"))
        print(convertPressure)
        pressureLabel.text =  String(convertPressure)

        
        let convertSunrise = String(weatherDetailsDictionary.valueForKey("sunrise"))
        print(convertSunrise)
        sunriseLabel.text =  String(convertSunrise)

        
        let convertSunset = String(weatherDetailsDictionary.valueForKey("sunset"))
        print(convertSunset)
        sunsetLabel.text =  String(convertSunset)

        self.reloadInputViews()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("WeatherDetailViewController viewWillAppear")
        
    }
}
