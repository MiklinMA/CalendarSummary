//
//  NSCalendar.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation
import EventKit


extension EKEvent: Leaf {
    var duration: Int {
        NSCalendar.current.dateComponents(
            [.minute],
            from: self.startDate,
            to: self.endDate
        ).minute ?? 0
    }
}
