//
//  Events.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import SwiftUI


fileprivate extension UserDefaults {
    var calendar: String {
        get { string(forKey: "calendar") ?? "" }
        set { set(newValue, forKey: "calendar") }
    }
}

@MainActor class EventManager: ObservableObject {
    @Published var period: TimePeriod { didSet { update() }}
    @Published var error: String = ""
    @Published var calendars: Calendars = Calendars()
    @Published var calendar: Calendar? { didSet {
        defaults.calendar = calendar?.calendarIdentifier ?? ""
        update()
    }}

    @Published var events: Events = []

    private var store: EKEventStore
    private var defaults: UserDefaults

    init() {
        period = TimePeriod()
        store = EKEventStore.shared
        defaults = UserDefaults.standard
    }

    func load() async throws {
        guard try await self.store.requestAccess() else {
            throw EventError.accessDenied
        }
        calendars = self.store.calendars
        calendar = self.calendars.first { $0.calendarIdentifier == defaults.calendar }
        update()
        objectWillChange.send()
    }
    func update() {
        events = self.store.events(
            period: period,
            calendars: calendar != nil ? [calendar!] : nil
        ).sorted()
        guard let _ = events.first else { return }

        events[0].expanded = true
    }
}

