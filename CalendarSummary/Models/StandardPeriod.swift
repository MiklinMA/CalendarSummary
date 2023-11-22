//
//  StandardPeriod.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


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

