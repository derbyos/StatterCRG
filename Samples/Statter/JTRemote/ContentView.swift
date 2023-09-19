//
//  ContentView.swift
//  JTRemote
//
//  Created by gandreas on 9/19/23.
//

import SwiftUI
import StatterCRG
import StatterCRGUI

enum JTActions : String, RemoteControlAction {
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
    @State var configureRemote: Bool = false
    @State var connect: Bool = false
    @StateObject var remote: RemoteControl<JTActions> = .init()
    @State var config = Connection.ConnectionRecord(host:"")
    
    struct CurrentGameView : View {
        init(game: Game) {
            _game = .init(wrappedValue:game)
        }
        
        @EnvironmentObject var connection: Connection
        @Stat var game: Game
        
        var body: some View {
            HStack {
                TimeDisplay(game: game)
            }
        }
    }
    
    struct GameControls: View {
        init(game: Game) {
            _game = .init(wrappedValue:game)
        }
        
        @Stat var game: Game
        @EnvironmentObject var remote: RemoteControl<JTActions>

        func perform(action: JTActions) {
            switch action {
            case .startJam:
                game.startJam()
            case .stopJam:
                game.stopJam()
            case .startTimeOut:
                game.timeout()
            case .undo:
                game.clockUndo()
            case .team1TO:
                game.teamOne.timeout()
            case .team2TO:
                game.teamTwo.timeout()
            case .oto:
                game.officialTimeout()
            }
        }

        var body: some View {
            VStack {
                if game.timeOutClock.running == true {
                    if game.officialReview == true {
                        if game.teamOne.inOfficialReview == true {
                            HStack {
                                Button {
                                    game.teamOne.retainedOfficialReview = true
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                Button {
                                    game.teamOne.retainedOfficialReview = false
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        } else if game.teamTwo.inOfficialReview == true {
                            HStack {
                                Button {
                                    game.teamTwo.retainedOfficialReview = true
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                Button {
                                    game.teamTwo.retainedOfficialReview = false
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                    HStack {
                        Button {
                            perform(action: .team1TO)
                        } label: {
                            LabelForAction(title: {
                                Text("1.square")
                            }, action: JTActions.team1TO)
                        }
                        Button {
                            game.teamOne.officialReview()
                        } label: {
                            Image(systemName: "o.square")
                        }
                        
                        Divider()
                        
                        Button {
                            game.teamTwo.officialReview()
                        } label: {
                            Image(systemName: "o.square")
                        }
                        Button {
                            perform(action: .team2TO)
                        } label: {
                            LabelForAction(title: {
                                Text("2.square")
                            }, action: JTActions.team2TO)
                        }
                    }
                }
                HStack {
                    Button {
                        if game.jamClock.running == true {
                            perform(action: .stopJam)
                        } else {
                            perform(action: .startJam)
                        }
                    } label: {
                        LabelForAction(title: {
                            if game.jamClock.running == true {
                                Image(systemName: "stop.fill")
                            } else {
                                Image(systemName: "play.fill")
                            }
                        }, action: game.jamClock.running == true ? JTActions.stopJam : JTActions.startJam)
                    }
                    if game.timeOutClock.running == true {
                        Button {
                            perform(action: .oto)
                        } label: {
                            LabelForAction(title: {
                                Text("OTO")
                            }, action: JTActions.oto)
                        }
                    } else {
                        Button {
                            perform(action: .startTimeOut)
                        } label: {
                            LabelForAction(title: {
                                Image(systemName: "pause.fill")
                            }, action: JTActions.startTimeOut)
                        }
                    }
                }
            }
            .onReceive(remote.actionReceived, perform: { action in
                perform(action: action)
            })
        }
    }
    @StateObject var connection: Connection = .init()
    var body: some View {
        PocketMode { unlocked in
            Button("Connection...") {
                connect.toggle()
            }
            .sheet(isPresented: $connect, content: {
                NavigationStack {
                    SelectAddress(connection: $config)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Connect") {
                                    connect.toggle()
                                    connection.configure(record: config)
                                    // this will connect us
                                    connection.source = .jt
                                }
                                .disabled(config.host.isEmpty)
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    connect.toggle()
                                }
                            }
                        }
                }
            })
            if let game = connection.game {
                CurrentGameView(game: game)
            } else {
                Text("No Current Game")
            }

            Spacer()
            if let game = connection.game {
                GameControls(game: game)
                    .environmentObject(remote)
            }
            Button("Configure Remote") {
                configureRemote.toggle()
            }
            .sheet(isPresented: $configureRemote, content: {
                ConfigureRemote(remote: remote)
            })
            .onChange(of: configureRemote) { _ in
                if configureRemote {
                    remote.state = .ignoringEvents
                } else {
                    remote.state = .sendAction
                }
            }
            .onAppear {
                remote.state = .sendAction
            }
        }
    }
}

#Preview {
    ContentView()
}
