//
//  Events.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    static let shared = EventManager()
    
    @Published private(set) var calendars: [Calendar] = []
    @Published private(set) var events: [Event] = []
    @Published private(set) var total: Int = 0
    @Published var period = TimePeriod() {
        didSet {
            try? fillEvents()
        }
    }
    
    @Published var calendar: Calendar? {
        didSet {
            UserDefaults.standard.set(
                calendar?.ref.calendarIdentifier,
                forKey: "calendar"
            )

            try? fillEvents()
        }
    }

    private let store = EKEventStore()
    
    init() {
        Task {
            try await requestAccess()
            try await fillCalendars()
        }
    }
    
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            let granted = try await store.requestAccess(to: .event)
            guard granted else {
                throw EventError.accessDenied
            }
        case .restricted:
            throw EventError.accessRestricted
        case .denied:
            throw EventError.accessDenied
        case .authorized:
            return
        @unknown default:
            throw EventError.unknown
        }
    }
    
    @MainActor
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
    
    func fillEvents() throws {
        guard isAvailable else { throw EventError.accessDenied }
        
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
            let duration = getDuration(event)
            let url = event.url?.absoluteString ?? ""
            
            total += duration
            
            if let i = events.firstIndex(where: { $0.title == title }) {
                events[i].duration += duration
                continue
            }
            events.append(
                Event(
                    title: title,
                    duration: duration,
                    url: url,
                    calendar: event.calendar
                )
            )
        }
        
        events.sort { $0.duration > $1.duration }
    }
}

extension EventList {
    class Manager: EventManager {}
}

