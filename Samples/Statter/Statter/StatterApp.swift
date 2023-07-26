//
//  StatterApp.swift
//  Statter
//
//  Created by gandreas on 7/25/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI


@main
struct StatterApp: App {
    var scoreboard: Connection = .init(host: "10.0.0.10")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreboard)
        }
    }
}
