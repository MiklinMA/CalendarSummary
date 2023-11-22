//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


struct EventTable: View {
    @StateObject var manager = EventManager.shared
    
    var body: some View {
        Table(manager.events) {
            TableColumn("Event") { row in Text(row.title) }
            
            TableColumn(String(Double(manager.total) / 60) + " total") { row in
                let hours = Double(row.duration) / 60
                Text(String(hours))
                    .foregroundColor(Color(row.calendar.color!))
            }.width(80)
        }
    }
}
