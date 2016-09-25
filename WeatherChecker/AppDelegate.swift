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

    var sharedSession = NSURLSession.sharedSession()
    
    func preloadData() {
        do {
            try stack.dropAllData()
        }catch{
            print("Error dropping all objects in DB")
        }
        
        
        //let pinLosAngeles = Pin(entity: "Los Angeles", insertIntoManagedObjectContext: stack.context)
        
        //let pinLosAngeles = Pin(location: "Los Angeles", latitude: "33.955190025712511", longitude: "-118.07473099889084", context: stack.context)
        
        // pinLosAngeles.location = "LosAngeles"
        // pinLosAngeles.latitude = "33.955190025712511"
        // pinLosAngeles.longitude = "-118.07473099889084"
        
        //print("pinLosAngeles", pinLosAngeles)
        
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        print(paths[0])
        
        stack.autoSave(60)

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

