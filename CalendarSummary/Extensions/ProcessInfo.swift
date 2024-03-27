//
//  ProcessInfo.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 27.03.2024.
//

import Foundation


extension ProcessInfo {
    var isSandboxed: Bool {
        ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }
}
