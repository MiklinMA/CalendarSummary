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

    @Published var period = TimePeriod()
    @Published var error: String = ""
    @Published var calendars: Calendars = Calendars()
    @Published var calendar: Calendar? { didSet {
        UserDefaults.standard.set(__calendar, forKey: "calendar")
    }}

    var events: Events {
        EKEventStore.shared.events(
            period: period,
            calendars: calendar != nil ? [calendar!] : nil
        ).sorted()
    }

    init() {}

    func load() async throws {
        try await EKEventStore.shared.requestAccess()
        calendars = EKEventStore.shared.calendars
        calendar = calendars.first(where: { $0.ref.calendarIdentifier == __calendar })
        objectWillChange.send()
    }
}

