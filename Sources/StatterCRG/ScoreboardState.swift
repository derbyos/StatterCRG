//
//  State.swift
//  Statter
//
//  Created by gandreas on 7/20/23.
//

import Foundation
import SwiftUI
import Combine

extension Connection {
    func binding(to path: PathSpecified) -> Binding<JSONValue> {
        .init {
            self.state[path.statePath] ?? .null
        } set: { newValue in
            self.state[path.statePath] = newValue
        }
    }

    #if false // this doesn't look good anyway
//    subscript(dynamicMember string: String) -> JSONValue {
//        return notification.userInfo?[string] as? String ?? .null
//    }
    subscript<T:PathSpecified>(dynamicMember keyPath: KeyPath<ScoreBoard, T>) -> JSONValue? {
        let path = scoreBoard[keyPath: keyPath]
        return state[path.statePath]
    }
    
    func ignore() {
        let game = self.clients
    }
    #endif
    
//    func ignore2() {
//        let game = self.game.flatMap{WrappedState(connection: self, root: $0)}!
//        game()
//    }
}


extension PathSpecified {
    
    public var binding: Binding<JSONValue> {
        .init {
            connection.state[statePath] ?? .null
        } set: { newValue in
            connection.state[statePath] = newValue
        }

    }
    
    public var value: JSONValue {
        if let value = connection.state[statePath] {
            return value
        }
        connection.register(self)
        return .null
    }
}


@dynamicMemberLookup
public class ObservableState<P: PathSpecified> : ObservableObject {
    public let wrappedValue: P
    var triggerChange: AnyCancellable?
    deinit {
        print("• Deinit")
    }
    public init(_ p: P) {
        print("• Init")
        self.wrappedValue = p
        triggerChange = wrappedValue.connection.objectWillChange.sink(receiveValue: { [weak self] in
            self?.objectWillChange.send()
        })
    }
    public subscript<V>(dynamicMember keyPath: KeyPath<P, V>) -> V {
        wrappedValue[keyPath: keyPath]
    }
}
