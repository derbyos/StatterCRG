//
//  File.swift
//  
//
//  Created by gandreas on 8/9/23.
//

import Foundation
import StatterCRG

extension Connection {
    
    /// When exporting a game,
    public struct StaticGame : Codable {
        public init(state: [StatePath : JSONValue]) {
            self.state = state
        }
        
        public var state: [StatePath: JSONValue]
        // since default encodeing will be as [(StatePath, JSONValue)] rather than a dictionary, we convert to/from strings
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Connection.StaticGame.CodingKeys> = try decoder.container(keyedBy: Connection.StaticGame.CodingKeys.self)
            let stringKeys = try container.decode([String : JSONValue].self, forKey: Connection.StaticGame.CodingKeys.state)
            state = .init(uniqueKeysWithValues: stringKeys.map({(StatePath(stringLiteral: $0.key), $0.value)}))
        }
        public enum CodingKeys: CodingKey {
            case state
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Connection.StaticGame.CodingKeys.self)
            let stringKeys = [String: JSONValue](uniqueKeysWithValues: state.map({($0.key.description, $0.value)}))
            try container.encode(self.state, forKey: Connection.StaticGame.CodingKeys.state)
        }
    }
    
    /// Create a blank game file
    public static func blankGameData() -> Connection {
        let retval = Connection(host: nil, operatorName: "<static>")
        // set a version
        retval.state["ScoreBoard.Version(release)"] = .string("v2023.3")
        return retval
    }
    /// Create a static instance of a single game based on downloaded JSON
    /// - Parameter game: The downloaded JSON
    public convenience init(game: Data) throws {
        self.init(host: nil, operatorName: "<static>")
        // now load our state with this data
        let staticGame = try JSONDecoder().decode(StaticGame.self, from: game)
        self.state = staticGame.state
    }
    
    /// Convert the current state (locally, not on server) to data
    ///
    /// This is useful for saving game data that was previously loaded
    ///
    /// - Returns: The encoded state
    ///
    public func saveState() throws -> Data {
        let staticGame = StaticGame(state: self.state)
        return try JSONEncoder().encode(staticGame)
    }
}
