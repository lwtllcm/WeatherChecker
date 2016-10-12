////
//  DBClient.swift
//  WeatherChecker
//
//  Created by Laurie Wheeler on 9/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class DBClient {
    
    var session = URLSession.shared
    
    
    class  func sharedInstance() -> DBClient {
        struct Singleton {
            static let sharedInstance = DBClient()
            
            private init() {}
        }
        return Singleton.sharedInstance
    }
    
    
    func getWeatherData(lat:String, lon: String, completionHandlerForGet: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        print("DBClient getWeatherData")
        let components = NSURLComponents()
        components.scheme = "http"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
        
        let queryItem1 = NSURLQueryItem(name:"lat", value:lat)
        let queryItem2 = NSURLQueryItem(name:"lon", value:lon)
        let queryItem3 = NSURLQueryItem(name:"appid", value:"5c1ed52c4b27b30dfa7a5ced97c4e8d8")
        let queryItem4 = NSURLQueryItem(name: "units", value:"imperial")

        components.queryItems?.append(queryItem1 as URLQueryItem)
        components.queryItems?.append(queryItem2 as URLQueryItem)
        components.queryItems?.append(queryItem3 as URLQueryItem)
        components.queryItems?.append(queryItem4 as URLQueryItem)
        
        let request = NSMutableURLRequest(url: components.url!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        print(request)
        
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            
            print("data",data)
            print(" ")
            print("response", response)
            print("error", error)
            print("data task completed")
            
            
            func sendError(error: String) {
                
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(nil, NSError(domain: "getWeatherData", code: 1, userInfo: userInfo))
                
            }
            
            if Reachability.isConnectedToNetwork() != true {
                print("notConnected")
                sendError(error: "Your internet is disconnected, please try again")
            }
            
            
            if error != nil
            {
                sendError(error: (error?.localizedDescription)!)
                return
            }
            
            
            if data == nil {
                sendError(error: "Error retrieving data")
                return
            }
            
            
            self.convertDataWithCompletionHandler(data: data! as NSData, completionHandlerForConvertData: completionHandlerForGet)
            
            
        }
        task.resume()
        return task
        
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
       // var parsedResult: AnyObject!
        
        do {
            
            //parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
            
             let parsedResult = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            completionHandlerForConvertData(parsedResult as AnyObject?, nil)

              //  print(parsedResult)
            
            
            
        }
        catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        //completionHandlerForConvertData(parsedResult, nil)
        
    }
    
    
}
