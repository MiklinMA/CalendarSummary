//
//  Calendar.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation
import EventKit


struct Calendar: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let ref: EKCalendar

    init(ek: EKCalendar) {
        self.title = ek.title
        self.ref = ek
    }
}

extension Calendar: Equatable {
    static func == (lhs: Calendar, rhs: Calendar) -> Bool {
        return lhs.ref.calendarIdentifier == rhs.ref.calendarIdentifier
    }
}


typealias Calendars = [Calendar]
extension Calendars {
}
