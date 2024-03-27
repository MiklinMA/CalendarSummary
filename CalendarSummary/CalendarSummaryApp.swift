//
//  Calendar_SummaryApp.swift
//  Calendar Summary
//
//  Created by Mike Miklin on 29.03.2022.
//

import SwiftUI

@main
struct CalendarSummaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
