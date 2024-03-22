//
//  EventTable.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.11.2023.
//
/* TODO:
 * изменять события календаря из приложения
 * - rename - определить подходящие события
 * - переименовать в соответствии с children
 * + открытие календаря с поиском по клику
 */


import SwiftUI


struct EventTable: View {
    @ObservedObject var manager: EventManager

    @State private var selection = Set<Branch.ID>()


    var body: some View {
        Table(of: Branch.self, selection: $selection) {
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
            OutlineGroup(manager.tree.branches ?? [], children: \.branches) { branch in
                EventRow(branch)
            }
        }
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
            .onSubmit {
                event.rename(text)
                print(event.all.map {$0.title})
            }
    }
}}
