//
//  Calendar.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation
import EventKit
import OSLog

// fileprivate extension Logger {
//     static let calendar = Logger(
//         subsystem: Bundle.main.bundleIdentifier!,
//         category: "calendar"
//     )
// }

struct Calendar: Identifiable, Hashable, Equatable {
    static func == (lhs: Calendar, rhs: Calendar) -> Bool {
        return lhs.ref.calendarIdentifier == rhs.ref.calendarIdentifier
    }

    let id = UUID()
    let title: String
    let ref: EKCalendar

    init(ek: EKCalendar) {
        self.title = ek.title
        self.ref = ek
    }
}

typealias Calendars = [Calendar]
extension Calendars {
}
