//
//  DateController.swift
//  Double
//
//  Created by James Pacheco on 1/7/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import Foundation

class DateController {
    static let SharedInstance = DateController()
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()

    static func yearFromDate() -> Int {
        let components = SharedInstance.calendar.components([.Day, .Month, .Year], fromDate: SharedInstance.date)
        return components.year
    }
    
    static func monthFromDate() -> Int {
        let components = SharedInstance.calendar.components([.Day, .Month, .Year], fromDate: SharedInstance.date)
        return components.month
    }
    
    static func dayFromDate() -> Int {
        let components = SharedInstance.calendar.components([.Day, .Month, .Year], fromDate: SharedInstance.date)
        return components.day
    }
    
    static func dateFromComponents(day: Int, month: Int, year: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = day
        components.month = month
        components.year = year
        let date = SharedInstance.calendar.dateFromComponents(components)
        return date!
    }
    
    static func stringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
    
    static func dateFromString(date: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.dateFromString(date)
    }
    
    static func dateEighteenYearsAgo() -> NSDate {
        let components = SharedInstance.calendar.components([.Day, .Month, .Year], fromDate: SharedInstance.date)
        components.year = components.year - 18
        return dateFromComponents(components.day, month: components.month, year: components.year)
    }
}