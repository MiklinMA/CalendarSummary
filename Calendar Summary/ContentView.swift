//
//  ContentView.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 29.03.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        EventList()
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
