//
//  Date.swift
//  Dubki
//
//  Created by Игорь Моренко on 08.11.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
//

import Foundation

// Function for working with date

extension String {
    
    func dateByFormat(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.dateFromString(self)
    }
}

extension NSDate {

    func stringByFormat(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(self)
    }
    
    func dateByAddingMinute(minute: Int) -> NSDate? {
        //return self.dateByAddingTimeInterval(Double(minute * 60))
        //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let calendar = NSCalendar.currentCalendar()
        if #available(iOS 8.0, *) {
            return calendar.dateByAddingUnit([.Minute], value: minute, toDate: self, options: [])
        } else {
            // Fallback on earlier versions
            let components = NSDateComponents()
            components.minute = minute
            return calendar.dateByAddingComponents(components, toDate: self, options: [])
        }
    }
    
    func dateByAddingDay(day: Int) -> NSDate? {
        //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let calendar = NSCalendar.currentCalendar()
        if #available(iOS 8.0, *) {
            return calendar.dateByAddingUnit([.Day], value: day, toDate: self, options: [])
        } else {
            // Fallback on earlier versions
            let components = NSDateComponents()
            components.day = day
            return calendar.dateByAddingComponents(components, toDate: self, options: [])
        }
    }
    
    /*
    The number of the weekday unit for the receiver.
    Weekday units are the numbers 1 through n, where n is the number of days in the week. For example, in the Gregorian calendar, n is 7 and Sunday is represented by 1.
    */
    var weekday: Int {
        get {
            //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(NSCalendarUnit.Weekday, fromDate: self)
            return components.weekday
        }
    }
    
    func weekdayName() -> String {
        return stringByFormat("EEE")
        //let weekdayName = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
        //return weekdayName[weekday - 1]
    }
    
    func dateByWithTime(time: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let dateString = dateFormatter.stringFromDate(self) + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.dateFromString(dateString)
    }
    
    // get interval from two date (of date on further date and pass the earlier date as parameter, this would give the time difference in seconds)
    //let interval = date1.timeIntervalSinceDate(date2)
    
    // get component from date
    //let date = NSDate()
    //let calendar = NSCalendar.currentCalendar()
    //let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
    //let hour = components.hour
    //let minutes = components.minute
}
