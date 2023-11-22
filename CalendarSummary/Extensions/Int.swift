//
//  Int.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


extension Int {
    var asTimeString: String {
        var minutes = self
        guard minutes > 0 else { return "0:00" }

        let days = minutes / 1440
        let hours = (minutes % 1440) / 60
        minutes %= 60

        return if days > 0 {
            String(format: "%d:%02i:%02i", days, hours, minutes)
        } else if hours > 0 {
            String(format: "%02i:%02i", hours, minutes)
        } else {
            String(format: "0:%02i", minutes)
        }
    }
}
