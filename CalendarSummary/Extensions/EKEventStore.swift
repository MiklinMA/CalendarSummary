//
//  EKEventStore.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation
import EventKit

extension EKEventStore {
    static var shared = EKEventStore()

    var available: Bool {
        return if #available(macOS 14.0, *) {
            Self.authorizationStatus(for: .event) == .fullAccess
        } else {
            Self.authorizationStatus(for: .event) == .authorized
        }
    }
    func requestAccess() async throws -> Bool {
        return if available { true }
        else {
            if #available(macOS 14.0, *) {
                try await requestFullAccessToEvents()
            } else {
                try await requestAccess(to: .event)
            }
        }
    }
    var calendars: Calendars {
        guard available else { return [] }
        return calendars(for: .event)
    }
    func events(period: TimePeriod, calendars: Calendars? = nil) -> [EKEvent] {
        guard available else { return [] }

        let predicate = predicateForEvents(
            withStart: period.since, end: period.until,
            calendars: calendars
        )
        return events(matching: predicate)
    }
}
