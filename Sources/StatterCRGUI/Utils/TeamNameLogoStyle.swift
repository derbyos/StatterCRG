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

/// How should team names be displayed
public enum TeamNameStyle {
    /// Display the league name only
    case leagueName
    /// Display the team name (appropriate for the AlternateNameType style)
    case teamName
    /// Display a full name of league & team
    case fullName
    /// Display the team's color
    case color
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
        AnyView(WithStat(team) { team in
            style.body(for: team)
        })
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
    
}

/// Make a vew wrapped around watch the stat change
public struct WithStat<P:PathSpecified, C:View> : View {
    var content: (P)->C
    @Stat var stat: P
    public init(_ stat: P, @ViewBuilder content: @escaping (P) -> C) {
        _stat = .init(wrappedValue: stat)
        self.content = content
    }
    public var body: some View {
        content(stat)
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
        WithStat(team) { team in
            VStack(alignment: .center) {
                NameOnlyStyle(nameStyle).body(for: team)
                LogoOnlyStyle().body(for: team)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

public struct LogoOrNameStyle : TeamNameLogoStyle {
    public init(_ nameStyle: TeamNameStyle = .teamName) {
        self.nameStyle = nameStyle
    }

    var nameStyle: TeamNameStyle
    @ViewBuilder public func body(for team: Team) -> some View {
        WithStat(team) { team in
            VStack(alignment: .center) {
                if team.logo != nil {
                    LogoOnlyStyle().body(for: team)
                } else {
                    NameOnlyStyle(nameStyle).body(for: team)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension Team {
    public func name(for type: AlternateNameType) -> String? {
        switch type {
        case .operator: return alternateName[.operator]
        case .scoreboard: return alternateName[.scoreboard]
        case .whiteboard: return alternateName[.whiteboard]
        case .overlay: return alternateName[.overlay]
        case .database: return name
        }
    }
}
public struct NameOnlyStyle : TeamNameLogoStyle {
    public init(_ nameStyle: TeamNameStyle) {
        self.nameStyle = nameStyle
    }
    
    var nameStyle: TeamNameStyle
    struct TeamNameView: View {
        @Stat var team: Team
        @Environment(\.alternateNameType) var altType
        var body: some View {
            if let name = team.name(for: altType) ?? team.name {
                Text(name)
            }
        }
    }
    
    @ViewBuilder public func body(for team: Team) -> some View {
        WithStat(team) { team in
            switch nameStyle {
            case .leagueName:
                if let name = team.leagueName {
                    Text(name)
                } else { // fallback to team name
                    TeamNameView(team: team)
                }
            case .fullName:
                if let name = team.fullName {
                    Text(name)
                } else { // fallback to team name
                    TeamNameView(team: team)
                }
            case .teamName:
                TeamNameView(team: team)
            case .color:
                if let name = team.color[.init(role: nil, component: .fg)] {
                    Text(name)
                } else { // fallback to team name
                    TeamNameView(team: team)
                }
            }
        }
    }
}

public struct AssetView: View {
    @EnvironmentObject var connection: Connection
    var path: String?
    public init(path: String?) {
        self.path = path
    }
    
    public var body: some View {
        if let url = connection.url(for:path) {
            AsyncImage(url: url) {
                $0.image?.resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
public struct LogoOnlyStyle : TeamNameLogoStyle {
    @ViewBuilder public func body(for team: Team) -> some View {
        WithStat(team) { team in
            AssetView(path: team.logo)
        }
    }
}

public struct DefaultTeamNameLogoStyle : TeamNameLogoStyle {
    @ViewBuilder public func body(for team: Team) -> some View {
        WithStat(team) { team in
            NameAndLogoStyle()
                .body(for: team)
        }
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


public extension TeamNameLogoStyle where Self == LogoOrNameStyle {
    
    static func logoOrName(_ nameStyle: TeamNameStyle = .teamName) -> LogoOrNameStyle {
        LogoOrNameStyle(nameStyle)
    }
}
