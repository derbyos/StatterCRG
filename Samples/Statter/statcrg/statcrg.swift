//
//  main.swift
//  statcrg
//
//  Created by gandreas on 8/2/23.
//

import Foundation
import ArgumentParser
import StatterCRG
import Combine

enum Errors : Error {
    case unableToGetValue
}

@main
struct StatCRG: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "statcrg",
        abstract: "A utility for controlling CRG.",
        
        version: "0.0.1",
        
        subcommands: [Get.self, Set.self, List.self, Repl.self],
        
        defaultSubcommand: Repl.self
    )
}

extension StatCRG {
    struct Repl : ParsableCommand {
        @OptionGroup var serverOptions: ServerOptions
//        @Option(name: .customLong("output"), help: "The style of the output")
//        var outputFormat: Format = .text

        var fileHandle: FileHandle {
            get throws {
//                guard let inputFile = inputFile else {
                    return .standardInput
//                }
//                return try FileHandle(forReadingFrom: inputFile)
            }
        }

        mutating func run() throws {
            let capture = self
            Task {
                try await capture.runAsync()
            }
            RunLoop.main.run()
        }
        func runAsync() async throws {
            let connection = serverOptions.connection()
            connection.connect()
            // ugly hack to get around async lines not be a sequence
            _ = try await fileHandle.bytes.lines.first(where: { line in
                let args = line.split(separator: " ")
                switch args.first {
                case "get":
                    guard args.count == 2 else {
                        print("<get> requires state path")
                        break
                    }
                    let statePath = StatePath(from: .init(args[1]))
                    let value = await connection.fetch(path: statePath)
                    if let value {
                        print(value.description)
                    } else {
                        print("Unavailable")
                    }
                case "set":
                    guard args.count >= 3 else {
                        print("<set> requires state path and value")
                        break
                    }
                    let statePath = StatePath(from: .init(args[1]))
                    guard let data = (args[2 ..< args.count]).joined(separator:" ").data(using: .utf8), let value = try? JSONDecoder().decode(JSONValue.self, from: data) else {
                        print("\(args[2]) invalid JSON value")
                        break
                    }
                    connection.set(key: statePath, value: value)
                case "exit":
                    StatCRG.Repl.exit()
                default:
                    print("Unknown command: \(line)")
                }
                return false
            })
        }
    }
}
struct ServerOptions: ParsableArguments {
    @Argument(help: "The hostname of the CRG server")
    var hostName: String = "localhost"
    
    @Option(name: .long, help: "Port")
    var port: Int = 8000
    
    @Option(name: [.customShort("o"), .customLong("operator")], help: "The name of the operator")
    var operatorName: String = ""
    
    @Option(help: "The ID of the game")
    var game: String? = nil

    @Flag(help: "Verbose nextorking")
    var verbose: Bool = false

    func connection() -> Connection {
        let retval = Connection(host: hostName, port: port, operatorName: operatorName)
        if verbose {
            retval.debugFlags = [.incoming, .outgoing, .registering, .webSockets]
        }
        return retval
    }
}

struct OutputOptions: ParsableArguments {
    enum Format : String, RawRepresentable, ExpressibleByArgument {
        case text // tab separated if needed
        case json
    }
    @Option(name: .customLong("output"), help: "The style of the output")
    var outputFormat: Format = .text
    
    @Flag(name: .long, help: "Continue to listen and get values for this command")
    var continuous: Bool = false
}

extension StatCRG {
    static func parse(specifier: [String]) -> StatePath {
        .init(from: specifier.joined(separator: "."))
    }
}
extension StatCRG {
    struct Get: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Get a single value from the server")
        @OptionGroup var serverOptions: ServerOptions
        @OptionGroup var outputOptions: OutputOptions
        
        @Argument(help: "The data specifier")
        var specifier: String = ""

        mutating func run() throws {
            let statePath = StatCRG.parse(specifier: [specifier])
            let connection = serverOptions.connection()
            connection.connect()
            let continuous = outputOptions.continuous
            Task {
                let value = await connection.fetch(path: statePath)
                if let value {
                    print(value.description)
                    if !continuous {
                        StatCRG.Get.exit()
                    }
                } else {
                    StatCRG.Get.exit(withError: Errors.unableToGetValue)
                }
            }
            RunLoop.main.run()
        }
    }
}

extension StatCRG {
    struct Set: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Set a single value from the server")
        @OptionGroup var serverOptions: ServerOptions
        @Argument(help: "The data specifier")
        var specifier: String = ""
        
        @Argument(help: "The JSON value")
        var value: [String] = []

        mutating func run() throws {
            let statePath = StatCRG.parse(specifier: [specifier])
            let connection = serverOptions.connection()
            connection.connect()
            guard let data = (value).joined(separator:" ").data(using: .utf8) else {
                print("Unable to form value")
                return
            }
            let jsonValue = try JSONDecoder().decode(JSONValue.self, from: data)

            Task {
                connection.set(key: statePath, value: jsonValue)
                // and wait for it to be set
                _ = await connection.fetch(path: statePath)
                StatCRG.Get.exit()
            }
            RunLoop.main.run()
        }
    }
}

extension StatCRG {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "List a series of values (such as games, skaters, officials)")
        @OptionGroup var serverOptions: ServerOptions
        @OptionGroup var outputOptions: OutputOptions
        enum TopLevel : String, RawRepresentable, ExpressibleByArgument {
            case games // tab separated if needed
            case refs
            case nsos
        }
        @Argument(help: "What to list")
        var list: TopLevel = .games

        
        mutating func run() throws {
            let connection = serverOptions.connection()
            connection.connect()
            switch list {
            case .games:
//                let games : MapNodeCollection<ScoreBoard, Game, UUID> = .init(connection.scoreBoard, "Game(*)")
//                let gameIDs : MapValueCollection<UUID, UUID> = .init(connection: connection, statePath: StatePath(from: "ScoreBoard.Game(*)"))
//                _ = games.allValues()
                var seenGames:Swift.Set<UUID> = []
                var update : AnyCancellable? = nil
                update = connection.stateDataDidChange.sink { msg in
//                    print("change of \(msg)")
//                    guard !games.allValues().isEmpty else {
//                        return
//                    }
//                    for game in games.allValues() {
                    if msg.path.hasPrefix("ScoreBoard") {
                        if case let .id("Game", id: id) = msg.path.dropFirst().first(where: {_ in true}) {
                            if !seenGames.contains(id) {
                                print("Game <\(id.uuidString.lowercased())> : \(msg.newValue.description)")
                                seenGames.insert(id)
                                DispatchQueue.main.async {
                                    update = nil
                                    StatCRG.Get.exit()
                                }
                            }
                        }
                    }
                }
                connection.register(statePaths:  ["ScoreBoard.Game(*).Name"])
            case .nsos:
                break
            case .refs:
                break
            }
            RunLoop.main.run()
        }

    }
}
