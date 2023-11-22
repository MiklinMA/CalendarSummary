//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


struct EventTable: View {
    @StateObject var manager: EventManager
    
    var body: some View {
        Table(manager.events) {
            TableColumn("Event") { row in Text(row.title) }
            
            TableColumn(manager.events.total.asTimeString + " total") { row in
                Text(row.duration.asTimeString)
                    .foregroundColor(Color(row.calendar.color!))
            }.width(80)
        }
    }
}
