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
}
