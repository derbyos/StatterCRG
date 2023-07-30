// Skater.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct Skater : PathNodeId, Identifiable {
    public var parent: Team
    public var id: UUID? { UUID.from(component: statePath.last)?.1 }
    public let statePath: StatePath
    public enum Role: String, EnumStringAsID {
        case bench = "Bench"
        case blocker = "Blocker"
        case pivot = "Pivot"
        case jammer = "Jammer"
    }
    public enum Flags: String, EnumStringAsID {
        case skater = ""
        case altSkater = "ALT"
        case bench = "B"
        case captain = "C"
        case benchAltCaptain = "BA"
        case altCaptain = "AC"
    }
    @Leaf public var flags: Flags?

    @Leaf public var name: String?

    @Leaf public var pronouns: String?

    @Leaf public var rosterNumber: String?

    @Leaf public var role: Role?

    public var penalties : MapNodeCollection<Self, Penalty> { .init(self,"Penalty") } 

    

    public init(parent: Team, id: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("Skater", id: id))

        _flags = parent.leaf("Flags")
        _name = parent.leaf("Name")
        _pronouns = parent.leaf("Pronouns")
        _rosterNumber = parent.leaf("RosterNumber")
        _role = parent.leaf("Role")
        _flags.parentPath = statePath
        _name.parentPath = statePath
        _pronouns.parentPath = statePath
        _rosterNumber.parentPath = statePath
        _role.parentPath = statePath
    }
    public init(parent: Team, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _flags = parent.leaf("Flags")
        _name = parent.leaf("Name")
        _pronouns = parent.leaf("Pronouns")
        _rosterNumber = parent.leaf("RosterNumber")
        _role = parent.leaf("Role")
        _flags.parentPath = statePath
        _name.parentPath = statePath
        _pronouns.parentPath = statePath
        _rosterNumber.parentPath = statePath
        _role.parentPath = statePath
    }
}
extension Team {
    public func skater(_ id: UUID) -> Skater { .init(parent: self, id: id) }
}
