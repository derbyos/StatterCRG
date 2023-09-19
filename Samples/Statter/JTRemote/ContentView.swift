//
//  ContentView.swift
//  JTRemote
//
//  Created by gandreas on 9/19/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

enum Actions : String, RemoteControlAction {
    var description: String { rawValue }
    
    case startJam = "Start Jam"
    case stopJam = "Stop Jam"
    case startTimeOut = "Time Out"
    case undo = "Undo"
    case team1TO = "Team 1 Time Out"
    case team2TO = "Team 2 Time Out"
    case oto = "Offical Time Out"
}
struct ContentView: View {
    @State var configure: Bool = false
    @StateObject var remote: RemoteControl<Actions> = .init()
    var body: some View {
        PocketMode { unlocked in
            Button("Configure") {
                configure.toggle()
            }
            .sheet(isPresented: $configure, content: {
                ConfigureRemote(remote: remote)
            })
        }
    }
}

#Preview {
    ContentView()
}
