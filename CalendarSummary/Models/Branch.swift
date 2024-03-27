//
//  Branch.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.03.2024.
//

import Foundation
import OSLog
import EventKit

fileprivate extension Logger { static var branch = Logger("branch") }

protocol Leaf {
    var title: String! { get set }
    var duration: Int { get }
}
typealias Leaves = [Leaf]

class Branch: Identifiable, ObservableObject {
    var id: String { path }
    var path: String

    var level: Int = 0
    @Published var branches: Branches = []
    var parent: Branch! = nil
    var leaves: Leaves = []
    var expanded: Bool = false

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
        // Logger.branch.info("Init: \(self.path)")
    }
    init() {
        self.path = "ROOT."
        self.level = -1
        self.title = "ROOT"
        self.expanded = true

        Logger.branch.info("Init: \(self.path)")
    }
    func update(leaves initial: Leaves? = nil, level: Int = 0) {
        let leaves: Leaves
        if let initial {
            self.cleanLeaves()
            leaves = initial
        } else {
            leaves = self.all
        }

        Logger.branch.debug(
            "Update: \(leaves.map { "\($0.title ?? ""): \($0.duration.description) min" }.description)"
        )

        leaves.forEach { leaf in
            guard let branch = Branch(leaf, level: level) else { return }
            branch.parent = self
            self.branches.append(unique: branch)
        }
        self.cleanBranches()
        self.objectWillChange.send()
    }
    private func cleanLeaves(_ debug: Bool = true) {
        if debug {
            Logger.branch.debug("Clean leaves: \(self.path)")
        }
        self.leaves.removeAll()
        self.branches.forEach { $0.cleanLeaves(false) }
    }
    private func cleanBranches() {
        self.branches = self.branches.compactMap {
            guard $0.all.count > 0 else {
                Logger.branch.debug("Remove branch: \($0.path)")
                return nil
            }

            $0.cleanBranches()
            return $0
        }
    }
    func sort(using: [KeyPathComparator<Branch>] = [KeyPathComparator(\Branch.duration)],
              debug: Bool = true) {
        if debug {
            Logger.branch.debug("Sort: \(self.path)")
        }

        self.branches.forEach { $0.sort(using: using, debug: false) }
        self.branches.sort(using: using)
        objectWillChange.send()
    }
    var all: Leaves {
        // Logger.branch.debug("All: \(self.path)")

        return self.leaves + self.branches.reduce([]) { $0 + $1.all }
    }
    subscript (_ id: String?) -> Branch? {
        Logger.branch.debug("Subscript: \(self.path)")

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
    var list: Branches {
        (self.level < 0 ? [] : [self]) +
        (self.expanded ? self.branches.reduce([]) { $0 + $1.list } : [])
    }
    func rename(_ title: String) {
        guard let parent else { return }

        let leaves: [EKEvent] = self.all.compactMap {
            guard let leaf = $0 as? EKEvent else { return nil }
            leaf.title.replace(title, position: level)

            do {
                try EKEventStore.shared.save(leaf, span: .thisEvent, commit: true)
                Logger.branch.debug("Rename: \(leaf.title)")
            } catch {
                Logger.branch.error("\(error.localizedDescription)")
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
                Logger.branch.debug("Delete: \($0.title)")
            } catch {
                Logger.branch.error("\(error.localizedDescription)")
            }
        }
        parent.branches.removeAll { $0.id == self.id }
    }
    func showEvents() {
        let source = AppleScript.calendarFilterCmd(pattern: self.path.dropLastSeparator)
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return }

        DispatchQueue.global(qos: .background).async {
            script.executeAndReturnError(&error)
            if let error,
               let message: String = error["NSAppleScriptErrorMessage"] as? String {
                Logger.branch.error("AppleScript: \(message)")
            } else {
                Logger.branch.debug("Show events: \(self.path.dropLastSeparator)")
            }
        }
    }
}

typealias Branches = [Branch]
extension Branches {
    mutating func append(unique branch: Branch) {
        guard let index = firstIndex(where: { $0.path == branch.path })
        else {
            // Logger.branch.debug("Append: \(branch.path)")
            return append(branch)
        }

        let found = self[index]
        // Logger.branch.debug("Found: \(found.path)")
        branch.branches.forEach { found.branches.append(unique: $0) }
        branch.leaves.forEach { found.leaves.append($0) }
    }
}

