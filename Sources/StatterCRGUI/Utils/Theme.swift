//
//  File.swift
//  
//
//  Created by gandreas on 7/24/23.
//

import Foundation
import SwiftUI

/// Defines the appearance of all the parts of the scoreboard
public class Theme: ObservableObject {
    public init() {
    }
    
    
    static public let generic = Theme()
}

extension Color {
    static var backgroundFill : Color {
        #if os(macOS)
        Color(NSColor.textBackgroundColor)
        #elseif os(watchOS)
        Color(UIColor.black)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}
