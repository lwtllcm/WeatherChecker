//
//  AppDelegate.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let stack = CoreDataStack(modelName: "Model")!
    

    var sharedSession = URLSession.shared
   /*
    func preloadData() {
        do {
            try stack.dropAllData(coord: stack.coordinator, dbURL: stack.dbURL)
        }catch{
            print("Error dropping all objects in DB")
        }
        
    }
*/

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        print("didFinishLaunching")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("directory path", paths[0])
        
        stack.autoSave(delayInSeconds: 20)

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        do {
            try stack.saveContext()
        }catch{
            print("error while saving")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try stack.saveContext()
        }catch{
            print("error while saving")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("directory path", paths[0])

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

