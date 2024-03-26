//
//  EventRow.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 20.03.2024.
//

import Foundation
import SwiftUI
import OSLog


struct EventRow: TableRowContent {
    typealias TableRowValue = Branch
    typealias TableRowBody = TableRow

    let event: TableRowValue

    var tableRowBody: some TableRowContent<TableRowValue> {
        TableRow(event)
            .contextMenu {
                Button("Show events") { event.showSearch() }
                RenameButton()
                // Button("Delete") { manager.showDelete = true }
            }
    }
}
