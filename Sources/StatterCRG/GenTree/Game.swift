// Game.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct Game : PathNodeId, Identifiable {
    public var parent: ScoreBoard
    public var id: UUID? { UUID.from(component: statePath.last)?.1 }
    public let statePath: StatePath
    @ImmutableLeaf public var readonly: Bool?

    

    // Only valid in CurrentGame

    @Leaf public var game: UUID?

    

    @ImmutableLeaf public var name: String?

    public enum PreparedState: String, EnumStringAsID {
        case prepared = "Prepared"
        case running = "Running"
        case finished = "Finished"
    }
    @ImmutableLeaf public var state: PreparedState?

    

    public var teamOne: Team { team(1) }
    public var teamTwo: Team { team(2) }
    public var periodClock: Clock { clock(.period) }
    public var jamClock: Clock { clock(.jam) }
    public var lineupClock: Clock { clock(.lineup) }
    public var timeOutClock: Clock { clock(.timeOut) }
    public var intermissionClock: Clock { clock(.intermission) }
    

    @ImmutableLeaf public var currentPeriodNumber: Int?

    @ImmutableLeaf public var currentPeriod: Int?

    @ImmutableLeaf public var currentTimout: UUID?

    @ImmutableLeaf public var inPeriod: Bool?

    @Leaf public var officialScore: Bool?

    

    @ImmutableLeaf public var inJam: Bool?

    @ImmutableLeaf public var inOvertime: Bool?

    @ImmutableLeaf public var inSuddenScoring: Bool?

    @ImmutableLeaf public var injuryContinuationUpcoming: Bool?

    @Leaf public var officialReview: Bool?

    

    @ImmutableLeaf public var upcomingJam: UUID?

    @ImmutableLeaf public var upcomingJamNumber: Int?

    @Leaf public var timeoutOwner: UUID?

    @Leaf public var noMoreJam: Bool?

    @Leaf public var officalScore: Bool?

    @Leaf public var abortReason: String?

    @Leaf public var ruleset: UUID?

    @ImmutableLeaf public var rulesetName: String?

    @Leaf public var headNso: UUID?

    @Leaf public var headRef: UUID?

    @Leaf public var suspensionsServed: String?

    @Leaf public var clockDuringFinalScore: Bool?

    

    // These are commands, not state

    public func startJam() { connection.set(key: statePath.adding("StartJam"), value: .bool(true), kind: .set) }
    public func stopJam() { connection.set(key: statePath.adding("StopJam"), value: .bool(true), kind: .set) }
    public func timeout() { connection.set(key: statePath.adding("Timeout"), value: .bool(true), kind: .set) }
    public func officialTimeout() { connection.set(key: statePath.adding("OfficialTimeout"), value: .bool(true), kind: .set) }
    public func startOvertime() { connection.set(key: statePath.adding("StartOvertime"), value: .bool(true), kind: .set) }
    public func clockUndo() { connection.set(key: statePath.adding("ClockUndo"), value: .bool(true), kind: .set) }
    public func clockReplace() { connection.set(key: statePath.adding("ClockReplace"), value: .bool(true), kind: .set) }
    

    // MARK: Exporting

    public func export() { connection.set(key: statePath.adding("Export"), value: .bool(true), kind: .set) }
    @ImmutableLeaf public var updateInProgress: Bool?

    @Leaf public var statsbookExists: Bool?

    @Leaf public var jsonExists: Bool?

    @ImmutableLeaf public var exportBlockedBy: String?

    

    public typealias PenaltyCode_Map = MapValueCollection<String, String>
    public var penaltyCode:PenaltyCode_Map { .init(connection: connection, statePath: self.adding(.wild("PenaltyCode"))) }

    public typealias Label_Map = MapValueCollection<String, UUID>
    public var label:Label_Map { .init(connection: connection, statePath: self.adding(.wild("Label"))) }

    public typealias EventInfo_Map = MapValueCollection<String, UUID>
    public var eventInfo:EventInfo_Map { .init(connection: connection, statePath: self.adding(.wild("EventInfo"))) }

    public init(parent: ScoreBoard, id: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("Game", id: id))

        _readonly = parent.leaf("Readonly").immutable
        _game = parent.leaf("Game")
        _name = parent.leaf("Name").immutable
        _state = parent.leaf("State").immutable
        _currentPeriodNumber = parent.leaf("CurrentPeriodNumber").immutable
        _currentPeriod = parent.leaf("CurrentPeriod").immutable
        _currentTimout = parent.leaf("CurrentTimout").immutable
        _inPeriod = parent.leaf("InPeriod").immutable
        _officialScore = parent.leaf("OfficialScore")
        _inJam = parent.leaf("InJam").immutable
        _inOvertime = parent.leaf("InOvertime").immutable
        _inSuddenScoring = parent.leaf("InSuddenScoring").immutable
        _injuryContinuationUpcoming = parent.leaf("InjuryContinuationUpcoming").immutable
        _officialReview = parent.leaf("OfficialReview")
        _upcomingJam = parent.leaf("UpcomingJam").immutable
        _upcomingJamNumber = parent.leaf("UpcomingJamNumber").immutable
        _timeoutOwner = parent.leaf("TimeoutOwner")
        _noMoreJam = parent.leaf("NoMoreJam")
        _officalScore = parent.leaf("OfficalScore")
        _abortReason = parent.leaf("AbortReason")
        _ruleset = parent.leaf("Ruleset")
        _rulesetName = parent.leaf("RulesetName").immutable
        _headNso = parent.leaf("HeadNso")
        _headRef = parent.leaf("HeadRef")
        _suspensionsServed = parent.leaf("SuspensionsServed")
        _clockDuringFinalScore = parent.leaf("ClockDuringFinalScore")
        _updateInProgress = parent.leaf("UpdateInProgress").immutable
        _statsbookExists = parent.leaf("StatsbookExists")
        _jsonExists = parent.leaf("JsonExists")
        _exportBlockedBy = parent.leaf("ExportBlockedBy").immutable
        _readonly.parentPath = statePath
        _game.parentPath = statePath
        _name.parentPath = statePath
        _state.parentPath = statePath
        _currentPeriodNumber.parentPath = statePath
        _currentPeriod.parentPath = statePath
        _currentTimout.parentPath = statePath
        _inPeriod.parentPath = statePath
        _officialScore.parentPath = statePath
        _inJam.parentPath = statePath
        _inOvertime.parentPath = statePath
        _inSuddenScoring.parentPath = statePath
        _injuryContinuationUpcoming.parentPath = statePath
        _officialReview.parentPath = statePath
        _upcomingJam.parentPath = statePath
        _upcomingJamNumber.parentPath = statePath
        _timeoutOwner.parentPath = statePath
        _noMoreJam.parentPath = statePath
        _officalScore.parentPath = statePath
        _abortReason.parentPath = statePath
        _ruleset.parentPath = statePath
        _rulesetName.parentPath = statePath
        _headNso.parentPath = statePath
        _headRef.parentPath = statePath
        _suspensionsServed.parentPath = statePath
        _clockDuringFinalScore.parentPath = statePath
        _updateInProgress.parentPath = statePath
        _statsbookExists.parentPath = statePath
        _jsonExists.parentPath = statePath
        _exportBlockedBy.parentPath = statePath
    }
    public init(parent: ScoreBoard, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _readonly = parent.leaf("Readonly").immutable
        _game = parent.leaf("Game")
        _name = parent.leaf("Name").immutable
        _state = parent.leaf("State").immutable
        _currentPeriodNumber = parent.leaf("CurrentPeriodNumber").immutable
        _currentPeriod = parent.leaf("CurrentPeriod").immutable
        _currentTimout = parent.leaf("CurrentTimout").immutable
        _inPeriod = parent.leaf("InPeriod").immutable
        _officialScore = parent.leaf("OfficialScore")
        _inJam = parent.leaf("InJam").immutable
        _inOvertime = parent.leaf("InOvertime").immutable
        _inSuddenScoring = parent.leaf("InSuddenScoring").immutable
        _injuryContinuationUpcoming = parent.leaf("InjuryContinuationUpcoming").immutable
        _officialReview = parent.leaf("OfficialReview")
        _upcomingJam = parent.leaf("UpcomingJam").immutable
        _upcomingJamNumber = parent.leaf("UpcomingJamNumber").immutable
        _timeoutOwner = parent.leaf("TimeoutOwner")
        _noMoreJam = parent.leaf("NoMoreJam")
        _officalScore = parent.leaf("OfficalScore")
        _abortReason = parent.leaf("AbortReason")
        _ruleset = parent.leaf("Ruleset")
        _rulesetName = parent.leaf("RulesetName").immutable
        _headNso = parent.leaf("HeadNso")
        _headRef = parent.leaf("HeadRef")
        _suspensionsServed = parent.leaf("SuspensionsServed")
        _clockDuringFinalScore = parent.leaf("ClockDuringFinalScore")
        _updateInProgress = parent.leaf("UpdateInProgress").immutable
        _statsbookExists = parent.leaf("StatsbookExists")
        _jsonExists = parent.leaf("JsonExists")
        _exportBlockedBy = parent.leaf("ExportBlockedBy").immutable
        _readonly.parentPath = statePath
        _game.parentPath = statePath
        _name.parentPath = statePath
        _state.parentPath = statePath
        _currentPeriodNumber.parentPath = statePath
        _currentPeriod.parentPath = statePath
        _currentTimout.parentPath = statePath
        _inPeriod.parentPath = statePath
        _officialScore.parentPath = statePath
        _inJam.parentPath = statePath
        _inOvertime.parentPath = statePath
        _inSuddenScoring.parentPath = statePath
        _injuryContinuationUpcoming.parentPath = statePath
        _officialReview.parentPath = statePath
        _upcomingJam.parentPath = statePath
        _upcomingJamNumber.parentPath = statePath
        _timeoutOwner.parentPath = statePath
        _noMoreJam.parentPath = statePath
        _officalScore.parentPath = statePath
        _abortReason.parentPath = statePath
        _ruleset.parentPath = statePath
        _rulesetName.parentPath = statePath
        _headNso.parentPath = statePath
        _headRef.parentPath = statePath
        _suspensionsServed.parentPath = statePath
        _clockDuringFinalScore.parentPath = statePath
        _updateInProgress.parentPath = statePath
        _statsbookExists.parentPath = statePath
        _jsonExists.parentPath = statePath
        _exportBlockedBy.parentPath = statePath
    }
}
extension ScoreBoard {
    public func game(_ id: UUID) -> Game { .init(parent: self, id: id) }
}
