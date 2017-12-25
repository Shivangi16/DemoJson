//
//  CustomDatePicker.swift
//  DemoSwift
//
//  Created by mac-0007 on 06/10/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import UIKit

enum CustomDatePickerMode: Int {
    case week
    case month
    case year
    case monthyear
}

enum WeekFormat: Int {
    case full
    case short
}

enum MonthFormat: Int {
    case full
    case short
    case index
}

class CustomDatePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource
{
    var _date       = today()
    
    let kMinYear    = 1
    let kMaxYear    = 10000
    
    var minimumMonth    = -1
    var maximumMonth    = -1
    var minimumYear     = -1
    var maximumYear     = -1
    
    var arrWeekdays :[String]?
    var arrMonths   :[String]?
    var arrYears    :[String]?
    
    
    
    var didSelectRow: ((_ comps1: String, _ comps2: String?) -> Void)?
    
    var weekFormat:WeekFormat = .full {
        didSet
        {
            switch weekFormat {
            case .short:
                arrWeekdays = DateFormatterManager.shared().shortStandaloneWeekdaySymbols
            default:
                arrWeekdays = DateFormatterManager.shared().standaloneWeekdaySymbols
            }
            
            reloadAllComponents()
        }
    }
    
    var monthFormat:MonthFormat = .full {
        didSet
        {
            switch monthFormat {
            case .index:
                arrMonths = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
            case .short:
                arrMonths = DateFormatterManager.shared().shortStandaloneMonthSymbols
            default:
                arrMonths = DateFormatterManager.shared().standaloneMonthSymbols
            }
            
            reloadAllComponents()
        }
    }
    
    var datePickerMode:CustomDatePickerMode = .monthyear {
        didSet
        {
            switch datePickerMode
            {
            case .week:
                switch weekFormat
                {
                case .short:
                    arrWeekdays = DateFormatterManager.shared().shortStandaloneWeekdaySymbols
                default:
                    arrWeekdays = DateFormatterManager.shared().standaloneWeekdaySymbols
                }
            default:
                switch monthFormat
                {
                case .index:
                    arrMonths = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
                case .short:
                    arrMonths = DateFormatterManager.shared().shortStandaloneMonthSymbols
                default:
                    arrMonths = DateFormatterManager.shared().standaloneMonthSymbols
                }
            }
            
            reloadAllComponents()
        }
    }

    var minimumDate:Date? {
        didSet
        {
            if (datePickerMode == .year || datePickerMode == .monthyear)
            {
                if (minimumDate != nil)
                {
                    let comps = CalendarManager.shared().dateComponents([.year, .month], from: minimumDate!)
                    minimumYear = comps.year!
                    minimumMonth = comps.month!
                }
                else
                {
                    minimumYear = -1
                    minimumMonth = -1
                }
                
                reloadAllComponents()
            }
        }
    }
    
    var maximumDate:Date? {
        didSet
        {
            if (datePickerMode == .year || datePickerMode == .monthyear)
            {
                if (maximumDate != nil)
                {
                    let comps = CalendarManager.shared().dateComponents([.year, .month], from: maximumDate!)
                    maximumYear = comps.year!
                    maximumMonth = comps.month!
                }
                else
                {
                    maximumYear = -1
                    maximumMonth = -1
                }
                
                reloadAllComponents()
            }
        }
    }
    
    
    
    
    
    //MARK:-
    //MARK:- init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize()
    {
        self.showsSelectionIndicator = true
        
        
        
        ///Months
        arrMonths = DateFormatterManager.shared().standaloneMonthSymbols
        
        
        
        
        ///Years
        var dateComps = DateComponents()
        var years = [String]()
        
        DateFormatterManager.shared().dateFormat = "yyyy"
        
        for year in kMinYear...kMaxYear {
            dateComps.year = year
            let date = CalendarManager.shared().date(from: dateComps)
            let str = DateFormatterManager.shared().string(from: date!)
            years.append(str)
        }
        
        arrYears = years
        
        
        
        
        self.delegate = self
        self.dataSource = self
    }
    
    
    
    
    
    //MARK:-
    //MARK:- Date <-> Selection
    
