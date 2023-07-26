//
//  ContentView.swift
//  Statter
//
//  Created by gandreas on 7/25/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

struct ContentView: View {
    @EnvironmentObject var scoreboard: Connection
    @State var search: String = ""
    var body: some View {
        VStack {
            if !scoreboard.isConnected {
                Text("Not Connected")
                    .padding()
            } else {
                HStack {
                    if let devName = scoreboard.deviceName {
                        Text(devName)
                        Spacer()
                    }
                    if let game = scoreboard.game {
                        Text("Current Game \(game.game?.uuidString ?? "<Fetching>")")
                    } else {
                        Text("No current game")
                    }
                }
                .padding()
            }
            List {
                ForEach(scoreboard.state.enumerated().filter{
                    if search == "" {
                        return true
                    }
                    return $0.element.key.description.localizedCaseInsensitiveContains(search) || $0.element.value.description.localizedCaseInsensitiveContains(search)
                }, id:\.offset) {
                    let entry = $0.element
                    HStack {
                        Text("\(entry.key.description)")
                        Spacer()
                        Text("\(entry.value.description)")
                    }
                }
            }
            .searchable(text: $search)
            switch scoreboard.source {
            case .sbo:
                if let game = scoreboard.game {
                HStack {
                        Text("Period: \(game.periodClock.time.timeValue)")
                        Text("Jam: \(game.jamClock.time.timeValue)")
                        Text("Timeout: \(game.timeOutClock.time.timeValue)")
                }
                HStack {
                    Text("Team 1: \(game.teamOne.score ?? 0)")
                    Text("Team 2: \(game.teamTwo.score ?? 0)")
                }
                }
            case .sb:
                if let game = scoreboard.game {
                    SB(game: game)
                }
            case .jt:
                if let game = scoreboard.game {
                    JT(game: game)
                }
            default:
                EmptyView()
            }
            Picker("Role", selection: $scoreboard.source) {
                Text("Root").tag(Connection.Source.root)
                Text("SB").tag(Connection.Source.sb)
                Text("SBO").tag(Connection.Source.sbo)
                Text("JT").tag(Connection.Source.jt)
            }
            .pickerStyle(.automatic)
            .padding()
            .disabled(scoreboard.game == nil)
        }
        .onAppear {
            scoreboard.connect()
        }
//        .onChange(of: scoreboard.game) { newValue in
//            if scoreboard.game != nil {
//                scoreboard.registerSBO()
//            }
//        }
    }
}
