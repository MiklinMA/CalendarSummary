//
//  Date.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


extension Date {
    var firstDay: Date {
        let nsc = NSCalendar.current
        let components = nsc.dateComponents(
            [.year, .month],
            from: nsc.startOfDay(for: self)
        )
        return nsc.date(from: components) ?? Date()
    }
    var startOfDay: Date {
        NSCalendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        return NSCalendar.current.date(byAdding: components, to: startOfDay)!
    }
    var startOfMonth: Date {
        let nsc = NSCalendar.current
        
        let components = nsc.dateComponents([.year, .month], from: self)
        return nsc.date(from: components)!
    }
    var startOfYear: Date {
        let nsc = NSCalendar.current
        
        let components = nsc.dateComponents([.year], from: self)
        return nsc.date(from: components)!
    }
    
    func delta(_ days: Int? = nil, months: Int? = nil, years: Int? = nil) -> Date {
        let nsc = NSCalendar.current

        if let days = days {
            return nsc.date(byAdding: .day, value: days, to: self)!
        }
        if let months = months {
            return nsc.date(byAdding: .month, value: months, to: self)!
        }
        if let years = years {
            return nsc.date(byAdding: .year, value: years, to: self)!
        }
        return self
    }
    func dow(_ value: Int) -> Date {
        let nsc = NSCalendar.current
        
        var components = nsc.dateComponents(
            [.weekOfYear, .yearForWeekOfYear],
            from: self
        )
        components.weekday = value
        return nsc.date(from: components)!
    }
}
