//
//  StatterScreenApp.swift
//  StatterScreen
//
//  Created by gandreas on 7/26/23.
//

import SwiftUI
import StatterCRG

@main
struct StatterScreenApp: App {
    var scoreboard: Connection = .init(host: "10.0.0.10")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreboard)
//                .timeoutStyle(.vertical(separated: false))
//                .timeoutDotStyle(.square())
                .teamNameLogo(.logoOrName())
                .alternateNameType(.scoreboard)
                .formFactorFontName("Times New Roman")
        }
    }
}
