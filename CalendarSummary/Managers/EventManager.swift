//
//  Events.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import SwiftUI
import Combine
import OSLog


fileprivate extension Logger { static var manager = Logger("manager") }

fileprivate extension UserDefaults {
    var calendar: String {
        get { string(forKey: "calendar") ?? "" }
        set { set(newValue, forKey: "calendar") }
    }
}

@MainActor class EventManager: ObservableObject {
    @Published var period: TimePeriod { didSet {
        Logger.manager.debug("Period: \(self.period.description)")
    }}
    @Published var error: String = ""
    @Published var calendars: Calendars = Calendars()
    @Published var calendar: Calendar? { didSet {
        defaults.calendar = calendar?.calendarIdentifier ?? ""
        Logger.manager.debug("Calendar: \(self.defaults.calendar)")
    }}
    @Published var sortOrder = [KeyPathComparator(\Branch.duration, order: .reverse)] { didSet {
        self.tree.sort(using: sortOrder)
        Logger.manager.debug("Sort order: \(self.sortOrder.description)")
    }}

    @Published var tree: Branch! = Branch()

    private var store: EKEventStore
    private var defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()
    @Published private var lastEvent: String = String()

    init() {
        period = TimePeriod()
        store = EKEventStore.shared
        defaults = UserDefaults.standard
        self.observe()
        self.subscribe()
    }
    private func observe() {
        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: nil,
            queue: nil
        ) { [weak self] info in
            guard let self,
                  info.calendarDataChanged == true
            else { return }

            guard let event = info.changedObjectIDs?.first(where: {
                $0.description.starts(with: "x-apple-eventkit:///Event/")
            }) else { return }

            Logger.manager.debug("Notification: \(event.description)")

            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    private func subscribe() {
        $calendar.removeDuplicates()
            .combineLatest($period.removeDuplicates())
            .dropFirst(2)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink {
                Logger.manager.info("Subscription: \($0.0?.title ?? "ALL") \($0.1.description)")
                self.update()
            }
            .store(in: &cancellables)
    }

    func load() async throws {
        guard try await self.store.requestAccess() else {
            throw EventError.accessDenied
        }
        calendars = self.store.calendars
        calendar = self.calendars.first { $0.calendarIdentifier == defaults.calendar }

        Logger.manager.debug(
            "Load: \(self.calendar?.title ?? "ALL") \(self.period.description)"
        )
        update()
        self.tree.branches.first?.expanded = true
    }
    private func update() {
        self.tree.update(leaves: self.store.events(period, calendar))
        self.tree.sort(using: sortOrder)
        self.objectWillChange.send()
    }
}

