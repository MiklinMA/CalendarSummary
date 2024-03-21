//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import SwiftUI
import Combine
import OSLog


class Event: ObservableObject, Identifiable {
    var ref: EKEvent?

    var url: String
    var calendar: Calendar
    @Published var title: String { didSet {
        ref?.title = title
    }}

    var _children: Events? {
        guard children.count > 0 else { return nil }
        return children
    }
    var children: Events = Events()
    var expandable: Bool { children.count > 0 }
    var level: Int = 0

    @Published var subtitle: String
    private var cancellables = Set<AnyCancellable>()

    init?(ref: EKEvent, level: Int = 0) {
        if ref.isAllDay { return nil }

        self.ref = ref
        self.level = level

        self.title = ref.title
        self.url = ref.url?.absoluteString ?? ""
        self.calendar = ref.calendar

        guard let subtitle = ref.title
            .split(separator: ". ")
            .dropFirst(level)
            .first?
            .description
        else { return nil }

        self.subtitle = subtitle

        self.$subtitle
            .dropFirst()
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink { [weak self] in self?.rename($0) }
            .store(in: &cancellables)

        guard let child = Event(ref: ref, level: level + 1)
        else { return }

        self.ref = nil
        children.append(child)
    }

    var id: String {
        self.title.split(separator: ". ")[...level]
            .joined(separator: ". ") + "."
    }

    func rename(_ text: String, level: Int? = nil) {
        let level = level ?? self.level

        guard let ref else {
            self.children.forEach { $0.rename(text, level: level) }
            return
        }

        let head = self.title
            .split(separator: ". ")[..<level]
            .joined(separator: ". ")

        let tail = self.title
            .split(separator: ". ")
            .dropFirst(level + 1)
            .joined(separator: ". ")

        self.title = "\(head)\(text). \(tail)"
        print("Title: \(head)\(text). \(tail)")

        do {
            try EKEventStore.shared.save(ref, span: .thisEvent, commit: true)
        } catch {
            Logger("event").error("\(error.localizedDescription)")
        }
    }
}

extension Event {
    var duration: Int {
        ref?.duration ?? children.reduce(0, { $0 + $1.duration })
    }
    var color: Color { Color(calendar.color) }
}


typealias Events = [Event]
extension Events {
    var total: Int { reduce(0) { $0 + $1.duration } }

    mutating func append(_ event: Event) {
        guard let index = firstIndex(where: { $0.id == event.id })
        else {
            return append(contentsOf: [event])
        }

        event.children.forEach { child in
            self[index].children.append(child)
        }
    }
}
