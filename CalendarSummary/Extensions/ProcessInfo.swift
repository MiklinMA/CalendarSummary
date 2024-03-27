//
//  ProcessInfo.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 27.03.2024.
//

import Foundation


extension ProcessInfo {
    static var isSandboxed: Bool {
        processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }
}
