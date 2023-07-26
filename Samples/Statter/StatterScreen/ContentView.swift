//
//  ContentView.swift
//  StatterScreen
//
//  Created by gandreas on 7/26/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

struct ContentView: View {
    @EnvironmentObject var scoreboard: Connection
    var body: some View {
        Group {
            if let game = scoreboard.game {
                SB(game: game)
            }
        }
        .onAppear {
            scoreboard.connect()
        }
    }
}