    func selectionFromDate(_ animated:Bool) -> Void
    {
        if (datePickerMode == .year || datePickerMode == .monthyear)
        {
            let comps = CalendarManager.shared().dateComponents([.year , .month], from: _date)
            let month = comps.month
            let year  = comps.year
            
            // Select the corresponding rows in the UI
            if( datePickerMode == .year ) {
                self.selectRow((year! - kMinYear), inComponent: 0, animated: animated)
            } else {
                self.selectRow((month! - 1), inComponent: 0, animated: animated)
                self.selectRow((year! - kMinYear), inComponent: 1, animated: animated)
            }
        }
    }
    
    func dateFromSelection() -> Date?
    {
        if (datePickerMode == .year || datePickerMode == .monthyear)
        {
            var month:Int, year:Int
            
            // Select the corresponding rows in the UI
            if( datePickerMode == .year ) {
                month = 1
                year = self.selectedRow(inComponent: 0) + kMinYear
            } else {
                month = self.selectedRow(inComponent: 0) + 1
                year = self.selectedRow(inComponent: 1) + kMinYear
            }
            
            // Assemble into a date object
            var comps  = DateComponents()
            comps.day = 1
            comps.month = month
            comps.year = year
            
            return CalendarManager.shared().date(from: comps)
        }
        return nil
    }
    
    
    
    
    
    //MARK:-
    //MARK:- UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        switch datePickerMode
        {
        case .monthyear:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component
        {
        case 0:
            switch datePickerMode
            {
            case .week:
                return arrWeekdays!.count
            case .year:
                return arrYears!.count
            default:
                return arrMonths!.count
            }
        case 1:
            return arrYears!.count
        default:
            return 0
        }
    }
    
    /*
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch component
        {
        case 0:
            switch datePickerMode
            {
            case .week:
                return arrWeekdays![row]
            case .year:
                return arrYears![row]
            default:
                return arrMonths![row]
            }
        case 1:
            return "\(arrYears![row])"
        default:
            return nil
        }
    }
    */
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var label = view as? UILabel
        
        if (label == nil)
        {
            let rowSize = pickerView.rowSize(forComponent: component)
            label = UILabel(frame: CGRect(x: 0, y: 0, width: rowSize.width, height: rowSize.height))
            label?.font = UIFont.systemFont(ofSize: 24)
            label?.adjustsFontSizeToFitWidth = true
            label?.textAlignment = .center
        }
        
        
        
        switch datePickerMode {
        case .week:
            label?.text = arrWeekdays![row]
        case .month:
            label?.text = arrMonths![row]
        case .year:
            label?.text = arrYears![row]
        
            let year = row + kMinYear
            var outOfBounds = false
            
            if ((minimumDate != nil && year < minimumYear) ||
                (maximumDate != nil && year > maximumYear)) {
                outOfBounds = true
            }
            
            label!.textColor = (outOfBounds ? UIColor.gray : UIColor.black)
        case .monthyear:
            var outOfBounds = false
            if (component == 0)
            {
                label?.text = arrMonths![row]
                let month = row + 1
                let year = CalendarManager.shared().dateComponents([.year], from: _date).year
                
                if (( (minimumDate != nil) && ((year! < minimumYear) || ((year! == minimumYear) && (month < minimumMonth))) ) ||
                    ( (maximumDate != nil) && ((year! > maximumYear) || ((year! == maximumYear) && (month > maximumMonth))) )) {
                    outOfBounds = true
                }
            }
            else
            {
                label?.text = arrYears![row]
                let year = row + kMinYear
                
                if ((minimumDate != nil && year < minimumYear) ||
                    (maximumDate != nil && year > maximumYear)) {
                    outOfBounds = true
                }
            }
            
            label!.textColor = (outOfBounds ? UIColor.gray : UIColor.black)
        }
        
        
        return label!
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var comps1:String?
        var comps2:String?
        
        switch datePickerMode
        {
        case .week:
            comps1 = arrWeekdays![self.selectedRow(inComponent: 0)]
        case .monthyear:
            comps1 = arrMonths![self.selectedRow(inComponent: 0)]
            comps2 = arrYears![self.selectedRow(inComponent: 1)]
        case .year:
            comps1 = arrYears![self.selectedRow(inComponent: 0)]
        default:
            comps1 = arrMonths![self.selectedRow(inComponent: 0)]
        }
        
        if let block = didSelectRow {
            block(comps1!, comps2)
        }
    }
}
