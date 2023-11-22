//
//  Double.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//

import Foundation


extension Double {
    var asInt: Int? {
        guard self >= Double(Int.min),
              self <= Double(Int.max)
        else { return nil }

        return Int(self)
    }
    var asTimeString: String {
        self.asInt?.asTimeString ?? "0:00"
    }
}
