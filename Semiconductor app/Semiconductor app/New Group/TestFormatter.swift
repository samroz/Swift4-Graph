//
//  TestFormatter.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Charts

@objc(BarChartFormatter)
class ChartFormatter:NSObject,IAxisValueFormatter{
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (value < 0) {
            return ""
        }
        
        if(Int(value) >= months.count){
            return ""
        }
        return months[Int(value)]
    }
}
