//
//  Events.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import OSLog
import SwiftUI

fileprivate extension Logger {
    static let manager = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "manager"
    )
}

@MainActor class EventManager: ObservableObject {
    @Published private(set) var calendars: [Calendar] = []
    @Published private(set) var events: [Event] = []
    @Published private(set) var total: Int = 0
    @Published var period = TimePeriod()

    @Published var calendar: Calendar? {
        didSet {
            UserDefaults.standard.set(
                calendar?.ref.calendarIdentifier,
                forKey: "calendar"
            )
        }
    }

    @Published var error: String = ""

    private let store = EKEventStore()

    init() {}

    func load() async throws {
        try await requestAccess()
        try fillCalendars()
    }

    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            // if #available(macOS 14.0, *) {
                guard try await store.requestFullAccessToEvents() else {
                    throw EventError.accessDenied
                }
            // } else {
            //     guard try await store.requestAccess(to: .event) else {
            //         throw EventError.accessDenied
            //     }
            // }
        case .restricted:
            throw EventError.accessRestricted
        case .denied:
            throw EventError.accessDenied
        case .authorized:
            return
        default:
            throw EventError.unknown
        }
    }
    
    func fillCalendars() throws {
        guard isAvailable else { throw EventError.accessDenied }
        
        let ref = UserDefaults.standard.string(forKey: "calendar")

        calendars = store.calendars(for: .event).compactMap { ekItem in
            let item = Calendar(
                title: ekItem.title,
                ref: ekItem
            )
            if ekItem.calendarIdentifier == ref { calendar = item }
            return item
        }
        try fillEvents()
    }
    
    func fillEvents () throws {
        guard isAvailable else {
            // return Logger.manager.error("\(EventError.accessDenied)")
            throw EventError.accessDenied
        }

        var calendars: [EKCalendar]?
        if let calendar = calendar { calendars = [calendar.ref] }
        else { calendars = nil }

        let predicate = store.predicateForEvents(
            withStart: period.since, end: period.until,
            calendars: calendars
        )
        
        events.removeAll()
        total = 0
        
        for event in store.events(matching: predicate) {
            if event.isAllDay { continue }
            
            let title = event.title.trimmingCharacters(in: .whitespaces)
            let url = event.url?.absoluteString ?? ""
            
            total += event.duration

            if let i = events.firstIndex(where: { $0.title == title }) {
                events[i].duration += event.duration
                continue
            }
            events.append(
                Event(
                    title: title,
                    duration: event.duration,
                    url: url,
                    calendar: event.calendar
                )
            )
        }
        
        events.sort { $0.duration > $1.duration }
    }
}

