//
//  ContentView.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 29.03.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager: EventManager

    init() {
        let manager = EventManager()
        _manager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    CalendarPicker(manager: manager)
                    StandardDatePicker(manager: manager)
                }

                CalendarDatePicker(manager: manager)
            }
            EventTable(manager: manager)
                .padding(.vertical, 5)
        }
        .frame(minWidth: 300, minHeight: 200)
        .alert(isPresented: Binding(
            get: { manager.error.isEmpty != true },
            set: { _ in manager.error = String() }
        )) {
            Alert( title: Text(manager.error) )
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
