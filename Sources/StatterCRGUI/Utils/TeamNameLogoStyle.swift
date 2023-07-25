//
//  File.swift
//  
//
//  Created by gandreas on 7/24/23.
//

import Foundation
import SwiftUI
import StatterCRG

public protocol TeamNameLogoStyle  {
    associatedtype Result: View
    @ViewBuilder func body(for: Team) -> Result
}

public enum TeamNameStyle {
    case leagueName
    case teamName
    case leagueAndTeamName
    case color
}

public enum DisplayType : Equatable {
    case `operator`
    case overlay
    case scoreboard
    case whiteboard
//    case other(String)
}
struct DisplayTypeEnvironmentKey: EnvironmentKey {
    typealias Value = DisplayType
    
    static var defaultValue: DisplayType = .operator
}

extension EnvironmentValues {
    var displayType : DisplayType {
        get {
            self[DisplayTypeEnvironmentKey.self]
        }
        set {
            self[DisplayTypeEnvironmentKey.self] = newValue
        }
    }
}


protocol AbstractTeamNameLogoStyle {
    func body(for: Team) -> AnyView
}
struct WrappedTeamNameLogoStyle<T:TeamNameLogoStyle>: AbstractTeamNameLogoStyle {
    var style: T
    init(style: T) {
        self.style = style
    }
    public func body(for team: Team) -> AnyView {
        AnyView(style.body(for: team))
    }
}

struct TeamNameLogoStyleEnvironmentKey: EnvironmentKey {
    typealias Value = AbstractTeamNameLogoStyle
    
    static var defaultValue: AbstractTeamNameLogoStyle = WrappedTeamNameLogoStyle(style:DefaultTeamNameLogoStyle())
}

extension EnvironmentValues {
    var teamNameLogoStyle : any AbstractTeamNameLogoStyle {
        get {
            self[TeamNameLogoStyleEnvironmentKey.self]
        }
        set {
            self[TeamNameLogoStyleEnvironmentKey.self] = newValue
        }
    }
}

public extension View {
    /// Apply a style to the team's name and logo
    /// - Parameter style: The style to use
    /// - Returns: Modified view with this style
    func teamNameLogo<S: TeamNameLogoStyle>(_ style:S) -> some View {
        self.environment(\.teamNameLogoStyle, WrappedTeamNameLogoStyle(style: style))
    }
    
    func displayType(_ displayType: DisplayType) -> some View {
        self.environment(\.displayType, displayType)
    }
}

public extension TeamNameLogoStyle where Self == DefaultTeamNameLogoStyle {
    
    static var `default`: DefaultTeamNameLogoStyle {
        DefaultTeamNameLogoStyle()
    }
}

public struct NameAndLogoStyle : TeamNameLogoStyle {
    public init(_ nameStyle: TeamNameStyle = .teamName) {
        self.nameStyle = nameStyle
    }

    var nameStyle: TeamNameStyle
    @ViewBuilder public func body(for team: Team) -> some View {
        VStack(alignment: .center) {
            NameOnlyStyle(nameStyle).body(for: team)
            LogoOnlyStyle().body(for: team)
        }
        .frame(maxWidth: .infinity)
    }
}

extension DisplayType {
    var asAlternateName: Team.AlternateName {
        switch self {
        case .operator: return .operator
        case .scoreboard: return .scoreboard
        case .whiteboard: return .whiteboard
        case .overlay: return .overlay
        }
    }
}
public struct NameOnlyStyle : TeamNameLogoStyle {
    public init(_ nameStyle: TeamNameStyle) {
        self.nameStyle = nameStyle
    }
    
    var nameStyle: TeamNameStyle
    struct TeamNameView: View {
        var team: Team
        @Environment(\.displayType) var display
        var body: some View {
            if let name = team.alternateName[display.asAlternateName] ?? team.name {
                Text(name)
            }
        }
    }
    
    @ViewBuilder public func body(for team: Team) -> some View {
        switch nameStyle {
        case .leagueName:
            if let name = team.leagueName {
                Text(name)
            }
        case .leagueAndTeamName:
            if let name = team.fullName {
                Text(name)
            }
        case .teamName:
            TeamNameView(team: team)
        case .color:
//            if let name = team.uniformColor {
//                Text(name)
//            }
            EmptyView()
        }
    }
}

public struct LogoOnlyStyle : TeamNameLogoStyle {
    @ViewBuilder public func body(for team: Team) -> some View {
        EmptyView()
    }
}

public struct DefaultTeamNameLogoStyle : TeamNameLogoStyle {
    @ViewBuilder public func body(for team: Team) -> some View {
        NameAndLogoStyle()
            .body(for: team)
    }
}



public extension TeamNameLogoStyle where Self == NameOnlyStyle {
    
    static func nameOnly(_ nameStyle: TeamNameStyle = .teamName) -> NameOnlyStyle {
        NameOnlyStyle(nameStyle)
    }
}

public extension TeamNameLogoStyle where Self == LogoOnlyStyle {
    
    static var logoOnly: LogoOnlyStyle {
        LogoOnlyStyle()
    }
}

public extension TeamNameLogoStyle where Self == NameAndLogoStyle {
    
    static func nameAndLogo(_ nameStyle: TeamNameStyle = .teamName) -> NameAndLogoStyle {
        NameAndLogoStyle(nameStyle)
    }
}
