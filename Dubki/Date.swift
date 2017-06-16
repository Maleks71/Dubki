//
//  Date.swift
//  Dubki
//
//  Created by Игорь Моренко on 08.11.15.
//  Copyright © 2015-2017 LionSoft, LLC. All rights reserved.
//

import Foundation

// Function for working with date

extension String {
    
    func date(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
}

extension Date {

    func string(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingMinute(_ minute: Int) -> Date? {
        //return self.dateByAddingTimeInterval(Double(minute * 60))
        //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let calendar = Calendar.current
        if #available(iOS 8.0, *) {
            return calendar.date(byAdding: .minute, value: minute, to: self)
        } else {
            // Fallback on earlier versions
            var components = DateComponents()
            components.minute = minute
            return calendar.date(byAdding: components, to: self)
        }
    }
    
    func dateByAddingDay(_ day: Int) -> Date? {
        //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let calendar = Calendar.current
        if #available(iOS 8.0, *) {
            return calendar.date(byAdding: .day, value: day, to: self)
        } else {
            // Fallback on earlier versions
            var components = DateComponents()
            components.day = day
            return calendar.date(byAdding: components, to: self)
        }
    }
    
    /*
    The number of the weekday unit for the receiver.
    Weekday units are the numbers 1 through n, where n is the number of days in the week. For example, in the Gregorian calendar, n is 7 and Sunday is represented by 1.
    */
    var weekday: Int {
        get {
            //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = Calendar.current
            return calendar.component(.weekday, from: self)
//            let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekday, from: self)
//            return components.weekday!
        }
    }
    
    func weekdayName() -> String {
        return string("EEE")
        //let weekdayName = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
        //return weekdayName[weekday - 1]
    }
    
    func dateByWithTime(_ time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let dateString = dateFormatter.string(from: self) + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.date(from: dateString)
    }
    
    // get interval from two date (of date on further date and pass the earlier date as parameter, this would give the time difference in seconds)
    //let interval = date1.timeIntervalSinceDate(date2)
    
    // get component from date
    //let date = Date()
    //let calendar = Calendar.currentCalendar()
    //let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
    //let hour = components.hour
    //let minutes = components.minute
}
