//
//  Helpers.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 07.05.2022.
//

import Foundation
import EventKit

let nsc = NSCalendar.current

func getFirstDay(_ date: Date? = nil) -> Date {
    let date = date ?? Date()
    
    let components = nsc.dateComponents(
        [.year, .month],
        from: nsc.startOfDay(for: date)
    )
    return nsc.date(from: components)!
}

func getDuration(_ event: EKEvent) -> Int {
    return nsc.dateComponents(
        [.minute], from: event.startDate, to: event.endDate
    ).minute!
}

