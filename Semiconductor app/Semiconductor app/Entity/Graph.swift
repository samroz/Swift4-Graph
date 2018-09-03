//
//  Graph.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

private let _UserSharedInstance = Graph()

class Graph: NSObject {
    class var Instance: Graph {
        return _UserSharedInstance
    }
    
    
    var date = ""
    var temperature: Double = 0
    var x: Double! = 0
    var y: Double! = 0
    var z: Double! = 0
    var dateobj = Date()

//
//
//    var weightout:Double!
//    var weightoutactual:Double!
//    var weightoutforecastactual:Double!
//
//    var feedactual: Double!
//    var feedqforecast: Double!
//    var feedforecastactual: Double!
//
//
    
    var arrGeneric = [Graph]()
    
    var arrDates = [String]()
    
    var arrtemperature = [Any]()
    var arrX = [Any]()
    var arrY = [Any]()
    var arrZ = [Any]()
    
    func GetGenericList() -> [Graph]{
        return arrGeneric
    }
    
    func SetGenericList(list: [Graph]){
        arrGeneric = list
    }
    
    func GetTemperatureList() -> [Any]{
        return arrtemperature
    }
    
    func SetTemperatureList(list: [Any]){
        arrtemperature = list
    }
    
    func GetXList() -> [Any]{
        return arrX
    }
    func SetXList(list: [Any]){
        arrX = list
    }
    
    func GetYList() -> [Any]{
        return arrY
    }
    func SetYList(list: [Any]){
        arrY = list
    }
    
    func GetZList() -> [Any]{
        return arrZ
    }
    func SetZList(list: [Any]){
        arrZ = list
    }

    func GetDates() -> [String]{
        return arrDates
    }
    func SetDates(list: [String]){
        arrDates = list
    }

    
}
