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
    var scoreboard: Connection = {
        let retval = Connection(host: "10.0.0.10")
        retval.debugFlags.insert(.registering)
        retval.debugFlags.insert(.incoming)
        return retval
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scoreboard) 
        }
    }
}
