//
//  ContentView.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 29.03.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager = EventManager.shared

    var body: some View {
        VStack {
            HStack {
                CalendarPicker(manager: manager)
                CalendarDatePicker(manager: manager)
            }

            EventTable(manager: manager)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
