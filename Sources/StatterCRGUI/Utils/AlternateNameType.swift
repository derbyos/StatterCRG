//
//  File.swift
//  
//
//  Created by gandreas on 7/25/23.
//

import Foundation
import SwiftUI
import StatterCRG

/// An enum specifying what sort of presention we are for.  This is used to support
/// the alternate name style
public enum AlternateNameType : Equatable {
    /// Display the alternate name for operator
    case `operator`
    /// Display the alternate name for overlay
    case overlay
    /// Display the alternate name for scoreboard
    case scoreboard
    /// Display the alternate name for whiteboard
    case whiteboard
    /// Display the standard (no alternate) name
    case database
}

extension AlternateNameType {
    var asTeamAlternateName: Team.AlternateName? {
        switch self {
        case .overlay: return .overlay
        case .operator: return .operator
        case .scoreboard: return .scoreboard
        case .whiteboard: return .whiteboard
        case .database: return nil
        }
    }
}

struct AlternateNameTypeEnvironmentKey: EnvironmentKey {
    typealias Value = AlternateNameType
    
    static var defaultValue: AlternateNameType = .database
}

extension EnvironmentValues {
    var alternateNameType : AlternateNameType {
        get {
            self[AlternateNameTypeEnvironmentKey.self]
        }
        set {
            self[AlternateNameTypeEnvironmentKey.self] = newValue
        }
    }
}

public extension View {
    func alternateNameType(_ alternateNameType: AlternateNameType) -> some View {
        self.environment(\.alternateNameType, alternateNameType)
    }
}
