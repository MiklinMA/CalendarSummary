//
//  EventError.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


enum EventError: LocalizedError {
    case accessDenied
    case accessRestricted
    case failedReadingEvents
    case noCalendar
    case unknownDate
    case unknown

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("The app does'n have permission to read calendars",
                comment: "access denied error description"
            )
        case .accessRestricted:
            return NSLocalizedString("The device doesn't allow access to calendars",
                comment: "access restricted error description"
            )
        case .failedReadingEvents:
            return NSLocalizedString("Failed to read events.",
                comment: "failed reading events error description"
            )
        case .noCalendar:
            return NSLocalizedString("Calendar is not selected.",
                comment: "calendar is not selected"
            )
        case .unknownDate:
            return NSLocalizedString("Unknown date selected.",
                comment: "unknown date selected"
            )
        case .unknown:
            return NSLocalizedString("An unknown error occured",
                comment: "unknown error description"
            )
        }
    }
}
