//
//  WebServiceJson.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit


class WebServiceJson : NSObject, NSURLConnectionDelegate, XMLParserDelegate, URLSessionDelegate {
    
    var servicetoken = ""
    var token = ""
    
    var mutableData: NSMutableData = NSMutableData()
    var currentElementName: NSString = ""
    var callbackfunc: (_ data: NSData) -> Int
    static var backgroundurlSession: URLSession?
    static var refreshing: Bool = false
    var identifier: UIBackgroundTaskIdentifier!
    
    
    init(callback: @escaping (NSData) -> Int){
        callbackfunc = callback
        super.init()
    }
    
    func Execute( JsonParams: NSDictionary, url: String, requestType: String) {
        
        let headers = [
            "cache-control": "no-cache",
            "postman-token": "5da208b5-3b21-103a-3134-3a7f5743a0a7"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15)

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        var session = URLSession.shared
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig)

        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("ERROR FOUND :", error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                let response = String(data: data!, encoding: String.Encoding.utf8)

                print(response ?? String())
                self.mutableData.append((data)!)
                self.callbackfunc(self.mutableData)
            }
        })
        
        dataTask.resume()
    }
}
