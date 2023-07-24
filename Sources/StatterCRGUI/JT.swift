//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 7/22/23.
//

import SwiftUI
import StatterCRG

public struct JT: View {
    public init(game: Game) {
        self.game = game
    }
    
    @EnvironmentObject var connection: Connection
    var game: Game

    public var body: some View {
        VStack {
            #if os(watchOS)
            VStack {
                TimeDisplay(game: game)
            }
            #else
            HStack {
                TimeDisplay(game: game)
            }
            #endif
            Spacer()
            if game.timeOutClock.running == true {
                if game.teamOne.officialReview == true {
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
                } else if game.teamTwo.officialReview == true {
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
                HStack {
                    Button {
                        game.teamOne.timeout = true
                    } label: {
                        Image(systemName: "1.square")
                    }
                    Button {
                        game.teamOne.officialReview = true
                    } label: {
                        Image(systemName: "o.square")
                    }

                    Divider()

                    Button {
                        game.teamTwo.officialReview = true
                    } label: {
                        Image(systemName: "o.square")
                    }
                    Button {
                        game.teamTwo.timeout = true
                    } label: {
                        Image(systemName: "2.square")
                    }
                }
            }
            HStack {
                Button {
                    if game.jamClock.running == true {
                        game.stopJam()
                    } else {
                        game.startJam()
                    }
                } label: {
                    if game.jamClock.running == true {
                        Image(systemName: "stop.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                if game.timeOutClock.running == true {
                    Button {
                        game.officialTimeout()
                    } label: {
                        Text("OTO")
                    }
                } else {
                    Button {
                        game.timeout()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                }
            }
        }
    }
}

