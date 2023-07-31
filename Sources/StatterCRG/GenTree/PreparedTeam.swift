// PreparedTeam.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct PreparedTeam : PathNodeId, Identifiable {
    public var parent: ScoreBoard
    public var id: UUID? { UUID.from(component: statePath.last)?.1 }
    public let statePath: StatePath
    @ImmutableLeaf public var readonly: Bool?

    @ImmutableLeaf public var name: String?

    @ImmutableLeaf public var fullName: String?

    @Leaf public var leagueName: String?

    @Leaf public var teamName: String?

    public typealias UniformColor_Map = MapValueCollection<String, UUID>
    public var uniformColor:UniformColor_Map { .init(connection: connection, statePath: self.adding(.wild("UniformColor"))) }

    @Leaf public var logo: String?

    public typealias AlternateName_Map = MapValueCollection<String, Team.AlternateName>
    public var alternateName:AlternateName_Map { .init(connection: connection, statePath: self.adding(.wild("AlternateName"))) }

    public typealias Color_Map = MapValueCollection<String, Team.AlternateName>
    public var color:Color_Map { .init(connection: connection, statePath: self.adding(.wild("Color"))) }

    public init(parent: ScoreBoard, id: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("PreparedTeam", id: id))

        _readonly = parent.leaf("Readonly").immutable
        _name = parent.leaf("Name").immutable
        _fullName = parent.leaf("FullName").immutable
        _leagueName = parent.leaf("LeagueName")
        _teamName = parent.leaf("TeamName")
        _logo = parent.leaf("Logo")
        _readonly.parentPath = statePath
        _name.parentPath = statePath
        _fullName.parentPath = statePath
        _leagueName.parentPath = statePath
        _teamName.parentPath = statePath
        _logo.parentPath = statePath
    }
    public init(parent: ScoreBoard, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _readonly = parent.leaf("Readonly").immutable
        _name = parent.leaf("Name").immutable
        _fullName = parent.leaf("FullName").immutable
        _leagueName = parent.leaf("LeagueName")
        _teamName = parent.leaf("TeamName")
        _logo = parent.leaf("Logo")
        _readonly.parentPath = statePath
        _name.parentPath = statePath
        _fullName.parentPath = statePath
        _leagueName.parentPath = statePath
        _teamName.parentPath = statePath
        _logo.parentPath = statePath
    }
}
extension ScoreBoard {
    public func preparedTeam(_ id: UUID) -> PreparedTeam { .init(parent: self, id: id) }
}