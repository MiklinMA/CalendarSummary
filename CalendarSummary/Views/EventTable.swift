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
 * + удаление событий
 * - сортировка
 * - причесать UI
 */


import SwiftUI
import OSLog


struct EventTable: View {
    @ObservedObject var manager: EventManager

    @State private var selection: Branch.ID? = nil
    // TODO: sort won't work
    @State private var sortOrder = [KeyPathComparator(\Branch.duration)]

    @State private var showDelete: Bool = false
    @State private var selected: Branch? = nil

    var body: some View {
        Table(of: Branch.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Event") { event in EventColumn(event: event) }
        } rows: {
            OutlineGroup(manager.tree.branches, children: \.children) { branch in
                TableRow(branch)
                    .contextMenu {
                        Button("Show events") { branch.showSearch() }
                        Button("Delete") { showDelete = true }
                    }
            }
        }
        .tableColumnHeaders(.hidden)
        .onChange(of: selection, { self.selected = self.manager.tree[$1] })
        .confirmationDialog("Are you sure?", isPresented: $showDelete) {
            Button("Delete") { selected?.delete() }
        }
        .onDeleteCommand(perform: { showDelete = true })
    }
}

extension EventTable { private struct EventColumn: View {
    @FocusState private var isRename: Bool
    @State var text: String

    let event: Branch

    init(event: Branch) {
        self.event = event
        self.text = event.title
    }

    var body: some View {
        HStack {
            TextField("", text: $text)
                .fontWeight(event.expandable ? .regular : .thin)
                .focused($isRename)
                .renameAction($isRename)
                .onSubmit { event.rename(text) }

            Spacer()

            Text(event.duration.asTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(event.expandable ? .regular : .light)
        }
    }
}}
