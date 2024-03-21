//
//  EventRow.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 20.03.2024.
//

import Foundation
import SwiftUI
import OSLog


func calendarFilterCmd(pattern: String) -> String {
    """
    tell application "Calendar"
        activate
        tell window 0 to set visible to true
        switch view to week view
    end tell

    delay 0.1

    tell application "System Events"
        tell process "Calendar"
            keystroke "f" using {command down}
            keystroke "title: \(pattern)"
            keystroke return
        end tell
    end tell
    """
}

struct EventRow: TableRowContent {
    typealias TableRowValue = Event
    typealias TableRowBody = TableRow

    let event: TableRowValue

    init(_ event: TableRowValue) {
        self.event = event
    }

    var tableRowBody: some TableRowContent<TableRowValue> {
        TableRow(event)
            .contextMenu {
                Button("Show calendar events") { self.showSearch() }
                Button("Rename events") { self.renameEvents() }
            }
    }

    func showSearch() {
        var pattern: String
        if event.expandable {
            pattern = event.title + "."
        } else {
            pattern = event.ref.title
        }

        let source = calendarFilterCmd(pattern: pattern)
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return }

        DispatchQueue.global(qos: .background).async {
            script.executeAndReturnError(&error)
            if let error,
               let message: String = error["NSAppleScriptErrorMessage"] as? String {
                Logger("event row").error("AppleScript: \(message)")
            }
        }
    }

    func renameEvents() {
        print(event)
        return
    }
}
