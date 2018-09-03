//
//  ChartMarkerView.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

@objc(ChartMarkerView)
open class MarkerView: NSUIView, IMarker
{
    open var offset: CGPoint = CGPoint()
    
    open weak var chartView: ChartViewBase?
    
    open func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        
        let chart = self.chartView
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        if point.x + offset.x < 0.0
        {
            offset.x = -point.x
        }
        else if chart != nil && point.x + width + offset.x > chart!.bounds.size.width
        {
            offset.x = chart!.bounds.size.width - point.x - width
        }
        
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if chart != nil && point.y + height + offset.y > chart!.bounds.size.height
        {
            offset.y = chart!.bounds.size.height - point.y - height
        }
        
        return offset
    }
    
    open func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        // Do nothing here...
        
        NotificationCenter.default.post(name: Notification.Name("setmarker"), object: nil, userInfo: ["xvalue": entry.x, "yvalue": entry.y])
        
        NotificationCenter.default.post(name: Notification.Name("setfeedmarker"), object: nil, userInfo: ["xvalue": entry.x, "yvalue": entry.y])
        
        NotificationCenter.default.post(name: Notification.Name("setgrowthfeedmarker"), object: nil, userInfo: ["xvalue": entry.x, "yvalue": entry.y])
        
        NotificationCenter.default.post(name: Notification.Name("setharvestgraphmarker"), object: nil, userInfo: ["xvalue": entry.x, "yvalue": entry.y])
    }
    
    open func draw(context: CGContext, point: CGPoint)
    {
        
        NotificationCenter.default.post(name: Notification.Name("setpoints"), object: nil, userInfo: ["xvalue": point.x, "yvalue": point.y])
        
        NotificationCenter.default.post(name: Notification.Name("setfeedpoints"), object: nil, userInfo: ["xvalue": point.x, "yvalue": point.y])
        
        NotificationCenter.default.post(name: Notification.Name("setgrowthfeedpoints"), object: nil, userInfo: ["xvalue": point.x, "yvalue": point.y])
        
        NotificationCenter.default.post(name: Notification.Name("setharvestpoints"), object: nil, userInfo: ["xvalue": point.x, "yvalue": point.y])
        
        //setharvestpoints

        let offset = self.offsetForDrawing(atPoint: point)
        print("x point : \(point.x) y point: \(point.y)")
        
        context.saveGState()
        context.translateBy(x: point.x + offset.x,
                              y: point.y + offset.y)
        NSUIGraphicsPushContext(context)
        self.nsuiLayer?.render(in: context)
        NSUIGraphicsPopContext()
        context.restoreGState()
    }
    
    @objc
    open class func viewFromXib() -> MarkerView?
    {
        #if !os(OSX)
            return Bundle.main.loadNibNamed(
                String(describing: self),
                owner: nil,
                options: nil)?[0] as? MarkerView
        #else
            
            var loadedObjects = NSArray()
            let loadedObjectsPointer = AutoreleasingUnsafeMutablePointer<NSArray>(&loadedObjects)
            
            if Bundle.main.loadNibNamed(
                String(describing: self),
                owner: nil,
                topLevelObjects: loadedObjectsPointer)
            {
                return loadedObjects[0] as? MarkerView
            }
            
            return nil
        #endif
    }
    
}
