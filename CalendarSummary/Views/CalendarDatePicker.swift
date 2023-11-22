//
//  CalendarDatePicker.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


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
