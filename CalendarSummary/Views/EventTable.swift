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
 * + сортировка
 * - причесать UI
 */


import SwiftUI
import OSLog


struct EventTable: View {
    @ObservedObject var manager: EventManager

    @State private var showDelete: Bool = false
    @State private var selection: Branch.ID? = nil
    @State private var selected: Branch? = nil

    var body: some View {
        Table(manager.tree.list, selection: $selection, sortOrder: $manager.sortOrder) {
            TableColumn("Event", value: \.title) { event in
                EventColumn(event: event)
            }
            TableColumn(manager.tree.duration.asTimeString, value: \.duration) { event in
                DurationColumn(event: event)
            }.width(80)
        }
        .confirmationDialog("Are you sure?", isPresented: $showDelete) {
            Button("Delete") {
                selected?.delete()
            }
        }
        .onDeleteCommand(perform: { showDelete = true })
        .onReceive(selection.publisher, perform: { self.selected = self.manager.tree[$0] })
        .environmentObject(manager)
        .task { @MainActor in
            do { try await manager.load() }
            catch { manager.error = error.localizedDescription }
        }
    }
}

extension EventTable { private struct EventColumn: View {
    @FocusState private var isRename: Bool
    @State var text: String
    @EnvironmentObject var manager: EventManager

    let event: Branch

    init(event: Branch) {
        self.event = event
        self.text = event.title
    }

    var body: some View {
        HStack {
            ForEach((0..<event.level), id: \.self) { _ in Text(" ") }

            if event.expandable {
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 8)
                    .rotationEffect(Angle(degrees: event.expanded ? 90 : 0 ))
                    .animation(.easeIn(duration: 0.1), value: UUID())
                    .onTapGesture {
                        manager.tree[event.id]?.expanded.toggle()
                        manager.objectWillChange.send()
                    }
            }
            TextField("", text: $text)
                .fontWeight(event.expandable ? .regular : .light)
                .focused($isRename)
                .renameAction($isRename)
                .onSubmit { event.rename(text) }
        }
    }
}}

extension EventTable { private struct DurationColumn: View {
    let event: Branch

    var body: some View {
        HStack {
            if !ProcessInfo.isSandboxed {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 8)
                    .onTapGesture { event.showEvents() }
            }
            Spacer()
            Text(event.duration.asTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(event.expandable ? .regular : .light)
        }
    }
}}
