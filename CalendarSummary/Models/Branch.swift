//
//  Branch.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.03.2024.
//

import Foundation
import OSLog
import EventKit


protocol Leaf {
    var title: String! { get set }
    var duration: Int { get }
}
typealias Leaves = [Leaf]

class Branch: Identifiable, ObservableObject {
    var id: String { path }
    var path: String

    var level: Int = 0
    var branches: Branches = []
    var parent: Branch! = nil
    var leaves: Leaves = []

    var title: String!

    private init?(_ leaf: Leaf, level: Int) {
        let nodes = leaf.title.split()

        guard let title = nodes.dropFirst(level).first?.description.trim(),
              title.isEmpty == false
        else { return nil }

        self.path = nodes[0...level].joined()
        self.title = title
        self.level = level

        if let branch = Branch(leaf, level: level + 1) {
            branch.parent = self
            self.branches.append(unique: branch)
        } else {
            self.leaves.append(leaf)
        }
    }
    init(leaves: Leaves = []) {
        self.path = "ROOT."
        self.level = -1
        self.title = "ROOT"
        self.update(leaves: leaves)
    }
    func update(leaves: Leaves? = nil, level: Int = 0) {
        let leaves = leaves ?? self.all
        leaves.forEach { leaf in
            guard let branch = Branch(leaf, level: level) else { return }
            branch.parent = self
            self.branches.append(unique: branch)
        }
        self.sort()
    }
    func sort(using: [KeyPathComparator<Branch>] = [KeyPathComparator(\Branch.duration)]) {
        self.branches.forEach { $0.sort(using: using) }
        self.branches.sort(using: using)
        objectWillChange.send()
    }
    var all: Leaves {
        self.leaves + self.branches.reduce([]) { $0 + $1.all }
    }
    subscript (_ id: String?) -> Branch? {
        for branch in self.branches {
            if branch.id == id { return branch }
            if let branch = branch[id] { return branch }
        }
        return nil
    }
}

extension Branch: Leaf {
    var duration: Int { self.all.reduce(0, { $0 + $1.duration }) }
    var expandable: Bool { self.branches.count > 0 }
    var children: Branches? { self.branches.count > 0 ? self.branches : nil }

    func rename(_ title: String) {
        guard let parent else { return }

        let leaves: [EKEvent] = self.all.compactMap {
            guard let leaf = $0 as? EKEvent else { return nil }
            leaf.title.replace(title, position: level)

            do {
                try EKEventStore.shared.save(leaf, span: .thisEvent, commit: true)
            } catch {
                Logger("event").error("\(error.localizedDescription)")
            }
            return leaf
        }

        parent.branches.removeAll { $0.id == self.id }
        parent.update(leaves: leaves, level: self.level)
    }
    func delete() {
        guard let parent else { return }

        self.all.forEach {
            guard let leaf = $0 as? EKEvent else { return }
            do {
                try EKEventStore.shared.remove(leaf, span: .thisEvent, commit: true)
            } catch {
                Logger("event").error("\(error.localizedDescription)")
            }
        }
        parent.branches.removeAll { $0.id == self.id }
    }
    func showEvents() {
        let source = AppleScript.calendarFilterCmd(pattern: self.path)
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return }

        DispatchQueue.global(qos: .background).async {
            script.executeAndReturnError(&error)
            if let error,
               let message: String = error["NSAppleScriptErrorMessage"] as? String {
                Logger("event row").error("AppleScript: \(message)")
            }
        }
    }
}

typealias Branches = [Branch]
extension Branches {
    mutating func append(unique branch: Branch) {
        guard let index = firstIndex(where: { $0.path == branch.path })
        else { return append(branch) }

        branch.branches.forEach { self[index].branches.append(unique: $0) }
        branch.leaves.forEach { self[index].leaves.append($0) }
    }
}

