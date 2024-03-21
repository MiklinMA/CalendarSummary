//
//  Error.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 31.03.2022.
//

import Foundation
import EventKit
import SwiftUI


struct Event: Identifiable {
    let ref: EKEvent

    var _children: Events? {
        guard children.count > 0 else { return nil }
        return children
    }
    var children: Events = Events()
    var expandable: Bool { children.count > 0 }
    var level: Int = 0

    init?(ref: EKEvent, level: Int = 0) {
        if ref.isAllDay { return nil }

        self.ref = ref
        self.level = level

        guard let _ = subtitle else { return nil }

        guard let child else { return }
        children.append(child)
    }

    var id: String {
        self.title.split(separator: ". ")[...level]
            .joined(separator: ". ") + "."
    }
    var subtitle: String? {
        self.title
            .split(separator: ". ")
            .dropFirst(level)
            .first?
            .description
    }
    private var child: Event? {
        return Event(ref: ref, level: level + 1)
    }
}

extension Event {
    var title: String { ref.title }
    var duration: Int {
        if children.isEmpty { ref.duration }
        else { children.reduce(0, { $0 + $1.duration }) }
    }
    var url: String { ref.url?.absoluteString ?? "" }
    var calendar: Calendar { ref.calendar }
    var color: Color { Color(ref.calendar.color) }
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
