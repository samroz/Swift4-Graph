//
//  GraphViewController.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
import Charts

struct entryType {
    let val: Double
    let index: Int
}

class GraphViewController: UIViewController, ChartViewDelegate {
    
    let svc = WebserviceRequests()
    
    var arrtemperature = [Double]()
    var arrX = [Double]()
    var arrY = [Double]()
    var arrZ = [Double]()
    var arrGeneric = [Graph]()

    var arrdates = [NSDate]()
    var xvals: [String]!
    
    var arrtemperatureItems = [entryType]()
    var arrXItems = [entryType]()
    var arrYItems = [entryType]()
    var arrZItems = [entryType]()
    
    var arrtemperaturesEntry = [ChartDataEntry]()
    var arrXEntry = [ChartDataEntry]()
    var arrYEntry = [ChartDataEntry]()
    var arrZEntry = [ChartDataEntry]()

    var minimumvalue: Double!
    var firstdate:NSDate!
    var noOfItems = 0
    
    var isCompanySelected = false
    
    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    @IBOutlet weak var lineChart: LineChartView!
    
    @IBOutlet weak var viewMarker: UIView!
    
    @IBOutlet weak var viewforX: UIView!
    @IBOutlet weak var viewHeader1: UIView!

    @IBOutlet weak var lblDateGraph: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblXValue: UILabel!
    @IBOutlet weak var lblYValue: UILabel!
    @IBOutlet weak var lblZValue: UILabel!

    
    @IBOutlet weak var viewtemperature: UIView!
    @IBOutlet weak var viewX: UIView!
    @IBOutlet weak var viewY: UIView!
    @IBOutlet weak var viewZ: UIView!

    
    var reachability = Reachability()
    
    //    var viewMarker = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    let strgrowthmodel = NSLocalizedString("Growth - model", comment: "")
    let strgrowthactual = NSLocalizedString("Growth - actual", comment: "")
    let strgrowthforecast = NSLocalizedString("Growth - forecast", comment: "")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        Events.PerformanceAndFeeding.ChartsClicked.log()
        
        //        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        //        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
        
        viewtemperature.layer.cornerRadius = viewtemperature.frame.size.height/2
        viewY.layer.cornerRadius = viewY.frame.size.height/2
        viewX.layer.cornerRadius = viewX.frame.size.height/2
        viewZ.layer.cornerRadius = viewZ.frame.size.height/2
        
        /*
         let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreActions(touch:)))
         tap.numberOfTapsRequired = 1
         lineChart.addGestureRecognizer(tap)
         */
        
        //        let pan = UIPanGestureRecognizer(target: self, action: #selector(showMarkeronPan(touch:)))
        //        lineChart.addGestureRecognizer(pan)
        
