//
//  Branch.swift
//  CalendarSummary
//
//  Created by Mike Miklin on 22.03.2024.
//

import Foundation


protocol Leaf {
    var title: String! { get set }
    var duration: Int { get }
}
typealias Leaves = [Leaf]

class Branch: Identifiable {
    var id: String

    var level: Int = 0
    var branches: Branches! = []
    var parent: Branch!
    var leaves: Leaves = []

    var title: String!

    private init?(_ leaf: Leaf, level: Int) {
        let nodes = leaf.title.split()

        guard let title = nodes.dropFirst(level).first?.description.trim(),
              title.isEmpty == false
        else { return nil }

        self.id = nodes[0...level].joined()
        self.title = title
        self.level = level

        if let branch = Branch(leaf, level: level + 1) {
            branch.parent = self
            self.branches.append(unique: branch)
        } else {
            self.branches = nil
            self.leaves.append(leaf)
        }
    }
    init(leaves: Leaves = []) {
        self.id = "ROOT."
        self.level = -1
        self.title = "ROOT"
        self.update(leaves: leaves)
    }
    func update(leaves: Leaves, level: Int = 0) {
        leaves.forEach { leaf in
            guard let branch = Branch(leaf, level: level) else { return }
            branch.parent = self
            self.branches.append(unique: branch)
        }
    }
    var all: Leaves {
        return if self.leaves.isEmpty {
            self.branches.reduce([]) { $0 + $1.all }
        } else {
            self.leaves
        }
    }

    func rename(_ title: String) {
        guard let parent else { return }

        let leaves = self.all.map {
            var leaf = $0
            leaf.title.replace(title, position: level)
            return leaf
        }

        parent.branches.removeAll { $0.id == self.id }
        parent.update(leaves: leaves, level: self.level)
    }
}

extension Branch: Leaf {
    var duration: Int { self.all.reduce(0, { $0 + $1.duration }) }
    var expandable: Bool { self.branches != nil }
}

typealias Branches = [Branch]
extension Branches {
    mutating func append(unique branch: Branch) {
        guard let index = firstIndex(where: { $0.id == branch.id })
        else {
            return append(contentsOf: [branch])
        }

        branch.branches.forEach { self[index].branches.append(unique: $0) }
        branch.leaves.forEach { self[index].leaves.append($0) }
    }
}

