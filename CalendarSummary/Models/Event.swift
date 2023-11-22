//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import OSLog
import SwiftUI

fileprivate extension Logger {
    static let calendar = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "calendar"
    )
}

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var duration: Int
    var url: String
    let calendar: EKCalendar
    let color: Color

    var children: Events = Events()

    init?(ek: EKEvent) {
        if ek.isAllDay { return nil }

        self.init(ek: ek, title: ek.title
            .trimmingCharacters(in: .whitespaces)
        )
    }
    init(ek: EKEvent, title: String) {
        self.title = title
        self.duration = ek.duration
        self.url = ek.url?.absoluteString ?? ""
        self.calendar = ek.calendar
        self.color = Color(ek.calendar.color)
    }
    var subtitle: (String, String) {
        var subtitle = self.title.split(separator: ". ")
        return (
            subtitle.removeFirst().description,
            subtitle.joined(separator: ". ")
        )
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.title == rhs.title
    }
}

extension Event: Comparable {
    public static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.duration > rhs.duration
    }
}

typealias Events = [Event]
extension Events {
    var total: Int {
        reduce(0) { $0 + $1.duration }
    }
    mutating func updateExisting(event: Event) -> Bool {
        if let index = firstIndex(of: event) {
            self[index].children += event.children
            self[index].children.sort()
            self[index].duration += event.duration
            return true
        }
        return false
    }
    mutating func append(ek: EKEvent) {
        guard var event = Event(ek: ek) else { return }

        let (title, subtitle) = event.subtitle
        if !subtitle.isEmpty {
            event.title = title
            let child = Event(ek: ek, title: subtitle)
            if event.children.updateExisting(event: child) == false {
                event.children.append(child)
            }
        }

        if updateExisting(event: event) == false {
            append(event)
        }
    }
}
