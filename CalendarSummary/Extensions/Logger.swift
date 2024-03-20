//
//  Logger.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 20.03.2024.
//

import Foundation
import OSLog

extension Logger {
    static var subsystem: String = Bundle.main.bundleIdentifier!

    public init(_ category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
}
