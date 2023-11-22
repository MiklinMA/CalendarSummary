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
            HStack {
                CalendarPicker(manager: manager)
                CalendarDatePicker(manager: manager)
            }

            EventTable(manager: manager)
        }
        .alert(isPresented: Binding(
            get: { manager.error.isEmpty != true },
            set: { _ in manager.error = String() }
        )) {
            Alert( title: Text(manager.error) )
        }
        .task { @MainActor in
            do {
                try await manager.load()
            } catch {
                manager.error = error.localizedDescription
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
