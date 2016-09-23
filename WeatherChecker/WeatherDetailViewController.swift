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
    
    @IBOutlet weak var detailViewTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TableViewController")
        detailViewTitle.text = weatherLocation
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("TableViewController viewWillAppear")
        
    }
}
