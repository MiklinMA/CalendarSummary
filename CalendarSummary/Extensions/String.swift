//
//  String.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.03.2024.
//

import Foundation


let separator: String = ". "

extension String {
    func split() -> [String] {
        if #available(macOS 13.0, *) {
            split(separator: separator).map { String($0) }
        }
        else {
            components(separatedBy: separator)
        }
    }
    func trim() -> String {
        self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    var pad: String {
        padding(toLength: 10, withPad: " ", startingAt: 0)
    }
    func padding(_ count: Int) -> String {
        padding(toLength: count, withPad: " ", startingAt: 0)
    }
    mutating func replace(_ string: String, position: Int) {
        var nodes = split()
        nodes[position] = string
        self = nodes.joined(separator: separator)
    }
    var dropLastSeparator: String {
        if last?.description == separator.trim() {
            dropLast(1).description
        } else {
            self
        }
    }
}

extension ArraySlice where Element : StringProtocol {
    func joined() -> String {
        let result = joined(separator: separator)
        let separator = separator.trim()
        if result.last?.description == separator { return result }
        return (result + separator).trim()
    }
}
