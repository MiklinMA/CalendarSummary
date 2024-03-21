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
        let _ = Self._printChanges()
        Table(of: Event.self) {
            TableColumn("Event") {
                EventColumnTitle(manager: manager, event: $0)
            }
            TableColumn(manager.events.total.asTimeString + " total") {
                EventColumnDuration(event: $0)
            }.width(80)
        } rows: {
            ForEach(manager.events, id: \.id) { event in
                EventRow(event)
                if event.expanded {
                    ForEach(event.children) { child in
                        EventRow(child)
                    }
                }
            }
        }
    }
}
