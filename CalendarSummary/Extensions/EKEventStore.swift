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
    func requestAccess() async throws {
        switch Self.authorizationStatus(for: .event) {
        case .notDetermined, .restricted, .denied:
            if #available(macOS 14.0, *) {
                guard try await requestFullAccessToEvents() else {
                    throw EventError.accessDenied
                }
            } else {
                guard try await requestAccess(to: .event) else {
                    throw EventError.accessDenied
                }
            }
        case .authorized:
            return
        default:
            throw EventError.unknown
        }
    }
    var calendars: Calendars {
        guard available else { return [] }
        return calendars(for: .event).map { Calendar(ek: $0) }
    }
    func events(period: TimePeriod, calendars: Calendars? = nil) -> Events {
        guard available else { return [] }

        let predicate = predicateForEvents(
            withStart: period.since, end: period.until,
            calendars: calendars != nil ? calendars!.map { $0.ref } : nil
        )

        return events(matching: predicate).reduce(into: Events()) { result, event in
            if event.isAllDay { return }

            let title = event.title.trimmingCharacters(in: .whitespaces)
            let url = event.url?.absoluteString ?? ""
            
            if let index = result.firstIndex(where: { $0.title == title }) {
                result[index].duration += event.duration
                return
            }

            result.append(
                Event(
                    title: title,
                    duration: event.duration,
                    url: url,
                    calendar: event.calendar
                )
            )
        }
    }
}
