//
//  File.swift
//  
//
//  Created by gandreas on 7/25/23.
//

import Foundation
import SwiftUI
import StatterCRG


/// Provide a way to specify if the team name should reflect the color of the
/// team.  Note this also factors in the AlternateNameType
public enum ColorizeTeamName {
    case off
    case on // both halo/background
    case onWithHalo
    case onWithBackground
}
struct ColorizeTeamNameEnvironmentKey: EnvironmentKey {
    typealias Value = ColorizeTeamName
    
    static var defaultValue: ColorizeTeamName = .on
}

extension EnvironmentValues {
    var colorizeTeamName : ColorizeTeamName {
        get {
            self[ColorizeTeamNameEnvironmentKey.self]
        }
        set {
            self[ColorizeTeamNameEnvironmentKey.self] = newValue
        }
    }
}

struct ColorizeForTeam : ViewModifier {
    @Stat var team: Team
    @Environment(\.colorizeTeamName) var colorize
    @Environment(\.alternateNameType) var altType
    
    @ViewBuilder func addForeground<C:View>(content: C) -> some View {
        if let name = team.color[Team.Color(role: altType.asTeamAlternateName, component: .fg)], let color = Color(fromHex: name) {
            content.foregroundColor(color)
        } else {
            content
        }
    }
    @ViewBuilder func addHalo<C:View>(content: C) -> some View {
        if let name = team.color[Team.Color(role: altType.asTeamAlternateName, component: .glow)], let color = Color(fromHex: name) {
            content.shadow(color: color, radius: 3, x: 0, y: 0)
        } else {
            content
        }
    }
    @ViewBuilder func addBackground<C:View>(content: C) -> some View {
        if let name = team.color[Team.Color(role: altType.asTeamAlternateName, component: .bg)], let color = Color(fromHex: name) {
            content.background(color)
        } else {
            content
        }
    }
    @ViewBuilder func body(content: Content) -> some View {
        switch colorize {
        case .off:
            content
        case .on:
            addBackground(content: addHalo(content: addForeground(content: content)))
        case .onWithHalo:
            addHalo(content: addForeground(content: content))
        case .onWithBackground:
            addBackground(content: addForeground(content: content))
        }
    }
}
public extension View {
    func teamNameColorStyle(_ color: ColorizeTeamName) -> some View {
        self.environment(\.colorizeTeamName, color)
    }

    // Apply the fg/bg/halo based on the current colorize team name style
    func colorize(for team: Team) -> some View {
        self.modifier(ColorizeForTeam(team: team))
    }
}
