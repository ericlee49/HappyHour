//
//  Time.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-16.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import Foundation


class Time {
    
    var hour: Int
    var minute: Int
    var isAM: Bool
    
    init(hour: Int, minute: Int, isAM: Bool) {
        self.hour = hour
        self.minute = minute
        self.isAM = isAM
    }
    
    func dateToTime(date:NSDate) -> Time {
        let twentyFourhour = date.hour()
        let minute = date.minute()
 
        switch (twentyFourhour < 12) {
            case true: return Time(hour: twentyFourhour, minute: minute, isAM: true)
            case false: return Time(hour: twentyFourhour - 12, minute: minute, isAM: false)
        }
        
    }
    
    func timeToString(time:Time) -> NSString {
        let hour = time.hour
        let minute = time.minute
        if time.isAM {
            if minute < 10 {
                return "\(hour):0\(minute) AM"
            } else {
                return "\(hour):\(minute) AM"
            }
        } else {
            if minute < 10 {
                return "\(hour):0\(minute) PM"
            } else {
                return "\(hour):\(minute) PM"
            }
        }
    }
    
    func toString() -> NSString {
        if self.isAM {
            if self.minute < 10 {
                return "\(self.hour):0\(self.minute) AM"
            } else {
                return "\(self.hour):\(self.minute) AM"
            }
            
        } else {
            if self.minute < 10 {
                return "\(self.hour):0\(self.minute) PM"
            } else {
                return "\(self.hour):\(self.minute) PM"
            }
        }
    }
    
    func get24HrHourValue() -> Int {
        if !(self.isAM) {
            return self.hour + 12
        } else {
            return self.hour
        }
    }
    
    func getTimeValueInMinutes() -> Int {
        if !(self.isAM) && self.hour == 12 {
            return (((self.hour) * 60) + self.minute)
        } else if !(self.isAM) {
            return (((self.hour + 12) * 60) + self.minute)
        } else {
            return (((self.hour) * 60) + self.minute)
        }
    }
    
    
    
}