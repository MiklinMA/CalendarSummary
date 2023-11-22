//
//  CalendarPicker.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


struct CalendarPicker: View {
    @StateObject var manager = EventManager.shared
    
    var body: some View {
        Picker("Calendar", selection: $manager.calendar) {
            Text("ALL").tag(nil as Calendar?)
            ForEach(manager.calendars) { calendar in
                Text(calendar.title).tag(calendar as Calendar?)
            }
        }
    }
}

