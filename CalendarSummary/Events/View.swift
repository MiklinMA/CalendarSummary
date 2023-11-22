//
//  EventsView.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 07.05.2022.
//

import SwiftUI

struct EventList: View {
    @StateObject var manager = Manager.shared

    var body: some View {
        VStack {
            HStack {
                CalendarPicker(manager: manager)
                CalendarDatePicker(manager: manager)
            }

            EventTable(manager: manager)
        }
    }
}

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

struct CalendarDatePicker: View {
    @StateObject var manager = EventManager.shared
    
    var body: some View {
        VStack {
            HStack {
                Text("Period")
                // Toggle(isOn: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Is On@*/.constant(true)/*@END_MENU_TOKEN@*/) {
                //     /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Label@*/Text("Label")/*@END_MENU_TOKEN@*/
                // }
                DatePicker("", selection: $manager.period.since, displayedComponents: [.date])
                DatePicker("", selection: $manager.period.until, displayedComponents: [.date])
            }
            Picker("Standard", selection: $manager.period.standard) {
                ForEach(StandardPeriod.allCases) { p in
                    Text(p.rawValue.capitalized).tag(p)
                }
            }
        }
    }
}

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

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventList()
    }
}
