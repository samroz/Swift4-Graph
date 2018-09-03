//
//  GetGraphData.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
public class GetGraphData {

    var arrDates = [String]()
    
    var arrGeneric = [Graph]()
    
    var arrtemperature = [Any]()
    var arrX = [Any]()
    var arrY = [Any]()
    var arrZ = [Any]()
    
    var didFinishParsingfunc: (_ inp: NSDictionary) -> Int
    
    init(didFinishParsingCallback: @escaping (NSDictionary) -> Int){
        didFinishParsingfunc = didFinishParsingCallback
    }
    
    func getGraphData(){
        
        let params = ["" : ""]
        
        let url = "https://dweet.io:443/get/dweets/for/nsemi"
//        let url = "https://www.skretting.com/es-ec/rss"
        
        let webservice = WebServiceJson(callback: Parse)
        webservice.Execute(JsonParams: params as NSDictionary, url: url, requestType: "GET")
    }
    
    func Parse(data: NSData) -> Int{
        
        var jsonResult: NSDictionary
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            var success = ""
            var arrGraphdata: NSArray!
            
            
            if (jsonResult["this"] is String){
                success = jsonResult["this"] as! String
                
                if (jsonResult["with"] is NSArray){
                    arrGraphdata = jsonResult["with"] as! NSArray
                    
                    for i in 0..<arrGraphdata.count {
                        let dict = arrGraphdata[i] as! NSDictionary
                        
                        var genericObj = Graph()
                        var date = ""
                        var temperature: Double!
                        var xvalue: Double!
                        var yvalue: Double!
                        var zvalue: Double!
                        var dateobj = NSDate()
                        
                        if (dict["created"] is String){
                            date = dict["created"] as! String
                        }
                        
                        var dictContent: NSDictionary!
                        
                        if (dict["content"] is NSDictionary){
                            dictContent = dict["content"] as! NSDictionary
                        }
                        
                        if (dictContent["temperature_data"] is NSNumber){
                            temperature = dictContent["temperature_data"] as! Double
                        }
                        
                        var dictAccData: NSDictionary!
                        if (dictContent["accelerometer_data"] is NSDictionary){
                            dictAccData = dictContent["accelerometer_data"] as! NSDictionary
                        }
                        
                        if (dictAccData["x"] is NSNumber){
                            xvalue = dictAccData["x"] as! Double
                        }
                        
                        if (dictAccData["y"] is NSNumber){
                            yvalue = dictAccData["y"] as! Double
                        }
                        
                        if (dictAccData["z"] is NSNumber){
                            zvalue = dictAccData["z"] as! Double
                        }
                        
                        genericObj.temperature = temperature
                        genericObj.date = date
                        genericObj.x = xvalue
                        genericObj.y = yvalue
                        genericObj.z = zvalue
                        
                        dateobj = (convertToDate(strDate: date)! as NSDate)
                        genericObj.dateobj = dateobj as Date
                        
                        arrGeneric.append(genericObj)
                        
                        
                        if (temperature != nil){
                            arrtemperature.append(temperature)
                        }else {
                            arrtemperature.append(NSNull())
                        }
                        
                        if (xvalue != nil){
                            arrX.append(xvalue)
                        }else {
                            arrX.append(NSNull())
                        }
                        
                        if (yvalue != nil){
                            arrY.append(yvalue)
                        }else {
                            arrY.append(NSNull())
                        }
                        
                        if (zvalue != nil){
                            arrZ.append(zvalue)
                        }else {
                            arrZ.append(NSNull())
                        }
                        
                        arrDates.append(date)
                        
                        
                        
                        Graph.Instance.SetXList(list: arrX as! [Double])
                        Graph.Instance.SetYList(list: arrY as! [Double])
                        Graph.Instance.SetZList(list: arrZ as! [Double])
                        Graph.Instance.SetTemperatureList(list: arrtemperature as! [Double])
                        Graph.Instance.SetDates(list: arrDates)
                        Graph.Instance.SetGenericList(list: arrGeneric)
                    }
                    
                }
            }  
        }
        catch{
            jsonResult = NSDictionary()
        }
        didFinishParsingfunc(jsonResult)
        return 0;
    }
    
    func convertToDate(strDate: String) -> NSDate?{
        
        let endIndex = strDate.index(strDate.endIndex, offsetBy: -5)
        var truncated = strDate.substring(to: endIndex)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date( from: truncated ) as NSDate?
        return date
    }
}
