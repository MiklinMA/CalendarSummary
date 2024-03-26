//
//  AppleScript.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 26.03.2024.
//

import Foundation

struct AppleScript {
    static func calendarFilterCmd(pattern: String) -> String {
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
}
