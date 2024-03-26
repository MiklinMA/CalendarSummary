//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//
/* TODO:
 * изменять события календаря из приложения
 * + rename - определить подходящие события
 * + переименовать в соответствии с children
 * + открытие календаря с поиском по клику
 * - удаление событий
 * - причесать UI
 */


import SwiftUI
import OSLog


struct EventTable: View {
    @ObservedObject var manager: EventManager

    @State private var selection = Set<Branch.ID>()
    // TODO: sort won't work
    @State private var sortOrder = [KeyPathComparator(\Branch.duration)]

    @State private var showDelete: Branch? = nil


    var body: some View {
        Table(of: Branch.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Event") { event in TitleColumn(event: event) }

            TableColumn(manager.tree.duration.asTimeString + " total") { event in
                HStack {
                    Spacer()
                    Text(event.duration.asTimeString)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(event.expandable ? .regular : .light)
                }
            }.width(80)
        } rows: {
            OutlineGroup(manager.tree.branches, children: \.children) { branch in
                TableRow(branch)
                    .contextMenu {
                        Button("Show events") { branch.showSearch() }
                        RenameButton()
                        // Button("Delete") { manager.showDelete = true }
                    }
            }
        }
        .onChange(of: sortOrder) { _, sortOrder in
            manager.tree.branches.sort(using: sortOrder)
        }
        .onChange(of: selection, { oldValue, newValue in
            print(oldValue, newValue)
        })
        // .confirmationDialog(
        //     "Are you sure \(showDelete?.title ?? "")?",
        //     isPresented: Binding(get: {showDelete != nil}, set: { showDelete = nil} )
        // ) {
        //     Button("Delete") {
        //         print("Delete OK")
        //         // event.delete()
        //     }
        // }
        // .deleteDisabled(false)
        // .onDeleteCommand(perform: { showDelete = true })
    }
}

extension EventTable { private struct TitleColumn: View {
    @FocusState private var isRename: Bool
    @State var text: String

    let event: Branch

    init(event: Branch) {
        self.event = event
        self.text = event.title
    }

    var body: some View {
        TextField("", text: $text)
            .fontWeight(event.expandable ? .regular : .thin)
            .focused($isRename)
            .renameAction($isRename)
            .onSubmit { event.rename(text) }
    }
}}
