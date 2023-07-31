//
//  File.swift
//  
//
//  Created by gandreas on 7/22/23.
//

import Foundation

public extension Connection {
    /// What kind of change is this.  This is the "flag" that is passed to
    /// the `Set` command
    enum StateChange : String {
        /// Set the value
        case set = ""
        /// Adjust the value by this delta
        case change
        /// Reset the value (for time on a clock)
        case reset
    }
    /// Send out an update to the state of the data to the server
    /// - Parameters:
    ///   - key: The state path to change
    ///   - value: The new value
    func set(key: StatePath, value: JSONValue, kind: StateChange = .set) {
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

