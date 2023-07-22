//
//  File.swift
//  
//
//  Created by gandreas on 7/22/23.
//

import Foundation
import StatterCRG

public extension Connection {
    /// What kind of change is this
    public enum StateChange : String {
        case change
        case action = ""
    }
    /// Send out an update to the state of the data to the server
    /// - Parameters:
    ///   - key: The state path to change
    ///   - value: The new value
    ///   - kind: What kind of change this is
    func set(key: StatePath, value: JSONValue, kind: StateChange = .change) {
        struct SetCommand: Codable {
            var action: String = "Set"
            var key: StatePath
            var value: JSONValue
            var flag: String
        }
        let command = SetCommand(key: key, value: value, flag: kind.rawValue)
        // call the general routine to send it
        send(command: command)
    }
    
}