        viewMarker.isHidden = true
        viewMarker.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 0.5)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMarker(notification:)), name: Notification.Name("setmarker"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPoints(notification:)), name: Notification.Name("setpoints"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeYPosition(notification:)), name: Notification.Name("setyposition"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        //        self.lineChart.addGestureRecognizer(gestureRecognizer)
        
        viewtemperature.backgroundColor = UIColor(red: 220/255, green: 88/255, blue: 42/255, alpha: 1)
        viewX.backgroundColor = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
        viewY.backgroundColor = UIColor(red: 190/255, green: 214/255, blue: 47/255, alpha: 1)
        viewZ.backgroundColor = UIColor(red: 0/255, green: 154/255, blue: 218/255, alpha: 1)

            

        getGraphData()
    }
    
    func getGraphData() {
        var isconnectionfound = false
        
        switch self.reachability?.connection {
        case .cellular?:
            print("Network available via Cellular Data.")
            isconnectionfound = true
            break
        case .wifi?:
            print("Network available via WiFi.")
            isconnectionfound = true
            break
        case .none:
            print("Network is not available.")
            isconnectionfound = false
            break
        case .some(.none):
            print("Network is not available.")
            isconnectionfound = false
        }
        
        if (isconnectionfound){
            print("Connection is found")
            
            activityIndicator.startAnimating()
            self.svc.getGraphData(didFinishParsing: Finished)
            
        }else {
            let alert = UIAlertController(title: "", message:
                NSLocalizedString("No internet connection found", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = true
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("Landscape")
            
            viewforX.frame.size.height = 50
            
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
            
            viewforX.frame.size.height = 63
        }
    }
    
    
    
    @objc func rotated() {
        
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("Landscape")
            
            viewforX.frame.size.height = 50

        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
            
            viewforX.frame.size.height = 63
        }
    }
    
    func setdateformat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date as Date)
        return localDate
    }
    

    @objc func changeYPosition(notification: NSNotification) {
        
        let yvalue = notification.userInfo?["yvalue"] as? CGFloat
        self.viewMarker.frame.origin.y = yvalue! - 40
        
        //        if (lineChart.frame.size.height - yvalue! < 96){
        //            self.viewMarker.frame.origin.y = lineChart.frame.size.height - 96
        //        }
    }
    
    @objc func showPoints(notification: NSNotification) {
        let xvalue = notification.userInfo?["xvalue"] as? CGFloat
        let yvalue = notification.userInfo?["yvalue"] as? CGFloat
        
        viewMarker.translatesAutoresizingMaskIntoConstraints = false
        //        DispatchQueue.main.async {
        
        if ((lineChart.frame.size.width + 30) - xvalue! < 210){
            self.viewMarker.frame.origin.x = (257 + 40) - 185
            //            self.viewMarker.frame.origin.y = yvalue!
        }else {
            self.viewMarker.frame.origin.x = xvalue!
            //            self.viewMarker.frame.origin.y = yvalue!
        }
        
        if (lineChart.frame.size.height - yvalue! < 96){
            //            self.viewMarker.frame.origin.y = lineChart.frame.size.height - 96
        }
        
        //        if (lineChart.frame.origin.y - yvalue! < 96){
        //            self.viewMarker.frame.origin.y = 30
        //        }
        
        
        
    }
    
    @objc func showMarker(notification: NSNotification) {
        var count = 0
        
        let xvalue = notification.userInfo?["xvalue"] as? Double
        
        var tempVar = String(format: "%g", xvalue!)
        
        let index = Int(tempVar)
        //        if let xvalue = notification.userInfo?["xvalue"] as? Double {
        //            print("x value of marker : \(xvalue)")
        //        }
        
        if let yvalue = notification.userInfo?["yvalue"] as? Double {
        }
        
        
        lblTemperature.translatesAutoresizingMaskIntoConstraints = true
        lblXValue.translatesAutoresizingMaskIntoConstraints = true
        lblYValue.translatesAutoresizingMaskIntoConstraints = true
        lblZValue.translatesAutoresizingMaskIntoConstraints = true

        
        if (arrXEntry.count > 0){
            for i in 0..<arrXEntry.count{
                let e = arrXEntry[i]
                let tempVar2 = String(format: "%g", e.x)
                
                let currentx = Int(tempVar2)
                if (currentx == index){
                    print("match found in actual")
                    let stryval = String(e.y)
                    
                    count = count + 1
                    //                let calendar: Calendar = Calendar.current
                    //                let month = Calendar.current.component(.month, from: date as Date)
                    //
                    //                let strmonth = months[month] as String
                    let str = String(format: "%g", e.x)
                    let index = Int(str)
//                    let date = arrdates[index!]
                    
                    //                    let date = arrdates[index!]
                    //                    lblDateGraph.text = setdateformat(date: date as Date)
                    
                    let val = xvals[index!]
                    lblDateGraph.text = val
                    
//                    lblDateGraph.text = setdateformat(date: date as Date)
                    lblXValue.text = "Acc - X: " + stryval + " g"
                    lblXValue.isHidden = false
                    lblXValue.frame.origin.y = 50
                    lblYValue.frame.origin.y = 72
                    
                    viewX.frame.origin.y = 50 + 3
                    viewY.frame.origin.y = 72 + 3
                    
                    viewX.isHidden = false
                    
                    break
                }else {
                    lblYValue.frame.origin.y = lblXValue.frame.origin.y
                    viewY.frame.origin.y = lblYValue.frame.origin.y + 3
                    lblXValue.isHidden = true
                    viewX.isHidden = true
                }
            }
        }else {
            viewY.frame.origin.y = lblYValue.frame.origin.y + 3
            lblYValue.frame.origin.y = lblXValue.frame.origin.y
            lblXValue.isHidden = true
            viewX.isHidden = true
        }
        
        
        if (arrtemperaturesEntry.count > 0){
            for i in 0..<arrtemperaturesEntry.count{
                let e = arrtemperaturesEntry[i]
                let tempVar2 = String(format: "%g", e.x)
                let currentx = Int(tempVar2)
                if (currentx == index){
                    print("match found in weightout")
                    count = count + 1
                    //                if (i < xvals.count){
                    //                    lblDateGraph.text = xvals[i]
                    //                }
                    
                    let str = String(format: "%g", e.x)
                    let index = Int(str)
                    
//                    let date = arrdates[index!]
//                    lblDateGraph.text = setdateformat(date: date as Date)
                    
                    let val = xvals[index!]
                    lblDateGraph.text = val
                    
                    let stryval = String(format: "%.2f", e.y)
                    lblTemperature.text = "Temperature: " + stryval + " g"
                    lblXValue.frame.origin.y = 50
                    viewX.frame.origin.y = 50 + 3
                    lblTemperature.isHidden = false
                    viewtemperature.isHidden = false
                    break
                }else {
                    lblXValue.frame.origin.y = lblTemperature.frame.origin.y
                    viewX.frame.origin.y = lblXValue.frame.origin.y
                    
                    lblTemperature.isHidden = true
                    viewtemperature.isHidden = true
                }
            }
        }else {

            lblXValue.frame.origin.y = lblTemperature.frame.origin.y
            lblTemperature.isHidden = true
            viewtemperature.isHidden = true
            
        }
        
        if (arrYEntry.count > 0){
            for i in 0..<arrYEntry.count{
                let e = arrYEntry[i]
                let tempVar2 = String(format: "%g", e.x)
                let currentx = Int(tempVar2)
                if (currentx == index){
                    print("match found in forecast")
                    //                lblDateGraph.text = xvals[i]
                    count = count + 1
                    let str = String(format: "%g", e.x)
                    let index = Int(str)
//                    let date = arrdates[index!]
//
//                    lblDateGraph.text = setdateformat(date: date as Date)
                    
                    let val = xvals[index!]
                    lblDateGraph.text = val
                    
                    let stryval = String(format: "%.2f", e.y)
                    lblYValue.text = "Acc - Y: " + stryval + " g"
                    
                    lblYValue.isHidden = false
                    viewY.isHidden = false
                    
                    lblZValue.frame.origin.y = lblYValue.frame.origin.y + lblYValue.frame.size.height + 1
                    viewZ.frame.origin.y = lblZValue.frame.origin.y + 3
                    
                    break
                }else {
                    
                    lblZValue.frame.origin.y = lblYValue.frame.origin.y
                    viewZ.frame.origin.y = lblZValue.frame.origin.y + 3
                    
                    lblYValue.isHidden = true
                    viewY.isHidden = true
                }
            }
        }else {
            lblZValue.frame.origin.y = lblYValue.frame.origin.y
            viewZ.frame.origin.y = lblZValue.frame.origin.y + 3
            lblYValue.isHidden = true
            viewY.isHidden = true
        }
        
        
        if (arrZEntry.count > 0){
            for i in 0..<arrZEntry.count{
                let e = arrZEntry[i]
                let tempVar2 = String(format: "%g", e.x)
                let currentx = Int(tempVar2)
                if (currentx == index){
                    print("match found in forecast")
                    //                lblDateGraph.text = xvals[i]
                    count = count + 1
                    let str = String(format: "%g", e.x)
                    let index = Int(str)
//                    let date = arrdates[index!]
//
//                    lblDateGraph.text = setdateformat(date: date as Date)
                    
                    let val = xvals[index!]
                    lblDateGraph.text = val
                    
                    let stryval = String(format: "%.2f", e.y)
                    lblZValue.text = "Acc - Z: " + stryval + " g"
                    
                    lblZValue.isHidden = false
                    viewZ.isHidden = false
                    //                lblYValue.frame.origin.y = 72
                    break
                }else {
                    lblZValue.isHidden = true
                    viewZ.isHidden = true
                }
            }
        }else {
            lblZValue.isHidden = true
            viewZ.isHidden = true
        }
        
        lblTemperature.frame.size.width = 177
        lblXValue.frame.size.width = 177
        lblYValue.frame.size.width = 177
        lblZValue.frame.size.width = 177
        
        viewMarker.isHidden = false
        viewMarker.frame.size.height = CGFloat((count * 29)) + 20
        
    }
    
    func Finished(inp: NSDictionary) -> Int{
        DispatchQueue.main.async {
            
            self.activityIndicator.stopAnimating()
            
            self.arrGeneric = Graph.Instance.GetGenericList()
        
            if (self.arrGeneric.count > 0){
                self.arrtemperature = Graph.Instance.GetTemperatureList() as! [Double]
                self.arrX = Graph.Instance.GetXList() as! [Double]
                self.arrY = Graph.Instance.GetYList() as! [Double]
                self.arrZ = Graph.Instance.GetZList() as! [Double]
                

                let arrdatesstr = Graph.Instance.GetDates()
                for strdate in arrdatesstr {
                    
                    let endIndex = strdate.index(strdate.endIndex, offsetBy: -5)
                    var truncated = strdate.substring(to: endIndex)
                    
                    
    //                truncated = String(truncated.dropFirst(11))

                    let date = self.convertToDate(strDate: truncated)
                    self.arrdates.append(date!)
                }
                
                
                self.arrGeneric.sort(by: { $0.dateobj.compare($1.dateobj) == .orderedAscending })

    //            self.arrdates = self.arrdates.sorted(by: { $0.compare($1 as Date) == .orderedAscending })

                self.arrdates.removeAll()
                self.arrtemperature.removeAll()
                self.arrX.removeAll()
                self.arrY.removeAll()
                self.arrZ.removeAll()
                
                for i in 0..<self.arrGeneric.count {
                    let obj = self.arrGeneric[i]
                    self.arrdates.append(obj.dateobj as NSDate)
                }
                
                for i in 0..<self.arrGeneric.count {
                    let obj = self.arrGeneric[i]
                    self.arrtemperature.append(obj.temperature)
                }
                
                for i in 0..<self.arrGeneric.count {
                    let obj = self.arrGeneric[i]
                    self.arrX.append(obj.x)
                }
                
                for i in 0..<self.arrGeneric.count {
                    let obj = self.arrGeneric[i]
                    self.arrY.append(obj.y)
                }
                
                for i in 0..<self.arrGeneric.count {
                    let obj = self.arrGeneric[i]
                    self.arrZ.append(obj.z)
                }
                
                print(self.arrdates.count)
                
                let firstandlast = self.firstDate(dates: self.arrdates)
                self.firstdate = firstandlast.earliest
                
                var max1 = 0.0

                for i in 0..<self.arrdates.count {
                    let date = self.arrdates[i]
                    //                let value = self.arrweightout[i]
                    
                    var value: Double!
                    
                    if (i < self.arrtemperature.count){
                        
                        if (self.arrtemperature[i] is NSNumber){
                            value = self.arrtemperature[i] as! Double
                            
                            let i = self.daysBetweenDate(startDate: self.firstdate, endDate: date)
    //                        if(value > 0){
                                let x = entryType(val: value, index: i)
                                self.arrtemperatureItems.append(x)
    //                        }
                        }
                    }
                }
                
                for i in 0..<self.arrdates.count {
                    let date = self.arrdates[i]
                    var value: Double!
                    
                    if (i < self.arrX.count){
                        if (self.arrX[i] is NSNumber){
                            value = self.arrX[i] as! Double
                            
                            let i = self.daysBetweenDate(startDate: self.firstdate, endDate: date)
    //                        if(value > 0){
                                let x = entryType(val: value, index: i)
                                self.arrXItems.append(x)
    //                        }
                        }
                    }
                }
                
                for i in 0..<self.arrdates.count {
                    let date = self.arrdates[i]
                    var value: Double!
                    
                    if (i < self.arrY.count){
                        if (self.arrY[i] is NSNumber){
                            value = self.arrY[i] as! Double
                            
                            let i = self.daysBetweenDate(startDate: self.firstdate, endDate: date)
    //                        if(value > 0){
                                let x = entryType(val: value, index: i)
                                self.arrYItems.append(x)
    //                        }
                        }
                    }
                }
                
                for i in 0..<self.arrdates.count {
                    let date = self.arrdates[i]
                    var value: Double!
                    
                    if (i < self.arrZ.count){
                        if (self.arrZ[i] is NSNumber){
                            value = self.arrZ[i] as! Double
                            
                            let i = self.daysBetweenDate(startDate: self.firstdate, endDate: date)
    //                        if(value > 0){
                                let x = entryType(val: value, index: i)
                                self.arrZItems.append(x)
    //                        }
                        }
                    }
                }
                
                //change arrays to ascending order
                
                
                
                self.addData()
            }
            
        }
        return 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setXAxis (strdate: String) {
        let endIndex = strdate.index(strdate.endIndex, offsetBy: -7)
        let truncated = strdate.substring(to: endIndex)
        
        let str = truncated.dropFirst(6)
        let dbldate = Double(str)
        let finaldate = Date(timeIntervalSince1970: (dbldate! / 1000.0))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let s = dateFormatter.string(from: finaldate)
        xvals.append(s)
        
    }
    
    func convertToDate(strDate: String) -> NSDate?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date( from: strDate ) as NSDate?
        
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm:ss"
    }
    
    
    func firstDate(dates: [NSDate?]) -> (earliest: NSDate,latest: NSDate){
        var earliest: NSDate?
        var latest: NSDate?
        for date in dates{
            if(date != nil){
                if(earliest == nil){
                    earliest = date
                }
                else {
                    earliest = date!.earlierDate(earliest! as Date) as (Date) as NSDate?
                }
                if(latest == nil){
                    latest = date
                }
                else {
                    latest = date!.laterDate(latest! as Date) as (Date) as NSDate?
                }
            }
        }
        earliest = earliest != nil ? earliest : NSDate()
        latest = latest != nil ? latest : NSDate()
        return (earliest!,latest!)
    }
    
    func daysBetweenDate(startDate: NSDate?, endDate: NSDate?) -> Int
    {
        if(startDate == nil || endDate == nil) {return 0}
        let calendar = NSCalendar.current as NSCalendar
        
        //Note: Replace the hour (time) of both dates with 00:00
//        let date1 = calendar.startOfDay(for: startDate! as Date)
//        let date2 = calendar.startOfDay(for: endDate! as Date)
        
        //Note: flag is actually day
        let flags = NSCalendar.Unit.second
        
        //Note: replace to get difference in seconds
//        let components = calendar.components(flags, from: date1, to: date2, options: [])
        let components = calendar.components(flags, from: startDate! as Date, to: endDate! as Date, options: [])

        //Note: here we need seconds
        return components.second!
//        return components.second!

    }
    
    
    func addData(){
        
        xvals = [String]()
        arrtemperaturesEntry = [ChartDataEntry]()
        arrXEntry = [ChartDataEntry]()
        arrYEntry = [ChartDataEntry]()
        arrZEntry = [ChartDataEntry]()

        
//        let x = [23, 35, 46, 54, 68, 95]
//        var y = [34, 45.6, 73.8, 105.6, 127.9, 179.5]
//        y = [179.5, 127.9, 105.6, 73.8, 45.6, 34]
//
        for item in arrtemperatureItems{
            let value = item.val//["val"] as! Double
            let e = ChartDataEntry(x: Double(item.index), y: value)
            arrtemperaturesEntry.append(e)
        }
//        for i in 0..<x.count {
////            let value = item.val//["val"] as! Double
//            let e = ChartDataEntry(x: Double(x[i]), y: y[i])
//            arrtemperaturesEntry.append(e)
//        }
        
        for item in arrXItems{
            let value = item.val //["val"] as! Double
            let e = ChartDataEntry(x: Double(item.index), y: value)
            arrXEntry.append(e)
        }
        
        for item in arrYItems{
            let value = item.val //["val"] as! Double
            let e = ChartDataEntry(x: Double(item.index), y: value)
            arrYEntry.append(e)
        }
        
        for item in arrZItems{
            let value = item.val //["val"] as! Double
            let e = ChartDataEntry(x: Double(item.index), y: value)
            arrZEntry.append(e)
        }
        
        let firstandlast = self.firstDate(dates: self.arrdates)
        noOfItems = daysBetweenDate(startDate: firstandlast.earliest, endDate: firstandlast.latest)
        var labeldate = firstdate
        for j in 0 ... noOfItems
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss"
            let s = dateFormatter.string(from: labeldate as! Date)
            
            xvals.append(String(s))
            let calender = NSCalendar.current
            let newdate = calender.date(byAdding: .second, value: 1, to: labeldate! as Date)
            labeldate = newdate! as NSDate
        }
        
        //check here
        setAxisProperties()
        setChart()
        lineChart.isHidden = false
    }
    
    
    
    func setAxisProperties(){
        DispatchQueue.main.async {
            
            self.findminimumnumber()
            
            self.lineChart.descriptionText = ""
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelPosition = XAxis.LabelPosition.bottom
            //xl.spaceBetweenLabels = 0
            xaxis.drawLabelsEnabled = true
            //xaxis.labelRotationAngle = -90
            xaxis.axisLineColor = chartLineColor
            xaxis.labelTextColor = chartLabelColor
            //            xaxis.gridColor = chartLineColor
            xaxis.gridColor = UIColor.red
            
            
            xaxis.setLabelCount(4, force: true)
            
            let xaxisFormmater = ChartFormatter()
            xaxisFormmater.months = self.xvals
            xaxis.valueFormatter = xaxisFormmater
            
            xaxis.axisMinimum = 0
            
            let leftaxis = self.lineChart.leftAxis
            if (self.minimumvalue != nil){
                leftaxis.axisMinimum = self.minimumvalue//.customAxisMin = 0
            }else {
                leftaxis.axisMinimum = 0//.customAxisMin = 0
            }
            leftaxis.axisLineColor = chartLineColor
            leftaxis.labelTextColor = chartLabelColor
            leftaxis.gridColor = chartLineColor
            
            leftaxis.drawGridLinesEnabled = false
            
            let rightaxis = self.lineChart.rightAxis
            if (self.minimumvalue != nil){
                rightaxis.axisMinimum = self.minimumvalue//.customAxisMin = 0
            }else {
                rightaxis.axisMinimum = 0//.customAxisMin = 0
            }
            rightaxis.axisLineColor = chartLineColor
            rightaxis.labelTextColor = chartLabelColor
            rightaxis.drawGridLinesEnabled = false
            
            let leftformatter = NumberFormatter()
            leftformatter.numberStyle = .decimal
            leftaxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftformatter)

            let marker = MarkerView()
            marker.chartView = self.lineChart
            self.lineChart.marker = marker
            
            self.lineChart.notifyDataSetChanged()
        }
    }
    
    func setChart(){
        
        DispatchQueue.main.async {
            
            //theme blue: gb(0, 154, 218) gray: (136, 136, 136) red: (220, 88, 42) green: (190, 214, 47)
            
            //used: red gray green theme
            
            let set1 = LineChartDataSet(values: self.arrtemperaturesEntry, label: NSLocalizedString("Temperature", comment: ""))
            set1.drawValuesEnabled = false
            
            set1.axisDependency = YAxis.AxisDependency.right

            set1.lineWidth = 2.0
            set1.circleRadius = 2.0
            set1.setColor(UIColor(red: 220/255, green: 88/255, blue: 42/255, alpha: 1))
            
            self.lineChart.notifyDataSetChanged()
            
            let set2 = LineChartDataSet(values: self.arrXEntry, label: NSLocalizedString("Accelerometer - X", comment: ""))
            //            let set2 = LineChartDataSet(values: yweightmodel, label: "test")
            set2.drawValuesEnabled = false
            set2.axisDependency = YAxis.AxisDependency.left
            set2.lineWidth = 2.0;
            set2.circleRadius = 0.0;
            set2.setColor(UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1))
            self.lineChart.notifyDataSetChanged()

            
            let set3 = LineChartDataSet(values: self.arrYEntry, label: NSLocalizedString("Accelerometer - Y", comment: ""))
            //            let set2 = LineChartDataSet(values: yweightmodel, label: "test")
            set3.drawValuesEnabled = false
            set3.axisDependency = YAxis.AxisDependency.left
            set3.lineWidth = 2.0;
            set3.circleRadius = 0.0;
            set3.setColor(UIColor(red: 190/255, green: 214/255, blue: 47/255, alpha: 1))
            self.lineChart.notifyDataSetChanged()

            
            let set4 = LineChartDataSet(values: self.arrZEntry, label: NSLocalizedString("Accelerometer - Z", comment: ""))
            set4.axisDependency = YAxis.AxisDependency.left
            set4.drawValuesEnabled = false
            set4.circleRadius = 0.0;
            self.lineChart.notifyDataSetChanged()

            set4.setColor(UIColor(red: 0/255, green: 154/255, blue: 218/255, alpha: 1))

//            set3.lineDashLengths = [6, 2]
//            set3.lineWidth = 1.5;
//            set3.circleRadius = 0.0

            self.lineChart.notifyDataSetChanged()
            let data = LineChartData(dataSets: [set4,set3,set2,set1])
            self.lineChart.data = data
            
        }
    }
    
    func findminimumnumber() {
        
        if (arrtemperature.count > 0){
            let tempnum = arrtemperature.min()
            let xnum = arrX.min()
            let ynum = arrY.min()
            let znum = arrZ.min()
            
            let arrtemp = [tempnum, xnum, ynum, znum] as! [Double]
            
            minimumvalue = arrtemp.min()
        }
        
    }
    
    
    open func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        print("clickkkk : \(entry.x)")  // change to x
    }
    
    @IBAction func backAction(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
}
