//
//  Establishment.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-05.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import UIKit
import Firebase

class Establishment {
    
    // MARK: Properties
    
    var confirmations: Int
    var name: String
    var description: String
    var startTime: Time
    var endTime: Time
    var openStatus = false
    var startDay: String
    var endDay: String
    var photo: UIImage?
    var databaseID: String?
    var photoURL: String?
    
    
    
    
    
    
    let weekDays = ["Sunday":1, "Monday":2, "Tuesday":3, "Wednesday":4, "Thursday":5, "Friday":6, "Saturday":7, "All Week":0]
    
    
    
    // MARK: Initialization
    
    init?(name: String, description: String, confirmations: Int, startTime: Time, endTime: Time, startDay: String, endDay: String) {
        self.name = name
        self.description = description
        self.confirmations = confirmations
        self.startTime = startTime
        self.endTime = endTime
        self.startDay = startDay
        self.endDay = endDay
        
        
        if name.isEmpty {
            return nil
        }
        
        isOpen()

    }
    
    init?(name: String, description: String, confirmations: Int, startTime: Time, endTime: Time, startDay: String, endDay: String, photo: UIImage) {
        self.name = name
        self.description = description
        self.confirmations = confirmations
        self.startTime = startTime
        self.endTime = endTime
        self.startDay = startDay
        self.endDay = endDay
        self.photo = photo
        
        
        if name.isEmpty {
            return nil
        }
        
        isOpen()
        
    }

    
    init?(name: String, description: String, confirmations: Int, startTime: Time, endTime: Time, startDay: String, endDay: String, photoURL: String) {
        self.name = name
        self.description = description
        self.confirmations = confirmations
        self.startTime = startTime
        self.endTime = endTime
        self.startDay = startDay
        self.endDay = endDay
        self.photoURL = photoURL
        
        if name.isEmpty {
            return nil
        }
        
        isOpen()
        
    }
    
    func isOpen(){
        print("time is open: \(checkIfEstablishmentIsOpenForTime())")
        print("day is open: \(checkIfEstablishmentIsOpenOnDay())")
        if (checkIfEstablishmentIsOpenForTime() && checkIfEstablishmentIsOpenOnDay()) {
            self.openStatus = true
        } else {
            self.openStatus = false
        }
    }
    
    private func checkIfEstablishmentIsOpenForTime() -> Bool {
        let currentDate = NSDate()
        let currentTime = currentDate.toTime()
        var currentTimeInMinutes = currentTime.getTimeValueInMinutes()
        /*
        print("current time: \(currentTime.toString())")
        print("current time minutes: \(currentTime.getTimeValueInMinutes())")
        print("end time:\(self.endTime.getTimeValueInMinutes())")
        print("start time:\(self.startTime.getTimeValueInMinutes())")
        */
        
        var endTimeInMinutes = self.endTime.getTimeValueInMinutes()
        let startTimeInMinutes = self.startTime.getTimeValueInMinutes()
        
        if (endTimeInMinutes < startTimeInMinutes) {
            endTimeInMinutes += 1440
            // Set a 4am cap on late night happy hours, before considered next business day
            if currentTimeInMinutes >= 0 && currentTimeInMinutes <= 240 {
                currentTimeInMinutes += 1440
            }
        }
        
        if ((currentTimeInMinutes <= endTimeInMinutes) && (currentTimeInMinutes >= startTimeInMinutes)){
            print("current time: \(currentTime.toString())")

            return true
            
        } else {
            
            return false
            /*
            print("current time: \(currentTime.toString())")
            print("Establishment happy hour over")
            print("current time in 24: \(currentTime.get24HrHourValue())")
            print("establishment end time in 24: \(self.endTime.get24HrHourValue())")
             */
            
        }
    }
    
    private func checkIfEstablishmentIsOpenOnDay() -> Bool {
        let currentDate = NSDate()
        let currentDayOfTheWeek = currentDate.dayOfWeek()!
        print("Todays day is : \(currentDate.dayOfWeek()!)")
        
        let valueOfStartDay = weekDays[self.startDay]!
        var valueOfEndDay = weekDays[self.endDay]!
        // checking case for Sunday end day, since it has a value of 1
        if (valueOfEndDay < valueOfStartDay) {
            valueOfEndDay += 7
        }
        print("Start Day value: \(valueOfStartDay)")
        print("End Day value: \(valueOfEndDay)")
        
        if self.startDay == "All Week" {
            return true
        // If the start date and end date are the same, and the current day is the s & e day : Summary if the happy hour is today, and today only
        }
        
        /*
        else if (valueOfStartDay == valueOfEndDay && currentDayOfTheWeek == valueOfEndDay){
            return true
        // If today is Sunday, only compare that the end day is Sunday or further, since any start Day will be > 1
        } else if currentDayOfTheWeek == 1{
            if (currentDayOfTheWeek < valueOfEndDay) {
                return true
            }
        } else if currentDayOfTheWeek <= valueOfEndDay && currentDayOfTheWeek >= valueOfStartDay {
            return true
        }
        //return false
        */
        switch currentDayOfTheWeek {
        // Today is Sunday and end day is Sunday
        case let currentDay where currentDay == 1 && valueOfEndDay == 8:
            print("case 1")
            return true
        // Today is the only day establishment is open
        case let currentDay where currentDay == valueOfEndDay && valueOfEndDay == valueOfStartDay:
            print("case 2")
            return true
        // Today falls in between start and end day
        case let currentDay where currentDay <= 7 && currentDay <= valueOfEndDay && currentDay >= valueOfStartDay:
            print("case 3")
            return true
        default:
            print("case 4")
            return false
        }
        
        
    }
    
}