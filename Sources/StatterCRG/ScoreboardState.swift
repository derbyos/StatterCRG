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

/// An actual value that is contained in the data tree.  We currently support
/// strings, integers, uuids, and booleans, and are read-only
@propertyWrapper
public struct Leaf<T:JSONTypeable>: PathSpecified, DynamicProperty {
    public init(connection: Connection, component: StatePath.PathComponent, parentPath: StatePath, change: Connection.StateChange = .change) {
        self.connection = connection
        self.component = component
        self.parentPath = parentPath
        self.change = change
    }
    public init<P:PathSpecified>(_ parent: P, _ name: String, change: Connection.StateChange = .change) {
        self.connection = parent.connection
        self.component = .plain(name)
        self.parentPath = parent.statePath
        self.change = change
    }
    public init<P:PathSpecified>(_ parent: P, component: StatePath.PathComponent, change: Connection.StateChange = .change) {
        self.connection = parent.connection
        self.component = component
        self.parentPath = parent.statePath
        self.change = change
    }

    @ObservedObject public var connection: Connection
    public var component: StatePath.PathComponent
    public var parentPath: StatePath
    public var change: Connection.StateChange = .change
    public var statePath: StatePath {
        parentPath.adding(component)
    }
    public var wrappedValue: T? {
        get {
            if let value = connection.state[statePath] {
                return T(value)
            }
            connection.register(path: self)
            return nil
        }
        nonmutating set {
            connection.set(key: statePath, value: newValue?.asJSON ?? .null, kind: change)
        }
    }
}

@propertyWrapper
/// A Flag is like a Leaf but it is a bool that can be set via the `set` command
public struct Flag: PathSpecified, DynamicProperty {
    public init(connection: Connection, component: StatePath.PathComponent, parentPath: StatePath) {
        self.connection = connection
        self.component = component
        self.parentPath = parentPath
    }
    public init<P:PathSpecified>(_ parent: P, _ name: String) {
        self.connection = parent.connection
        self.component = .plain(name)
        self.parentPath = parent.statePath
    }
    public init<P:PathSpecified>(_ parent: P, component: StatePath.PathComponent) {
        self.connection = parent.connection
        self.component = component
        self.parentPath = parent.statePath
    }

    @ObservedObject public var connection: Connection
    public var component: StatePath.PathComponent
    public var parentPath: StatePath
    public var statePath: StatePath {
        parentPath.adding(component)
    }
    public var wrappedValue: Bool? {
        get {
            if let value = connection.state[statePath] {
                return Bool(value)
            }
            connection.register(path: self)
            return nil
        }
        nonmutating set {
            if let newValue {
                connection.set(key: statePath, value: .bool(newValue), kind: .set)
            }
        }
    }
}


/// An list of leaves, indexed by whatever the type is.  Used, for example,
/// to declare Skater roster in a team
public struct MapNodeCollection<Parent:PathSpecified, T:PathNode & Identifiable> : PathSpecified where T.ID == UUID?, T.Parent == Parent {
    public var connection: Connection {
        parent.connection
    }
    
    public init(_ parent: Parent, _ name: String) {
        self.parent = parent
        self.ourName = name
        parent.connection.register(path: self)
    }

    var parent: Parent
    var ourName: String
    public var statePath: StatePath {
        parent.statePath.adding(.plain(ourName))
    }
    // walk through all elements in the connection
    // and find any which match our path converting
    // the plain element to an id element
    func iterateElements(block: (T.ID, inout Bool)->Void) {
        let ourParent = parent.statePath
        for kv in parent.connection.state {
            // check to see if we are `foo.bar` and
            // the state variables is `foo.bar(id).baz`
            // then we want to build an element for `foo.bar(id)`
            if let relativeName = kv.key.dropping(parent: ourParent) {
                // see that this is `.bar(id)`
                guard case let .id(childName, id: id) = relativeName.first, childName == ourName else {
                    continue
                }
                var stop = false
                block(id, &stop)
                if stop {
                    break
                }
            }
        }
    }
    public subscript(id: T.ID) -> T? {
        var retval: T? = nil
        iterateElements {
            if $0 == id {
                $1 = true
                retval = T(parent: parent, statePath: parent.statePath.adding(.id(ourName, id: $0!)))
            }
        }
        return retval
    }
    
    public func keys() -> Set<T.ID> {
        var retval = Set<T.ID>()
        iterateElements { id, stop in
            retval.insert(id)
        }
        return retval
    }
    
    public func allValues() -> [T] {
        var retval = [T]()
        var seen = Set<T.ID>()
        iterateElements { id, stop in
            if seen.contains(id) {
                return
            }
            seen.insert(id)
            retval.append(T(parent: parent, statePath: parent.statePath.adding(.id(ourName, id: id!))))
        }
        return retval
    }
}
