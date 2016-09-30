//
//  TextFieldDelegate.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/29/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation
import UIKit

class  TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    override init() {
        super.init()
    }
    
    func textFieldDidBeginEditing( textField: UITextField) {
        print("textFieldDidBeginEditing")
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("textFieldShouldClear")
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersInRange")
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
    
}
