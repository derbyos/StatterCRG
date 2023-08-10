// Jam.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct Jam<P:PathSpecified> : PathNodeId, Identifiable {
    public var parent: P
    public var id: StatePath { statePath }
    public let statePath: StatePath
    @ImmutableLeaf public var readonly: Bool?

    @ImmutableLeaf public var number: Int?

    @ImmutableLeaf public var previous: UUID?

    @ImmutableLeaf public var next: UUID?

    @ImmutableLeaf public var periodNumber: Int?

    @ImmutableLeaf public var starPass: Bool?

    @Leaf public var overtime: Bool?

    @Leaf public var injuryContinuation: Bool?

    @ImmutableLeaf public var duration: Int?

    @Leaf public var periodClockElapsedStart: Int?

    @Leaf public var periodClockElapsedEnd: Int?

    @Leaf public var periodClockDisplayEnd: Int?

    @Leaf public var walltimeStart: Int?

    @Leaf public var walltimeEnd: Int?

    public func delete() { connection.set(key: statePath.adding("Delete"), value: .bool(true), kind: .set) }
    public func insertBefore() { connection.set(key: statePath.adding("InsertBefore"), value: .bool(true), kind: .set) }
    public func insertTimeoutAfter() { connection.set(key: statePath.adding("InsertTimeoutAfter"), value: .bool(true), kind: .set) }
    @ImmutableLeaf public var jamId: UUID?

    @Leaf public var noInitial: Bool?

    @Leaf public var noPivot: Bool?

    @Leaf public var lead: Bool?

    @Leaf public var lost: Bool?

    @Leaf public var injury: Bool?

    @Leaf public var calloff: Bool?

    @Leaf public var starPassTrip: UUID?

    @Leaf public var totalScore: Int?

    @Leaf public var afterSPScore: Int?

    @Leaf public var jamScore: Int?

    @Leaf public var lastScore: Int?

    @Leaf public var displayLead: Bool?

    @Leaf public var currentTrip: Int?

    @Leaf public var osOffset: Int?

    @Leaf public var osOffsetReason: String?

    

    public enum Position: String, EnumStringAsID {
        case jammer = "Jammer"
        case pivot = "Pivot"
        case blocker1 = "Blocker1"
        case blocker2 = "Blocker2"
        case blocker3 = "Blocker3"
    }
    public var fieldings : MapNodeCollection<Self, Fielding<Self>, Position> { .init(self,"Fielding") } 

    public var scoringTripss : MapNodeCollection<Self, ScoringTrip<Self>, Int> { .init(self,"ScoringTrips") } 

    

    @ImmutableLeaf public var jamID: UUID?

    public init(parent: P, _ key: Int) {
        self.parent = parent
        statePath = parent.adding(.number("Jam", param: key))

        _readonly = parent.leaf("Readonly").immutable
        _number = parent.leaf("Number").immutable
        _previous = parent.leaf("Previous").immutable
        _next = parent.leaf("Next").immutable
        _periodNumber = parent.leaf("PeriodNumber").immutable
        _starPass = parent.leaf("StarPass").immutable
        _overtime = parent.leaf("Overtime")
        _injuryContinuation = parent.leaf("InjuryContinuation")
        _duration = parent.leaf("Duration").immutable
        _periodClockElapsedStart = parent.leaf("PeriodClockElapsedStart")
        _periodClockElapsedEnd = parent.leaf("PeriodClockElapsedEnd")
        _periodClockDisplayEnd = parent.leaf("PeriodClockDisplayEnd")
        _walltimeStart = parent.leaf("WalltimeStart")
        _walltimeEnd = parent.leaf("WalltimeEnd")
        _jamId = parent.leaf("jamId").immutable
        _noInitial = parent.leaf("NoInitial")
        _noPivot = parent.leaf("NoPivot")
        _lead = parent.leaf("Lead")
        _lost = parent.leaf("Lost")
        _injury = parent.leaf("Injury")
        _calloff = parent.leaf("Calloff")
        _starPassTrip = parent.leaf("StarPassTrip")
        _totalScore = parent.leaf("TotalScore")
        _afterSPScore = parent.leaf("AfterSPScore")
        _jamScore = parent.leaf("JamScore")
        _lastScore = parent.leaf("LastScore")
        _displayLead = parent.leaf("DisplayLead")
        _currentTrip = parent.leaf("CurrentTrip")
        _osOffset = parent.leaf("OsOffset")
        _osOffsetReason = parent.leaf("OsOffsetReason")
        _jamID = parent.leaf("jamID").immutable
        _readonly.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _next.parentPath = statePath
        _periodNumber.parentPath = statePath
        _starPass.parentPath = statePath
        _overtime.parentPath = statePath
        _injuryContinuation.parentPath = statePath
        _duration.parentPath = statePath
        _periodClockElapsedStart.parentPath = statePath
        _periodClockElapsedEnd.parentPath = statePath
        _periodClockDisplayEnd.parentPath = statePath
        _walltimeStart.parentPath = statePath
        _walltimeEnd.parentPath = statePath
        _jamId.parentPath = statePath
        _noInitial.parentPath = statePath
        _noPivot.parentPath = statePath
        _lead.parentPath = statePath
        _lost.parentPath = statePath
        _injury.parentPath = statePath
        _calloff.parentPath = statePath
        _starPassTrip.parentPath = statePath
        _totalScore.parentPath = statePath
        _afterSPScore.parentPath = statePath
        _jamScore.parentPath = statePath
        _lastScore.parentPath = statePath
        _displayLead.parentPath = statePath
        _currentTrip.parentPath = statePath
        _osOffset.parentPath = statePath
        _osOffsetReason.parentPath = statePath
        _jamID.parentPath = statePath
    }
    public init(parent: P, _ key: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("Jam", id: key))

        _readonly = parent.leaf("Readonly").immutable
        _number = parent.leaf("Number").immutable
        _previous = parent.leaf("Previous").immutable
        _next = parent.leaf("Next").immutable
        _periodNumber = parent.leaf("PeriodNumber").immutable
        _starPass = parent.leaf("StarPass").immutable
        _overtime = parent.leaf("Overtime")
        _injuryContinuation = parent.leaf("InjuryContinuation")
        _duration = parent.leaf("Duration").immutable
        _periodClockElapsedStart = parent.leaf("PeriodClockElapsedStart")
        _periodClockElapsedEnd = parent.leaf("PeriodClockElapsedEnd")
        _periodClockDisplayEnd = parent.leaf("PeriodClockDisplayEnd")
        _walltimeStart = parent.leaf("WalltimeStart")
        _walltimeEnd = parent.leaf("WalltimeEnd")
        _jamId = parent.leaf("jamId").immutable
        _noInitial = parent.leaf("NoInitial")
        _noPivot = parent.leaf("NoPivot")
        _lead = parent.leaf("Lead")
        _lost = parent.leaf("Lost")
        _injury = parent.leaf("Injury")
        _calloff = parent.leaf("Calloff")
        _starPassTrip = parent.leaf("StarPassTrip")
        _totalScore = parent.leaf("TotalScore")
        _afterSPScore = parent.leaf("AfterSPScore")
        _jamScore = parent.leaf("JamScore")
        _lastScore = parent.leaf("LastScore")
        _displayLead = parent.leaf("DisplayLead")
        _currentTrip = parent.leaf("CurrentTrip")
        _osOffset = parent.leaf("OsOffset")
        _osOffsetReason = parent.leaf("OsOffsetReason")
        _jamID = parent.leaf("jamID").immutable
        _readonly.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _next.parentPath = statePath
        _periodNumber.parentPath = statePath
        _starPass.parentPath = statePath
        _overtime.parentPath = statePath
        _injuryContinuation.parentPath = statePath
        _duration.parentPath = statePath
        _periodClockElapsedStart.parentPath = statePath
        _periodClockElapsedEnd.parentPath = statePath
        _periodClockDisplayEnd.parentPath = statePath
        _walltimeStart.parentPath = statePath
        _walltimeEnd.parentPath = statePath
        _jamId.parentPath = statePath
        _noInitial.parentPath = statePath
        _noPivot.parentPath = statePath
        _lead.parentPath = statePath
        _lost.parentPath = statePath
        _injury.parentPath = statePath
        _calloff.parentPath = statePath
        _starPassTrip.parentPath = statePath
        _totalScore.parentPath = statePath
        _afterSPScore.parentPath = statePath
        _jamScore.parentPath = statePath
        _lastScore.parentPath = statePath
        _displayLead.parentPath = statePath
        _currentTrip.parentPath = statePath
        _osOffset.parentPath = statePath
        _osOffsetReason.parentPath = statePath
        _jamID.parentPath = statePath
    }
    public init(parent: P, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _readonly = parent.leaf("Readonly").immutable
        _number = parent.leaf("Number").immutable
        _previous = parent.leaf("Previous").immutable
        _next = parent.leaf("Next").immutable
        _periodNumber = parent.leaf("PeriodNumber").immutable
        _starPass = parent.leaf("StarPass").immutable
        _overtime = parent.leaf("Overtime")
        _injuryContinuation = parent.leaf("InjuryContinuation")
        _duration = parent.leaf("Duration").immutable
        _periodClockElapsedStart = parent.leaf("PeriodClockElapsedStart")
        _periodClockElapsedEnd = parent.leaf("PeriodClockElapsedEnd")
        _periodClockDisplayEnd = parent.leaf("PeriodClockDisplayEnd")
        _walltimeStart = parent.leaf("WalltimeStart")
        _walltimeEnd = parent.leaf("WalltimeEnd")
        _jamId = parent.leaf("jamId").immutable
        _noInitial = parent.leaf("NoInitial")
        _noPivot = parent.leaf("NoPivot")
        _lead = parent.leaf("Lead")
        _lost = parent.leaf("Lost")
        _injury = parent.leaf("Injury")
        _calloff = parent.leaf("Calloff")
        _starPassTrip = parent.leaf("StarPassTrip")
        _totalScore = parent.leaf("TotalScore")
        _afterSPScore = parent.leaf("AfterSPScore")
        _jamScore = parent.leaf("JamScore")
        _lastScore = parent.leaf("LastScore")
        _displayLead = parent.leaf("DisplayLead")
        _currentTrip = parent.leaf("CurrentTrip")
        _osOffset = parent.leaf("OsOffset")
        _osOffsetReason = parent.leaf("OsOffsetReason")
        _jamID = parent.leaf("jamID").immutable
        _readonly.parentPath = statePath
        _number.parentPath = statePath
        _previous.parentPath = statePath
        _next.parentPath = statePath
        _periodNumber.parentPath = statePath
        _starPass.parentPath = statePath
        _overtime.parentPath = statePath
        _injuryContinuation.parentPath = statePath
        _duration.parentPath = statePath
        _periodClockElapsedStart.parentPath = statePath
        _periodClockElapsedEnd.parentPath = statePath
        _periodClockDisplayEnd.parentPath = statePath
        _walltimeStart.parentPath = statePath
        _walltimeEnd.parentPath = statePath
        _jamId.parentPath = statePath
        _noInitial.parentPath = statePath
        _noPivot.parentPath = statePath
        _lead.parentPath = statePath
        _lost.parentPath = statePath
        _injury.parentPath = statePath
        _calloff.parentPath = statePath
        _starPassTrip.parentPath = statePath
        _totalScore.parentPath = statePath
        _afterSPScore.parentPath = statePath
        _jamScore.parentPath = statePath
        _lastScore.parentPath = statePath
        _displayLead.parentPath = statePath
        _currentTrip.parentPath = statePath
        _osOffset.parentPath = statePath
        _osOffsetReason.parentPath = statePath
        _jamID.parentPath = statePath
    }
}
extension Period {
    public func jam(_ key: Int) -> Jam<Period> { .init(parent: self, key) }
}
extension Game {
    public func jam(_ key: Int) -> Jam<Game> { .init(parent: self, key) }
}
extension Period {
    public func jam(_ key: UUID) -> Jam<Period> { .init(parent: self, key) }
}
extension Game {
    public func jam(_ key: UUID) -> Jam<Game> { .init(parent: self, key) }
}
