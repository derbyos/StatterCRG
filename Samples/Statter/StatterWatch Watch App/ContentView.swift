//
//  ContentView.swift
//  StatterWatch Watch App
//
//  Created by gandreas on 7/25/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

struct ContentView: View {
    @EnvironmentObject var scoreboard: Connection
    var body: some View {
        Group {
            if let game = scoreboard.game {
                TabView {
                    SB(game: game)
                    JT(game: game)
                    List {
                        Roster(team: game.teamOne)
                    }
                    List {
                        Roster(team: game.teamTwo)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
        .onAppear {
            scoreboard.connect()
            scoreboard.debugFlags = [.registering, .incoming]
        }
    }
}
