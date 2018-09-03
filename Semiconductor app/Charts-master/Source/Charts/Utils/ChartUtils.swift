//
//  Utils.swift
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

open class ChartUtils
{
    fileprivate static var _defaultValueFormatter: IValueFormatter = ChartUtils.generateDefaultValueFormatter()
    
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(M_PI / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / M_PI)
        internal static let DEG2RAD = M_PI / 180.0
        internal static let RAD2DEG = 180.0 / M_PI
    }
    
    internal class func roundToNextSignificant(number: Double) -> Double
    {
        if number.isInfinite || number.isNaN || number == 0
        {
            return number
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number))
        let pw = 1 - Int(d)
        let magnitude = pow(Double(10.0), Double(pw))
        let shifted = round(number * magnitude)
        return shifted / magnitude
    }
    
    internal class func decimals(_ number: Double) -> Int
    {
        if number.isNaN || number.isInfinite || number == 0.0
        {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        
        if i.isInfinite || i.isNaN
        {
            return 0
        }
        
        return Int(ceil(-log10(i))) + 2
    }
    
    internal class func nextUp(_ number: Double) -> Double
    {
        if number.isInfinite || number.isNaN
        {
            return number
        }
        else
        {
            return number + DBL_EPSILON
        }
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        )
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?)
    {
        var point = point
        
        if align == .center
        {
            point.x -= text.size(attributes: attributes).width / 2.0
        }
        else if align == .right
        {
            point.x -= text.size(attributes: attributes).width
        }
        
        NSUIGraphicsPushContext(context)
        
        //check here. this code creates standard figures with spaces in thousands and units
        
        var name: String = text
        var lastChars: String = ""

        if (text.characters.last == "g" && (!text.contains("feeding") && (!text.contains("Relativ utfôring")) && (!text.contains("Utfôret + ny prog")) && (!text.contains("Vekt + ny prog")))){
            print("Axis property== \(text)")
            var endIndex = name.index(name.endIndex, offsetBy: 0)
            if (name.contains("kg")){
                lastChars = " kg"
                endIndex = name.index(name.endIndex, offsetBy: -3)
            }else {
                lastChars = " g"
                endIndex = name.index(name.endIndex, offsetBy: -1)
            }
            let truncated = name.substring(to: endIndex)
            name = truncated
            let value = Double(name)

            let leftformatter = NumberFormatter()
            leftformatter.groupingSeparator = " "
            leftformatter.numberStyle = .decimal

            if (value != nil){
                let number = NSNumber(value:value!)

                var str:String = leftformatter.string(from: number)!
                str = str + lastChars
                print("string===== \(str)")

                (str as NSString).draw(at: point, withAttributes: attributes)
            }

        //check here. this adds % with y axis value for Relative feeding

        }else if (text.characters.last == "0" && !(text.contains("."))){
            lastChars = "%"
            var str:String = text
            str = str + lastChars
//            (str as NSString).draw(at: point, withAttributes: attributes)
            (text as NSString).draw(at: point, withAttributes: attributes)
        }
            
        //check here, this adds 0 before fraction in FCR barchart graph
        else if (text.hasPrefix(".")){
            var str:String = text
            str = "0" + str
            var axispoint = point
            //check here. to align left axis values in FCR
            axispoint.x = 35
            (str as NSString).draw(at: axispoint, withAttributes: attributes)
        }
        else {
            print("axis values == \(text)")
            (text as NSString).draw(at: point, withAttributes: attributes)
        }
//        (text as NSString).draw(at: point, withAttributes: attributes)
//        print(text as String)
        NSUIGraphicsPopContext()
    }
    
    open class func drawText(context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, anchor: CGPoint, angleRadians: CGFloat)
    {
        var drawOffset = CGPoint()
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            let size = text.size(attributes: attributes)
            
            // Move the text drawing rect in a way that it always rotates around its center
            drawOffset.x = -size.width * 0.5
            drawOffset.y = -size.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = sizeOfRotatedRectangle(size, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
            
            context.restoreGState()
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                let size = text.size(attributes: attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, knownTextSize: CGSize, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        var rect = CGRect(origin: CGPoint(), size: knownTextSize)
        
        NSUIGraphicsPushContext(context)
        
        if angleRadians != 0.0
        {
            // Move the text drawing rect in a way that it always rotates around its center
            rect.origin.x = -knownTextSize.width * 0.5
            rect.origin.y = -knownTextSize.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = sizeOfRotatedRectangle(knownTextSize, radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            context.saveGState()
            context.translateBy(x: translate.x, y: translate.y)
            context.rotate(by: angleRadians)
            
            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            context.restoreGState()
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                rect.origin.x = -knownTextSize.width * anchor.x
                rect.origin.y = -knownTextSize.height * anchor.y
            }
            
            rect.origin.x += point.x
            rect.origin.y += point.y
            
            rect.origin.x = rect.origin.x

            (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        
        NSUIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, point: CGPoint, attributes: [String : AnyObject]?, constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        let rect = text.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        drawMultilineText(context: context, text: text, knownTextSize: rect.size, point: point, attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    /// - returns: An angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal class func normalizedAngleFromAngle(_ angle: CGFloat) -> CGFloat
    {
        var angle = angle
        
        while (angle < 0.0)
        {
            angle += 360.0
        }
        
        return angle.truncatingRemainder(dividingBy: 360.0)
    }
    
    fileprivate class func generateDefaultValueFormatter() -> IValueFormatter
    {
        let formatter = DefaultValueFormatter(decimals: 1)
        return formatter
    }
    
    /// - returns: The default value formatter used for all chart components that needs a default
    open class func defaultValueFormatter() -> IValueFormatter
    {
        return _defaultValueFormatter
    }
    
    internal class func sizeOfRotatedRectangle(_ rectangleSize: CGSize, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(_ rectangleSize: CGSize, radians: CGFloat) -> CGSize
    {
        return sizeOfRotatedRectangle(rectangleWidth: rectangleSize.width, rectangleHeight: rectangleSize.height, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, degrees: CGFloat) -> CGSize
    {
        let radians = degrees * Math.FDEG2RAD
        return sizeOfRotatedRectangle(rectangleWidth: rectangleWidth, rectangleHeight: rectangleHeight, radians: radians)
    }
    
    internal class func sizeOfRotatedRectangle(rectangleWidth: CGFloat, rectangleHeight: CGFloat, radians: CGFloat) -> CGSize
    {
        return CGSize(
            width: abs(rectangleWidth * cos(radians)) + abs(rectangleHeight * sin(radians)),
            height: abs(rectangleWidth * sin(radians)) + abs(rectangleHeight * cos(radians))
        )
    }
    
    /// MARK: - Bridging functions
    
    internal class func bridgedObjCGetNSUIColorArray (swift array: [NSUIColor?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if val == nil
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val!)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetNSUIColorArray (objc array: [NSObject]) -> [NSUIColor?]
    {
        var newArray = [NSUIColor?]()
        for object in array
        {
            newArray.append(object as? NSUIColor)
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (swift array: [String?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if val == nil
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val! as NSObject)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (objc array: [NSObject]) -> [String?]
    {
        var newArray = [String?]()
        for object in array
        {
            newArray.append(object as? String)
        }
        return newArray
    }
}
