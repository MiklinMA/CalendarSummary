//
//  Int.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


extension Int {
    var asTimeString: String {
        var seconds = self
        guard seconds > 0
        else { return "0:00" }

        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        seconds %= 60

        return if hours > 0 {
            String(format: "%d:%02i:%02i", hours, minutes, seconds)
        } else if minutes > 0 {
            String(format: "%02i:%02i", minutes, seconds)
        } else {
            String(format: "0:%02i", seconds)
        }
    }
}
