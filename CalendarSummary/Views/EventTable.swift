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

    var expandable: Bool {
        children != nil && children!.count > 0
    }

    var weight: Font.Weight {
        children != nil ? .regular : .light
    }

    var chevron: String {
        expanded ? "chevron.down" : "chevron.left"
    }
}

typealias TableEvents = [TableEvent]

struct EventTable: View {
    @StateObject var manager: EventManager

    @State private var rows: TableEvents = TableEvents()

    func reload(_ events: Events) {
        var expanded = true
        rows = events.map { event in
            let e = TableEvent(
                event: event,
                expanded: expanded,
                children: event.children.map { child in
                    TableEvent(event: child)
                }
            )
            expanded = false
            return e
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
                    Text(row.event.title)
                        .fontWeight(row.weight)
                    Spacer()
                    if row.expandable {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 8)
                            .rotationEffect(Angle(degrees: row.expanded ? -90 : 0 ))
                            .animation(.easeIn(duration: 0.5), value: UUID())
                    }
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
