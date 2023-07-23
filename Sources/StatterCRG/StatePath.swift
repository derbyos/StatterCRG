//
//  StatePath.swift
//  Statter
//
//  Created by gandreas on 7/19/23.
//

import Foundation

/// StatePath encapsulates the keys that are passed in the state dictionary, reflecting where
/// the data lives in the tree.
///
/// It is a series of components, separated by periods.  Each component is a name
/// followed by an optional value enclosed in parenthesis.  Those values can be:
///  - `*` a wild card
///  - __integer__ an index
///  - __uuid__ identifier
///  - __string__ enumeration
///
public struct StatePath : Codable, Hashable {
    internal init(components: [StatePath.PathComponent]) {
        self.components = components
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fullString = try container.decode(String.self)
        self.init(from: fullString)
    }
    init(from fullString: String) {
        var pos = fullString.startIndex
        components = []
        enum State {
            case key
            case param
        }
        var key: String = ""
        var param: String = ""
        var state: State = .key
        func appendComponent() {
            if key.isEmpty == false {
                if param.isEmpty {
                    components.append(.plain(key))
                } else if param == "*" {
                    components.append(.wild(key))
                } else if let i = Int(param) {
                    components.append(.number(key, param: i))
                } else if let id = UUID(uuidString: param) {
                    components.append(.id(key, id: id))
                } else {
                    components.append(.name(key, name: param))
                }
            }
            key = ""
            param = ""
            state = .key
        }
        while pos < fullString.endIndex {
            let c = fullString[pos]
            pos = fullString.index(after: pos)
            switch state {
            case .key:
                switch c {
                case ".":
                    appendComponent()
                case "(":
                    state = .param
                default:
                    key.append(c)
                }
            case .param:
                switch c {
                case ")":
                    appendComponent()
                default:
                    param.append(c)
                }
            }
        }
        // and get thing that ended with string
        appendComponent()
    }
    public func encode(to encoder: Encoder) throws {
        let fullString = components.map {
            $0.description
        }
        var container = encoder.singleValueContainer()
        try container.encode(fullString.joined(separator: "."))
    }
    
    public enum PathComponent : Hashable, CustomStringConvertible {
        case plain(String)
        case wild(String)
        case number(String, param: Int)
        case id(String, id: UUID)
        case name(String, name: String)
        public var description: String {
            switch self {
            case .plain(let s): return s
            case .id(let s, id: let id): return "\(s)(\(id.uuidString.lowercased()))"
            case .name(let s, name: let name): return "\(s)(\(name))"
            case .wild(let s): return "\(s)(*)"
            case .number(let s, param: let n): return "\(s)(\(n))"
            }
        }
    }
    var components: [PathComponent]
    
    public func adding(_ component: PathComponent) -> StatePath {
        .init(components: components + [component])
    }
    public func adding(_ plain: String) -> StatePath {
        .init(components: components + [.plain(plain)])
    }
    public var description: String {
        .init(components.map {
            $0.description
        }.joined(separator: "."))
    }
}

/// A variable who is represented in the data tree.  These are essentially proxies between a
/// data representation and where it is stored in a data store on the connection
public protocol PathSpecified {
    /// The scoreboard connection
    var connection: Connection { get }
    /// A path into the server state
    var statePath: StatePath { get }
}
public extension PathSpecified {
    func adding(_ component: StatePath.PathComponent) -> StatePath {
        statePath.adding(component)
    }
    func adding(_ plain: String) -> StatePath {
        statePath.adding(.plain(plain))
    }
}

/// A child of a parent variable where both are in the data tree
public protocol PathNode : PathSpecified {
    associatedtype Parent : PathSpecified
    var parent: Parent { get }
}
public extension PathNode {
    var connection: Connection { parent.connection }
}

/// An actual value that is contained in the data tree.  We currently support
/// strings, integers, uuids, and booleans, and are read-only
@propertyWrapper
public struct Leaf<T:JSONTypeable>: PathSpecified {
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

    public var connection: Connection
    public var component: StatePath.PathComponent
    public var parentPath: StatePath
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
    }
}

@propertyWrapper
/// A Flag is like a Leaf but it is a bool that can be set via the `set` command
public struct Flag: PathSpecified {
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

    public var connection: Connection
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
                connection.set(key: statePath, value: .bool(newValue), kind: .action)
            }
        }
    }
}


extension PathSpecified {
    func leaf<T:JSONTypeable> (_ name: String) -> Leaf<T> {
        .init(connection: connection, component: .plain(name), parentPath: statePath)
    }
    func leaf<T:JSONTypeable> (_ component: StatePath.PathComponent) -> Leaf<T> {
        .init(connection: connection, component: component, parentPath: statePath)
    }
    
    func flag (_ name: String) -> Flag {
        .init(connection: connection, component: .plain(name), parentPath: statePath)
    }
    func flag (_ component: StatePath.PathComponent) -> Flag {
        .init(connection: connection, component: component, parentPath: statePath)
    }
}
/*
struct PathLeaf<P: PathSpecified> : PathSpecified {
    var connection: Connection { parent.connection }
    init(parent: P, component: StatePath.PathComponent) {
        self.parent = parent
        self.component = component
    }
    init(parent: P, name: String) {
        self.parent = parent
        self.component = .plain(name)
    }

    var parent: P
    var component: StatePath.PathComponent
    var statePath: StatePath { parent.adding(component) }
}

*/
