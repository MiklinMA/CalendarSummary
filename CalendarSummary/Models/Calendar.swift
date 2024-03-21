//
//  Calendar.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation
import EventKit

typealias Calendar = EKCalendar
extension Calendar: Identifiable {}

typealias Calendars = [Calendar]
extension Calendars {}
