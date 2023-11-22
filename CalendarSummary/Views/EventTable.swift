//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI

struct TableEvent: Identifiable, Equatable {
    let id = UUID()
    let event: Event
    var expanded: Bool = false
    var children: [TableEvent]? = nil

    var toplevel: Bool {
        children != nil
    }

    var title: String {
        toplevel
        ? event.title
        : " - \(event.title)"
    }

    var weight: Font.Weight {
        toplevel ? .regular : .thin
    }
}

struct EventTable: View {
    @StateObject var manager: EventManager

    @State private var rows: [TableEvent] = []

    func reload(_ events: Events) {
        rows = events.map { event in
            TableEvent(
                event: event,
                expanded: true,
                children: event.children.map { child in
                    TableEvent(event: child)
                }
            )
        }
    }

    var body: some View {
        Table(of: TableEvent.self) {
            TableColumn("Event") { row in
                HStack {
                    if manager.calendar == nil {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(row.event.color)
                    }
                    Text(row.title)
                        .fontWeight(row.weight)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = rows.firstIndex(of: row) {
                        withAnimation {
                            rows[index].expanded.toggle()
                        }
                    }
                }
            }

            TableColumn(manager.events.total.asTimeString + " total") { row in
                HStack {
                    Spacer()
                    Text(row.event.duration.asTimeString)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(row.weight)
                }
            }.width(80)
        } rows: {
            ForEach(rows, id: \.id) { row in
                TableRow(row)
                if row.expanded {
                    ForEach(row.children ?? []) { child in
                        TableRow(child)
                    }
                }
            }
        }
        .onReceive(manager.$events) { events in reload(events) }
    }
}
