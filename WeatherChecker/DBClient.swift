//
//  DBClient.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class DBClient {
    
    var session = NSURLSession.sharedSession()
    
    
    class  func sharedInstance() -> DBClient {
        struct Singleton {
            static let sharedInstance = DBClient()
            
            private init() {}
        }
        return Singleton.sharedInstance
    }
    
    
    func getWeatherData(completionHandlerForGet: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("DBClient getWeatherData")
        let components = NSURLComponents()
        components.scheme = "http"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [NSURLQueryItem]()
        let queryItem1 = NSURLQueryItem(name:"lat", value:"35")
        let queryItem2 = NSURLQueryItem(name:"lon", value:"139")
        let queryItem3 = NSURLQueryItem(name:"appid", value:"5c1ed52c4b27b30dfa7a5ced97c4e8d8")
        let queryItem4 = NSURLQueryItem(name: "units", value:"imperial")
        components.queryItems?.append(queryItem1)
        components.queryItems?.append(queryItem2)
        components.queryItems?.append(queryItem3)
        components.queryItems?.append(queryItem4)
        
        let request = NSMutableURLRequest(URL: components.URL!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        print(request)
        
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            
            
            print("data",data)
            print(" ")
            print("response", response)
            print("error", error)
            print("data task completed")
            
            
            func sendError(error: String) {
                
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(result: nil, error:NSError(domain: "getWeatherData", code: 1, userInfo: userInfo))
                
            }
            
            
            if error != nil
            {
                sendError((error?.localizedDescription)!)
                return
            }
            
            
            if data == nil {
                sendError("Error retrieving data")
                return
            }
            
            
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGet)
            
            
        }
        task.resume()
        return task
        
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            
        }
        catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
        
    }
    
    
}
