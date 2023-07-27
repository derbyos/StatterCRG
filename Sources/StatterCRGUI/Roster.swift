//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 7/27/23.
//

import SwiftUI
import StatterCRG

public struct Roster: View {
    public init(team: Team) {
        _team = .init(wrappedValue: team)
    }
    @Stat var team: Team
    struct PenaltyEntry: View {
        @Stat var penalty: Penalty
        var body: some View {
            if penalty.serving == true {
                Image(systemName: (penalty.code ?? "u").lowercased() + ".square.fill")
                //                        Image(systemName: "square")
            } else if penalty.served == true {
                Image(systemName: (penalty.code ?? "u").lowercased() + ".square")
            } else {
                Image(systemName: (penalty.code ?? "u").lowercased() + ".circle")
            }
        }
    }
    struct SkaterRosterEntry : View {
        @Stat var skater: Skater
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(skater.rosterNumber ?? "N/A")
                    Text(skater.name ?? "(Anonymous)")
                    Spacer()
                    if let role = skater.role {
                        Text(role.rawValue)
                    }
                }
                HStack {
                    ForEach(skater.penalties.allValues().sorted(by: {($0.number ?? 0) < ($1.number ?? 0)}), id: \.number) {
                        PenaltyEntry(penalty: $0)
                    }
                }
            }
        }
    }
    public var body: some View {
        let roster : [Skater] = team.skaters.allValues()
        ForEach(roster.sorted(by: {
            ($0.rosterNumber ?? $0.name ?? "-") < ($1.rosterNumber ?? $1.name ?? "-")
        })) {
            SkaterRosterEntry(skater: $0)
        }
    }
}

