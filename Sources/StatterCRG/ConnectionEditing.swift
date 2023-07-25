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
        case change
        case set = ""
    }
    /// Send out an update to the state of the data to the server
    /// - Parameters:
    ///   - key: The state path to change
    ///   - value: The new value
    func set(key: StatePath, value: JSONValue, kind: StateChange? = nil) {
        struct SetCommand: Codable {
            var action: String = "Set"
            var key: StatePath
            var value: JSONValue
            var flag: String
        }
        let command = SetCommand(key: key, value: value, flag: kind?.rawValue ?? stateChange.rawValue)
        // call the general routine to send it
        send(command: command)
    }
    
    
    /// Executes a closure with the specified flag and returns the result.
    ///
    /// - Parameters:
    ///   - change : The change flag.
    ///     transaction.
    ///   - body: A closure to execute.
    ///
    /// - Returns: The result of executing the closure with the specified
    ///   change action.
    func withSet<Result>(_ change: StateChange, _ body: () throws -> Result) rethrows -> Result {
        // save the old
        let change = stateChange
        defer {
            stateChange = change
        }
        return try body()
    }

}


extension PathSpecified {
    /// Executes a closure with the specified flag and returns the result.
    ///
    /// - Parameters:
    ///   - change : The change flag.
    ///   - body: A closure to execute.
    ///
    /// - Returns: The result of executing the closure with the specified
    ///   change action.
    public func withSet<Result>(_ change: Connection.StateChange, _ body: () throws -> Result) rethrows -> Result {
        return try connection.withSet(change, body)
    }
}
