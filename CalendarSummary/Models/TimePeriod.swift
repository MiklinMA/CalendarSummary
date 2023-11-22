//
//  TimePeriod.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


struct TimePeriod {
    var since: Date {
        didSet {
            UserDefaults.standard.set(since, forKey: "since")
        }
    }
    var until: Date {
        didSet {
            UserDefaults.standard.set(until, forKey: "until")
        }
    }
    var standard: StandardPeriod {
        didSet {
            UserDefaults.standard.set(standard.rawValue, forKey: "standard")
            
            switch standard.range {
            case let (since?, until?):
                self.since = since.startOfDay
                self.until = until.endOfDay
            default:
                break
            }
        }
    }
    
    init() {
        standard = StandardPeriod(rawValue: (
            UserDefaults.standard.string(forKey: "standard") ?? "custom"
        )) ?? StandardPeriod.custom
        
        switch standard.range {
        case let (since?, until?):
            self.since = since.startOfDay
            self.until = until.endOfDay
        default:
            since = (
                UserDefaults.standard.object(forKey: "since") ?? Date().firstDay
            ) as! Date
            
            until = (
                UserDefaults.standard.object(forKey: "until") ?? Date()
            ) as! Date
        }
    }
}

