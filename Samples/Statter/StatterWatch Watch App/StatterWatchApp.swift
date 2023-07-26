//
//  StatterWatchApp.swift
//  StatterWatch Watch App
//
//  Created by gandreas on 7/25/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

@main
struct StatterWatch_Watch_AppApp: App {
    var scoreboard: Connection = .init(host: "10.0.0.10")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreboard)
                .timeoutStyle(.vertical(separated: false))
                .timeoutDotStyle(.square())
                .teamNameLogo(.nameOnly(.teamName))
                .alternateNameType(.operator)
                .formFactorFontName("Times New Roman")
        }
    }
}
