//
//  Events.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import SwiftUI


@MainActor class EventManager: ObservableObject {
    private var __calendar = UserDefaults.standard.string(forKey: "calendar")

    @Published var period: TimePeriod { didSet { update() }}
    @Published var error: String = ""
    @Published var calendars: Calendars = Calendars()
    @Published var calendar: Calendar? { didSet {
        UserDefaults.standard.set(__calendar, forKey: "calendar")
        update()
    }}

    @Published var events: Events = []

    init() {
        period = TimePeriod()
    }

    func load() async throws {
        guard try await EKEventStore.shared.requestAccess() else {
            throw EventError.accessDenied
        }
        calendars = EKEventStore.shared.calendars
        calendar = calendars.first(where: { $0.calendarIdentifier == __calendar })
        update()
        objectWillChange.send()
    }
    func update() {
        events = EKEventStore.shared.events(
            period: period,
            calendars: calendar != nil ? [calendar!] : nil
        ).sorted()
    }
}

