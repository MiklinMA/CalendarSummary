//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit

struct Event: Identifiable, Comparable {
    let id = UUID()
    let title: String
    var duration: Int
    var url: String
    let calendar: EKCalendar

    public static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.duration > rhs.duration
    }
}

typealias Events = [Event]
extension Events {
    var total: Int {
        reduce(0) { $0 + $1.duration }
    }
}
