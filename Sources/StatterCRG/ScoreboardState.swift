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


@propertyWrapper
/// A property wrapper that is used to observe changes in some PathSpecified value
/// Use this like you would @ObservedObject, except with the PathSpecified (which is
/// usually a struct)
public struct Stat<P: PathSpecified> : DynamicProperty {
    @ObservedObject var connection: Connection
    private var value: P
    public init(wrappedValue p: P) {
        self.connection = p.connection
        self.value = p
    }
    public var wrappedValue: P {
        get {
            value
        }
    }
    
}
