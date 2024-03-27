//
//  Notification.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 27.03.2024.
//

import Foundation

extension Notification {
    var changeType: Int? {
        (userInfo?["EKEventStoreChangeTypeUserInfoKey"] as? NSNumber)?.intValue
    }
    var calendarDataChanged: Bool? {
        (userInfo?["EKEventStoreCalendarDataChangedUserInfoKey"] as? NSNumber)?.boolValue
    }
    var remindersDataChanged: Bool? {
        (userInfo?["EKEventStoreRemindersDataChangedUserInfoKey"] as? NSNumber)?.boolValue
    }
    var changedObjectIDs: [NSObject]? {
        userInfo?["EKEventStoreChangedObjectIDsUserInfoKey"] as? [NSObject]
    }
    var modifiedObjectIdentifiers: Set<String>? {
        userInfo?["EKEventStoreModifiedObjectIdentifiers"] as? Set<String>
    }
}
