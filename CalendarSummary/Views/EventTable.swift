//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//
/* TODO:
 * изменять события календаря из приложения
 * - rename - определить подходящие события
 * - переименовать в соответствии с children
 * + открытие календаря с поиском по клику
 */


import SwiftUI


struct EventTable: View {
    @ObservedObject var manager: EventManager

    var body: some View {
        // let _ = Self._printChanges()
        Table(of: Event.self) {
            TableColumn("Event") { event in
                Text(event.subtitle ?? "UNKNOWN")
                    .fontWeight(event.expandable ? .regular : .light)
            }
            TableColumn(manager.events.total.asTimeString + " total") { event in
                HStack {
                    Spacer()
                    Text(event.duration.asTimeString)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(event.expandable ? .regular : .light)
                }
            }.width(80)
        } rows: {
            OutlineGroup(manager.events, children: \._children) { event in
                EventRow(event)
            }
        }
    }
}
