// ScoringTrip.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct ScoringTrip<P:PathSpecified> : PathNodeId, Identifiable {
    public var parent: P
    public var id: StatePath { statePath }
    public let statePath: StatePath
    @Leaf public var afterSP: Bool?

    @Leaf public var annotation: String?

    @Leaf public var current: Bool?

    @Leaf public var duration: Int?

    @ImmutableLeaf public var tripId: UUID?

    @Leaf public var jamClockEnd: JamTime?

    @Leaf public var jamClockStart: JamTime?

    @Leaf public var next: UUID?

    @Leaf public var number: Int?

    @Leaf public var previous: UUID?

    @ImmutableLeaf public var readonly: Bool?

    @Leaf public var score: Int?

    public init(parent: P, _ key: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("ScoringTrip", id: key))

        _afterSP = parent.leaf("AfterSP")
        _annotation = parent.leaf("Annotation")
        _current = parent.leaf("Current")
        _duration = parent.leaf("Duration")
        _tripId = parent.leaf("Id").immutable
        _jamClockEnd = parent.leaf("JamClockEnd")
        _jamClockStart = parent.leaf("JamClockStart")
        _next = parent.leaf("Next")
        _number = parent.leaf("Number")
        _previous = parent.leaf("Previous")
        _readonly = parent.leaf("Readonly").immutable
        _score = parent.leaf("Score")
        _afterSP.parentPath = statePath
        _annotation.parentPath = statePath
        _current.parentPath = statePath
        _duration.parentPath = statePath
        _tripId.parentPath = statePath
        _jamClockEnd.parentPath = statePath
        _jamClockStart.parentPath = statePath
        _next.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _readonly.parentPath = statePath
        _score.parentPath = statePath
    }
    public init(parent: P, _ key: Int) {
        self.parent = parent
        statePath = parent.adding(.number("ScoringTrip", param: key))

        _afterSP = parent.leaf("AfterSP")
        _annotation = parent.leaf("Annotation")
        _current = parent.leaf("Current")
        _duration = parent.leaf("Duration")
        _tripId = parent.leaf("Id").immutable
        _jamClockEnd = parent.leaf("JamClockEnd")
        _jamClockStart = parent.leaf("JamClockStart")
        _next = parent.leaf("Next")
        _number = parent.leaf("Number")
        _previous = parent.leaf("Previous")
        _readonly = parent.leaf("Readonly").immutable
        _score = parent.leaf("Score")
        _afterSP.parentPath = statePath
        _annotation.parentPath = statePath
        _current.parentPath = statePath
        _duration.parentPath = statePath
        _tripId.parentPath = statePath
        _jamClockEnd.parentPath = statePath
        _jamClockStart.parentPath = statePath
        _next.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _readonly.parentPath = statePath
        _score.parentPath = statePath
    }
    public init(parent: P, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _afterSP = parent.leaf("AfterSP")
        _annotation = parent.leaf("Annotation")
        _current = parent.leaf("Current")
        _duration = parent.leaf("Duration")
        _tripId = parent.leaf("Id").immutable
        _jamClockEnd = parent.leaf("JamClockEnd")
        _jamClockStart = parent.leaf("JamClockStart")
        _next = parent.leaf("Next")
        _number = parent.leaf("Number")
        _previous = parent.leaf("Previous")
        _readonly = parent.leaf("Readonly").immutable
        _score = parent.leaf("Score")
        _afterSP.parentPath = statePath
        _annotation.parentPath = statePath
        _current.parentPath = statePath
        _duration.parentPath = statePath
        _tripId.parentPath = statePath
        _jamClockEnd.parentPath = statePath
        _jamClockStart.parentPath = statePath
        _next.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _readonly.parentPath = statePath
        _score.parentPath = statePath
    }
}
extension Jam {
    public func scoringTrip(_ key: UUID) -> ScoringTrip<Jam> { .init(parent: self, key) }
}
extension TeamJam {
    public func scoringTrip(_ key: UUID) -> ScoringTrip<TeamJam> { .init(parent: self, key) }
}
extension Jam {
    public func scoringTrip(_ key: Int) -> ScoringTrip<Jam> { .init(parent: self, key) }
}
extension TeamJam {
    public func scoringTrip(_ key: Int) -> ScoringTrip<TeamJam> { .init(parent: self, key) }
}
