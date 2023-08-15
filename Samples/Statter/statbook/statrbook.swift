//
//  main.swift
//  statbook
//
//  Created by gandreas on 8/15/23.
//

import Foundation
import ArgumentParser
import StatterCRG
import StatterBook

@main
struct StatRBook: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "statrbook",
        abstract: "A utility for CRG exported JSON statsbooks",
        version: "0.0.1",
        subcommands: [Times.self],
        defaultSubcommand: Times.self
    )
}

enum Errors : Error {
    case noGameInSBJSON
}
extension StatRBook {
    struct Times : ParsableCommand {
        @Option(name: [.customShort("j"), .customLong("json")], help: "The exported JSON file")
        var json: String
        
        mutating func run() throws {
            let jsonURL = URL(filePath: json)
            let jsonData = try Data(contentsOf: jsonURL)
            let connection = try Connection(game: jsonData)
            guard let game = connection.scoreBoard.games.allValues().first else {
                throw Errors.noGameInSBJSON
            }
            let events = game.timedEvents
            let allSkaters = game.allSkaters
            let allPenalties = game.allPenalties
            for event in events {
                switch event.event {
                case .periodStart(let p):
                    print("\(format(wallTime: event.time))\tPeriod Start \(p.number ?? 0)")
                case .periodEnd(let p):
                    print("\(format(wallTime: event.time))\tPeriod End \(p.number ?? 0)")
                case .jamStart(let j):
                    print("\(format(wallTime: event.time))\t\tJam Start \(j.number ?? 0)")
                case .jamEnd(let j):
                    print("\(format(wallTime: event.time))\t\tJam End \(j.number ?? 0)")
                case .timeoutStart(let t):
                    print("\(format(wallTime: event.time))\t\tTimeout Start \(t.owner ?? "-")")
                case .timeoutEnd(let t):
                    print("\(format(wallTime: event.time))\t\tTimeout End \(t.owner ?? "-")")
                case .scoringTripStart(let t):
                    print("\(format(wallTime: event.time))\t\t\tTrip Start Team \(t.statePath.teamJamNumber ?? 0)")
                case .scoringTripEnd(let t):
                    print("\(format(wallTime: event.time))\t\t\tTrip End Team \(t.statePath.teamJamNumber ?? 0)")
                case .penalty(let p):
                    if let (team, skater, penalty) = p.penaltyId.flatMap({allPenalties[$0]}) {
                        print("\(format(wallTime: event.time))\t\t\t\(team.fullName ?? "?"), \(skater.rosterNumber ?? "-"): \(penalty.code ?? "?")")
                    } else {
                        print("\(format(wallTime: event.time))\t\t\tPenalty \(p.code ?? "?")")
                    }
                case .boxTripStart(let t):
                    print("\(format(wallTime: event.time))\t\t\tBox Start")
                    for penaltyMap in t.penalty.allValues() {
                        if let (team, skater, penalty) = allPenalties[penaltyMap.key] {
                            let code = penalty.code ?? "?"
                            print("\t\t\t\t\t\t\(team.fullName ?? "?"), \(skater.rosterNumber ?? "-"): \(code)")
                        }
                    }
                case .boxTripEnd(let t):
                    print("\(format(wallTime: event.time))\t\t\tBox End")
                }
            }
        }
    }
}
