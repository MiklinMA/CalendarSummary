//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit

struct Calendar: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let ref: EKCalendar
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    var duration: Int
    var url: String
    let calendar: EKCalendar
}

extension Date {
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

enum StandardPeriod: String, CaseIterable, Identifiable {
    case custom
    case today
    case yesterday
    case oneWeek = "One Week"
    case oneMonth = "One Month"
    case oneYear = "One Year"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case lastYear = "Last Year"
    
    init() {
        self = StandardPeriod(rawValue: (
            UserDefaults.standard.string(forKey: "standard") ?? "custom"
        ))!
    }
    
    var id: String { self.rawValue }
    
    var range: (since: Date?, until: Date?) {
        let today = Date()
        
        switch self {
        case .today:
            return (today, today)
        case .yesterday:
            return (today.delta(-1), today.delta(-1))
            
        case .oneWeek:
            return (today.delta(-7), today)
        case .oneMonth:
            return (today.delta(months: -1), today)
        case .oneYear:
            return (today.delta(years: -1), today)

        case .thisWeek:
            return (today.dow(2), today)
        case .thisMonth:
            return (today.startOfMonth, today)
        case .thisYear:
            return (today.startOfYear, today)
            
        case .lastWeek:
            return (today.delta(-7).dow(2), today.delta(-7).dow(8))
        case .lastMonth:
            return (today.delta(months: -1).startOfMonth, today.startOfMonth.delta(-1))
        case .lastYear:
            return (today.delta(years: -1).startOfYear, today.startOfYear.delta(-1))
            
        case .custom:
            return (nil, nil)
        }
    }
}

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
                UserDefaults.standard.object(forKey: "since") ?? getFirstDay()
            ) as! Date
            
            until = (
                UserDefaults.standard.object(forKey: "until") ?? Date()
            ) as! Date
        }
    }
}

enum EventError: LocalizedError {
    case accessDenied
    case accessRestricted
    case failedReadingEvents
    case noCalendar
    case unknownDate
    case unknown

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("The app does'n have permission to read calendars",
                comment: "access denied error description"
            )
        case .accessRestricted:
            return NSLocalizedString("The device doesn't allow access to calendars",
                comment: "access restricted error description"
            )
        case .failedReadingEvents:
            return NSLocalizedString("Failed to read events.",
                comment: "failed reading events error description"
            )
        case .noCalendar:
            return NSLocalizedString("Calendar is not selected.",
                comment: "calendar is not selected"
            )
        case .unknownDate:
            return NSLocalizedString("Unknown date selected.",
                comment: "unknown date selected"
            )
        case .unknown:
            return NSLocalizedString("An unknown error occured",
                comment: "unknown error description"
            )
        }
    }
}
