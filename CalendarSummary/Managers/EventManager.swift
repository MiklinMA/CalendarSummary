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
    @Published var sortOrder = [KeyPathComparator(\Branch.duration, order: .reverse)] { didSet {
        self.tree.sort(using: sortOrder)
    }}

    @Published var tree: Branch! = Branch()

    private var store: EKEventStore
    private var defaults: UserDefaults

    init() {
        period = TimePeriod()
        store = EKEventStore.shared
        defaults = UserDefaults.standard

        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: nil,
            queue: nil
        ) { [weak self] info in
            guard let self,
                  info.calendarDataChanged == true
            else { return }

            DispatchQueue.main.async { self.update() }
        }
    }

    func load() async throws {
        guard try await self.store.requestAccess() else {
            throw EventError.accessDenied
        }
        calendars = self.store.calendars
        calendar = self.calendars.first { $0.calendarIdentifier == defaults.calendar }
        update()
        self.tree.branches.first?.expanded = true
    }
    func update() {
        self.tree.update(leaves: self.store.events(
            period: period,
            calendars: calendar != nil ? [calendar!] : nil
        ))
        self.tree.sort(using: sortOrder)
        objectWillChange.send()
    }
}

