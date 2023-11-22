//
//  CalendarDatePicker.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


struct CalendarDatePicker: View {
    @StateObject var manager: EventManager

    var body: some View {
        VStack {
            Picker("Standard", selection: $manager.period.standard) {
                ForEach(StandardPeriod.allCases) { p in
                    Text(p.rawValue.capitalized).tag(p)
                }
            }
            if manager.period.standard == .custom {
                HStack {
                    Text("Period")
                    DatePicker("", selection: $manager.period.since, displayedComponents: [.date])
                    DatePicker("", selection: $manager.period.until, displayedComponents: [.date])
                    Spacer()
                }
            }
        }
    }
}
