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
    typealias TableRowValue = TableEvent
    typealias TableRowBody = TableRow

    let value: TableRowValue

    init(_ value: TableRowValue) {
        self.value = value
    }

    func action() {
        var pattern: String
        if let _ = value.children {
            pattern = value.event.title + ". "
        } else {
            pattern = value.event.fullTitle
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

    var tableRowBody: some TableRowContent<TableRowValue> {
        TableRow(value)
            .contextMenu {
                Button("Show calendar events") { action() }
            }
    }
}
