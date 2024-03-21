//
//  EventColumn.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 21.03.2024.
//

import Foundation
import SwiftUI


struct EventColumnTitle: View {
    @ObservedObject var manager: EventManager
    // @State var index
    @State var event: Event

    var expanded: Bool {
        manager.events
            .first { $0.id == event.id }?
            .expanded ?? false
    }

    var body: some View {
        HStack {
            if manager.calendar == nil {
                Image(systemName: "circle.fill")
                    .foregroundStyle(event.color)
            }
            Text(event.subtitle!)
                .fontWeight(event.expandable ? .regular : .light)
            Spacer()
            if event.expandable {
                let _ = Self._printChanges()
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 8)
                    .rotationEffect(Angle(degrees: expanded ? -90 : 0 ))
                    .animation(.easeIn(duration: 0.1), value: UUID())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let index = manager.events.firstIndex(of: event) {
                withAnimation {
                    manager.events[index].expanded.toggle()
                }
            }
        }
    }
}

struct EventColumnDuration: View {
    let event: Event

    var body: some View {
        HStack {
            Spacer()
            Text(event.duration.asTimeString)
                .font(.system(.body, design: .monospaced))
                .fontWeight(event.expandable ? .regular : .light)
        }
    }
}
