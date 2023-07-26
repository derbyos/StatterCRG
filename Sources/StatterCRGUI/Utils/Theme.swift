//
//  File.swift
//  
//
//  Created by gandreas on 7/24/23.
//

import Foundation
import SwiftUI


extension Color {
    static var backgroundFill : Color {
        #if os(macOS)
        Color(NSColor.textBackgroundColor)
        #elseif os(watchOS)
        Color(UIColor.black)
        #elseif os(tvOS)
        Color(UIColor.black)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
    
    init?(fromHex hex: String?) {
        guard let hex else { return nil }
        let scanner = Scanner(string: hex)
        // skip optional leading hex, checking length
        if scanner.scanString("#") == nil {
            if hex.count != 6 {
                return nil
            }
        } else {
            if hex.count != 7 {
                return nil
            }
        }
        var rgbValue: UInt32 = 0
        if !scanner.scanHexInt32(&rgbValue) {
            return nil
        }
        self.init(red: Double((rgbValue & 0xFF0000) >> 16) / 255.0, green: Double((rgbValue & 0xFF00) >> 8) / 255.0, blue: Double(rgbValue & 0xFF) / 255.0)
    }
}
