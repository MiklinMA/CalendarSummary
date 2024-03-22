//
//  CalendarDatePicker.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import SwiftUI


struct CalendarDatePicker: View {
    @StateObject var manager: EventManager

    let columns = [
        GridItem(.flexible(minimum: 85)),
        GridItem(.fixed(100)),
        GridItem(.fixed(100)),
    ]

    var body: some View {
        if manager.period.standard == .custom {
            LazyVGrid(columns: columns, alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Select dates")
                }
                DatePicker("", selection: $manager.period.since, displayedComponents: [.date])
                DatePicker("", selection: $manager.period.until, displayedComponents: [.date])
            }
        }
    }
}

struct StandardDatePicker: View {
    @StateObject var manager: EventManager

    var body: some View {
        Picker("", selection: $manager.period.standard) {
            ForEach(StandardPeriod.allCases) { p in
                Text(p.rawValue.capitalized).tag(p)
            }
        }
        .help("Standard period")
    }
}
