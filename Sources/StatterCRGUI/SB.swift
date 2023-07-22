//
//  SB.swift
//  Statter
//
//  Created by gandreas on 7/22/23.
//

import SwiftUI

@ViewBuilder
func FlipGroup<V1: View, V2: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1))
    }
}
@ViewBuilder
func FlipGroup<V1: View, V2: View, V3: View>(if value: Bool,
                @ViewBuilder _ content: @escaping () -> TupleView<(V1, V2, V3)>) -> some View {
    let pair = content()
    if value {
        TupleView((pair.value.2, pair.value.1, pair.value.0))
    } else {
        TupleView((pair.value.0, pair.value.1, pair.value.2))
    }
}

struct SB: View {
    struct TeamNameLogo : View {
        @EnvironmentObject var connection: Connection
        var team: Team
        var body: some View {
            Text(team.name ?? team.uniformColor ?? "Team \(team.team)")
                .font(.largeTitle)
        }
    }
    enum TimeoutDot : View {
        case unused
        case used
        case retained
        var body: some View {
            switch self {
            case .unused: Image(systemName: "circle.fill")
            case .used: Image(systemName: "circle")
            case .retained: Image(systemName: "plus.circle.fill")
            }
        }
    }
    struct Timeouts : View {
        @EnvironmentObject var connection: Connection
        var team: Team
        var body: some View {
            VStack {
                VStack {
                    ForEach(0..<3) {
                        if $0 < (team.timeouts ?? 0) {
                            TimeoutDot.unused
                        } else {
                            TimeoutDot.used
                        }
                    }
                }
                .padding(2)
                .border(.primary)
                Group {
                    if let officialReviews = team.officialReviews, officialReviews > 0 {
                        if team.retainedOfficialReview == true {
                            TimeoutDot.retained
                        } else {
                            TimeoutDot.unused
                        }
                    } else {
                        TimeoutDot.used
                    }
                }
                .padding(2)
                .border(.primary)
            }
        }
    }
    struct TeamDisplay : View {
        @EnvironmentObject var connection: Connection
        var team: Team
        var leftSide: Bool
        var showJammer: Bool
        var body: some View {
            VStack {
                TeamNameLogo(team: team)
                HStack {
                    FlipGroup(if: !leftSide) {
                        Timeouts(team: team)
                        Text("\(team.score ?? 0)")
                            .font(.largeTitle)
                        Text("\(team.jamScore ?? 0)")
                    }
                }
                if showJammer && team.displayLead == true {
                    Text("Lead")
                } else {
                    Text("")
                }
            }
        }
    }
    @EnvironmentObject var connection: Connection
    var game: Game
    
    struct TimeDisplay : View {
        @EnvironmentObject var connection: Connection
        var game: Game
        var body: some View {
            if game.intermissionClock.running == true {
                Text("Intermission \(game.intermissionClock.time.timeValue)")
            } else if game.timeOutClock.running == true || game.lineupClock.running == true {
                HStack {
                    Text(game.periodClock.time.timeValue)
                    if let period = game.currentPeriodNumber {
                        Text("P\(period)")
                        Text("J\(game.period(period).currentJamNumber ?? 0)")
                    }
                }
                HStack {
                    if game.lineupClock.running == true {
                        Text("Lineup")
                        Text(game.lineupClock.time.timeValue)
                    } else {
                        Text(game.officialReview == true ? "OR" : "TO")
                        Text(game.timeOutClock.time.timeValue)
                    }
                }
            } else if let period = game.currentPeriodNumber {
                #if os(watchOS)
                HStack { Text("Period \(period)")
                    Text(game.periodClock.time.timeValue)
                }
                HStack { Text("Jam \(game.period(period).currentJamNumber ?? 0)")
                    Text(game.jamClock.time.timeValue)
                }
                #else
                GroupBox("Period \(period)") {
                    Text(game.periodClock.time.timeValue)
                }
                GroupBox("Jam \(game.period(period).currentJamNumber ?? 0)") {
                    Text(game.jamClock.time.timeValue)
                }
                #endif
            }

        }
    }
    #if os(watchOS)
    var body: some View {
        List {
            VStack(alignment: .center) {
                TimeDisplay(game: game)
            }
            TeamDisplay(team: game.teamOne, leftSide: false, showJammer: game.inJam == true)
            TeamDisplay(team: game.teamTwo, leftSide: false, showJammer: game.inJam == true)
        }
        .listStyle(.carousel)
    }
    #else
    var body: some View {
        VStack {
            HStack {
                TeamDisplay(team: game.teamOne, leftSide: true, showJammer: game.inJam == true)
                Divider()
                TeamDisplay(team: game.teamTwo, leftSide: false, showJammer: game.inJam == true)
            }
            Divider()
            HStack {
                TimeDisplay(game: game)
            }
        }
    }
    #endif
}

