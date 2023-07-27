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
    struct SkaterRosterEntry : View {
        @Stat var skater: Skater
        var body: some View {
            HStack {
                Text(skater.rosterNumber ?? "N/A")
                Text(skater.name ?? "(Anonymous)")
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

