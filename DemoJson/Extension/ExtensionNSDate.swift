//
//  ExtensionNSDate.swift
//  DemoSwift
//
//  Created by mac-0007 on 04/10/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation



//MARK:-
//MARK:- Singleton dateFormatter() and calendar()

private struct privateStatic
{
    static var dateFormatter: DateFormatter? = nil
    static var onceTokenDF: Int = 0
    
    static var calendar: Calendar? = nil
    static var onceTokenCL: Int = 0
}

/*
func dateFormatter() -> DateFormatter
{
    
    dispatch_once(&privateStatic.onceTokenDF) {
        privateStatic.dateFormatter = DateFormatter();
    }
    
    //    privateStatic.dateFormatter!.timeZone = NSTimeZone(abbreviation: "UTC")
    //    privateStatic.dateFormatter!.timeZone = NSTimeZone.localTimeZone()
    privateStatic.dateFormatter!.timeZone = TimeZone(secondsFromGMT: 0)
    privateStatic.dateFormatter!.locale = Locale.current
    return privateStatic.dateFormatter!
}*/

/*
func calendar() -> Calendar
{
    dispatch_once(&privateStatic.onceTokenCL) {
        privateStatic.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    //    privateStatic.calendar!.timeZone = NSTimeZone(abbreviation: "UTC")
    //    privateStatic.calendar!.timeZone = NSTimeZone.localTimeZone()
    privateStatic.calendar!.timeZone = TimeZone(secondsFromGMT: 0)!
    privateStatic.calendar!.locale = Locale.current
    return privateStatic.calendar!
}*/

func today() -> Date {
    return Date()
}


//MARK:-
//MARK:- ExtensionNSDate

extension Date
{
    
    static func currentTimestamp() -> NSNumber {
        return NSNumber(value: Date().timeIntervalSince1970 as Double)
    }
    
    //MARK:-
    static func start(ofDate date:Date) -> Date?
    {
        let stringDate = Date.string(fromDate: date, dateFormat: "yyyy-MM-dd") + " 00:00:00"
        let startDate = Date.date(fromString: stringDate, dateFormat: "yyyy-MM-dd HH:mm:ss")
        
        return startDate
    }
    
    static func end(ofDate date:Date) -> Date?
    {
        let stringDate = Date.string(fromDate: date, dateFormat: "yyyy-MM-dd") + " 23:59:59"
        let endDate = Date.date(fromString: stringDate, dateFormat: "yyyy-MM-dd HH:mm:ss")
        
        return endDate
    }
    
    static func startTimestamp(ofDate date:Date) -> Double {
        return (Date.start(ofDate: date)?.timeIntervalSince1970)!
    }
    
    static func endTimestamp(ofDate date:Date) -> Double {
        return (Date.end(ofDate: date)?.timeIntervalSince1970)!
    }
    
    
    
    
    
    //MARK:-
    static func date(fromString str:String, dateFormat:String) -> Date? {
        DateFormatterManager.shared().dateFormat = dateFormat
        return DateFormatterManager.shared().date(from: str)
    }
    
    static func string(fromDate dt:Date, dateFormat:String) -> String {
        DateFormatterManager.shared().dateFormat = dateFormat
        return DateFormatterManager.shared().string(from: dt)
    }
    
    
    //MARK:-
    func dateByAdd(days dy:Int) -> Date
    {
        var components = DateComponents()
        components.day = dy
        return CalendarManager.shared().date(byAdding: components, to: self)!
    }
    
    func dateByAdd(weeks wk:Int) -> Date
    {
        var components = DateComponents()
        components.day = 7 * wk
        return CalendarManager.shared().date(byAdding: components, to: self)!
    }
    
    func dateByAdd(months mn:Int) -> Date
    {
        var components = DateComponents()
        components.month = mn
        return CalendarManager.shared().date(byAdding: components, to: self)!
    }
    
    func dateByAdd(years yr:Int) -> Date
    {
        var components = DateComponents()
        components.year = yr
        return CalendarManager.shared().date(byAdding: components, to: self)!
    }
    
    
    //MARK:-
    func firstDayOfMonth() -> Date
    {
        let currentComponents = CalendarManager.shared().dateComponents([.year, .month, .day, .weekday, .weekOfMonth], from: self)
        var newComponents = DateComponents()
        
        newComponents.year          = currentComponents.year
        newComponents.month         = currentComponents.month
        newComponents.weekOfMonth   = 1
        newComponents.day           = 1
        
        return CalendarManager.shared().date(from: newComponents)!
    }
    
    func lastDayOfMonth() -> Date
    {
        let currentComponents = CalendarManager.shared().dateComponents([.year, .month, .day, .weekday, .weekOfMonth], from: self)
        var newComponents = DateComponents()
        
        newComponents.year          = currentComponents.year
        newComponents.month         = currentComponents.month! + 1
        newComponents.day           = 0
        
        return CalendarManager.shared().date(from: newComponents)!
    }
    
    
    
    
    //MARK:-
    func isSameDay(date dt:Date) -> Bool
    {
        let componentsA = CalendarManager.shared().dateComponents([.year, .month, .day], from: self)
        let componentsB = CalendarManager.shared().dateComponents([.year, .month, .day], from: dt)
        
        return (componentsA.year == componentsB.year && componentsA.month == componentsB.month && componentsA.day == componentsB.day)
    }
    
    func isSameWeek(date dt:Date) -> Bool
    {
        let componentsA = CalendarManager.shared().dateComponents([.year, .weekOfYear], from: self)
        let componentsB = CalendarManager.shared().dateComponents([.year, .weekOfYear], from: dt)
        
        return (componentsA.year == componentsB.year && componentsA.weekOfYear == componentsB.weekOfYear)
    }
    
    func isSameMonth(date dt:Date) -> Bool
    {
        let componentsA = CalendarManager.shared().dateComponents([.year, .month], from: self)
        let componentsB = CalendarManager.shared().dateComponents([.year, .month], from: dt)
        
        return (componentsA.year == componentsB.year && componentsA.month == componentsB.month)
    }
    
    func isSameYear(date dt:Date) -> Bool
    {
        let componentsA = CalendarManager.shared().dateComponents([.year], from: self)
        let componentsB = CalendarManager.shared().dateComponents([.year], from: dt)
        
        return (componentsA.year == componentsB.year)
    }
    
    
    
    
    //MARK:-
    func isBefore(date dt:Date) -> Bool
    {
        if (self.compare(dt) == .orderedAscending) {
            return true
        }
        
        return false
    }
    
    func isEqualOrBefore(date dt:Date) -> Bool
    {
        if (self.isBefore(date: dt) || self.isSameDay(date: dt)) {
            return true
        }
        
        return false
    }
    
    func isAfter(date dt:Date) -> Bool
    {
        if (self.compare(dt) == .orderedDescending) {
            return true
        }
        
        return false
    }
    
    func isEqualOrAfter(date dt:Date) -> Bool
    {
        if (self.isAfter(date: dt) || self.isSameDay(date: dt)) {
            return true
        }
        
        return false
    }
    
    
}



class DateFormatterManager {
    
    private init() {}
    
    private static var dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    class func shared() -> DateFormatter {
        return self.dateFormatter
    }
}

class CalendarManager {
    
    private init() {}
    
    private static var calendar : Calendar = {
        var calendar = Calendar(identifier: Calendar.Identifier.indian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale.current
        return calendar
    }()
    
    class func shared() -> Calendar {
        return self.calendar
    }
}



