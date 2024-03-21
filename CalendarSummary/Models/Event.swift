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


struct Event: Identifiable {
    let id = UUID()
    var title: String
    var duration: Int
    var url: String
    let calendar: Calendar
    let color: Color

    let ref: EKEvent

    var children: Events = Events()
    var expandable: Bool { children.count > 0 }
    var expanded: Bool = true
    var level: Int = 0

    init?(ek: EKEvent) {
        if ek.isAllDay { return nil }

        self.init(ek: ek, title: ek.title
            .trimmingCharacters(in: .whitespaces)
        )
    }
    init(ek: EKEvent, title: String) {
        self.ref = ek

        self.title = title
        self.duration = ek.duration
        self.url = ek.url?.absoluteString ?? ""
        self.calendar = ek.calendar
        self.color = Color(ek.calendar.color)
    }
    // var subtitle: (String, String) {
    //     var subtitle = self.title.split(separator: ". ")
    //     return (
    //         subtitle.removeFirst().description,
    //         subtitle.joined(separator: ". ")
    //     )
    // }
    var subtitle: String? {
        guard let subtitle = self.title
            .split(separator: ". ")
            .dropFirst(level)
            .first?
            .description
        else { return nil }
        return String(repeating: "- ", count: level) + subtitle
    }
    var path: String {
        self.title
            .split(separator: ". ")[...level]
            .joined(separator: ". ")
    }
    var hasChildren: Bool {
        var e = self
        e.level += 1
        return e.subtitle != nil
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.path == rhs.path
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
    mutating func append(_ immutable: Event) {
        var event = immutable

        if event.hasChildren {
            var child = event
            child.level += 1
            event.children.append(child)
        }

        if let index = firstIndex(of: event) {
            self[index].duration += event.duration
            event.children.forEach { child in
                self[index].children.append(child)
            }
        } else {
            append(contentsOf: [event])
        }

        sort()
    }
    mutating func append(_ ek: EKEvent) {
        guard let event = Event(ek: ek) else { return }
        append(event)
    }
}
