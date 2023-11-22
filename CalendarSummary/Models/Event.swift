//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit

struct Event: Identifiable {
    let id = UUID()
    let title: String
    var duration: Int
    var url: String
    let calendar: EKCalendar
}

