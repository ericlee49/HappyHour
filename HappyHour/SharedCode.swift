//
//  SharedCode.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-14.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import Foundation
import UIKit


extension NSDate
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
    
    func toTime() -> Time {
        let twentyFourhour = self.hour()
        let minute = self.minute()
        
        /*
        switch (twentyFourhour < 12) {
        case true: return Time(hour: twentyFourhour, minute: minute, isAM: true)
        case false: return Time(hour: twentyFourhour - 12, minute: minute, isAM: false)
        }
 */
        switch (twentyFourhour) {
        case let hour where hour == 12:
            return Time(hour: hour, minute: minute, isAM: false)
        case let hour where hour == 24:
            return Time(hour: hour, minute: minute, isAM: true)
        case let hour where hour < 12:
            return Time(hour: twentyFourhour, minute: minute, isAM: true)
        default:
            return Time(hour: twentyFourhour - 12, minute: minute, isAM: false)
        }
        
    }
    
    func dayOfWeek() -> Int? {
        if let cal: NSCalendar = NSCalendar.currentCalendar(), let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) {
            return comp.weekday
        } else {
            return nil
        }
    }


}


public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)
        
        let rect = CGRectMake(0, 0, diameter, diameter)
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillEllipseInRect(ctx, rect)
        
        CGContextRestoreGState(ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
}

