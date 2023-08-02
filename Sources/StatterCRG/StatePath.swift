//
//  StatePath.swift
//  Statter
//
//  Created by gandreas on 7/19/23.
//

import Foundation
import SwiftUI

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
public struct StatePath : Codable, Hashable, Sequence {
    public typealias Element = StatePath.PathComponent
    internal init(components: [StatePath.PathComponent]) {
        self.components = components
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let fullString = try container.decode(String.self)
        self.init(from: fullString)
    }
    public init(from fullString: String) {
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
                } else if param.contains(".") {
                    components.append(.compound(key, parts: param.components(separatedBy: ".").map{String($0)}))
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
        case compound(String, parts: [String]) // simlar to name, but parts are separated by periods
        public var description: String {
            switch self {
            case .plain(let s): return s
            case .id(let s, id: let id): return "\(s)(\(id.uuidString.lowercased()))"
            case .name(let s, name: let name): return "\(s)(\(name))"
            case .wild(let s): return "\(s)(*)"
            case .number(let s, param: let n): return "\(s)(\(n))"
            case .compound(let s, parts: let p): return "\(s)(\(p.joined(separator: ".")))"
            }
        }
        public var id: UUID? {
            switch self {
            case .id(_, id: let id): return id
            default: return nil
            }
        }
    }
    var components: [PathComponent]
    
    /// Create a new state path, adding this component
    /// - Parameter component: The component to add
    /// - Returns: A new state path with this component added
    public func adding(_ component: PathComponent) -> StatePath {
        .init(components: components + [component])
    }
    /// Create a new state path, adding this string as a .plain component
    /// - Parameter plain: The name to add
    /// - Returns: A new state path with this appended
    ///
    /// - Important: If the last element is a compound, this will add to the compound
    public func adding(_ plain: String) -> StatePath {
        switch components.last {
        case .compound(let s, parts: let p):
            return .init(components: components.dropLast() + [.compound(s, parts: p + [plain])])
        default:
            return .init(components: components + [.plain(plain)])
        }
    }
    public var description: String {
        .init(components.map {
            $0.description
        }.joined(separator: "."))
    }
    
    /// Test if a state path has another state path as its first components
    /// - Parameter other: The state path to compare
    /// - Returns: True if the other state path's components are our prefix
    public func hasPrefix(_ other: StatePath) -> Bool {
        if components.count >= other.components.count && components[0 ..< other.components.count] == other.components[0 ..< other.components.count] {
            return true
        }
        return false
    }
    
    /// Test if a state path has another state path as its first components,
    /// and is exactly one component longer (so an immediate child of the
    /// other one)
    /// - Parameter other: The state path to compare
    /// - Returns: The child component added to our path relative to the parent
    public func immediateChild(of parent: StatePath) -> PathComponent? {
        if components.count == parent.components.count+1 && components[0 ..< parent.components.count-1] == parent.components[0 ..< parent.components.count-1] {
            return components[count - 1]
        }
        return nil
    }
    
    /// Test if a state path has another state path as its first components,
    /// and if so, drop that parent and give what is left
    /// - Parameter other: The state path to compare
    /// - Returns: The child components added to our path relative to the parent
    public func dropping(parent: StatePath) -> ArraySlice<PathComponent>? {
        if hasPrefix(parent) {
            return components[parent.count ..<  components.count]
        }
        return nil
    }

    
    /// The last component of our path
    public var last : StatePath.PathComponent? {
        components.last
    }
    /// A new state path with the last component of us dropped
    /// - Returns: The state path
    public var parent : StatePath {
        .init(components: components.dropLast())
    }
    
    /// The number of elements
    public var count: Int {
        components.count
    }
    
    // for sequence conformity
    public typealias Iterator = StatePathIterator
    public struct StatePathIterator : IteratorProtocol {
        var index: Int = -1
        var components: [PathComponent]
        mutating public func next() -> Element? {
            index += 1
            if index >= components.count {
                return nil
            }
            return components[index]
        }
    }
    public func makeIterator() -> StatePathIterator {
        .init(components: components)
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
        statePath.adding(plain)
    }
}

/// A child of a parent variable where both are in the data tree
public protocol PathNode : PathSpecified {
    associatedtype Parent : PathSpecified
    var parent: Parent { get }
    
    init(parent: Parent, statePath: StatePath)
}
public extension PathNode {
    var connection: Connection { parent.connection }
}
#if nomore
public protocol PathNodeId : PathNode, Identifiable {
    associatedtype IDBase: JSONTypeable
    var id: IDBase? { get }
}
#else
public protocol PathNodeId : PathNode, Identifiable {
    var id: StatePath { get }
}
#endif
//extension Identifiable where Self: PathNodeId {
//    public var id: IDBase? { }
//}


extension PathSpecified {
    func leaf<T:JSONTypeable> (_ name: String) -> Leaf<T> {
        .init(connection: connection, component: .plain(name), parentPath: statePath)
    }
    func leaf<T:JSONTypeable> (_ component: StatePath.PathComponent) -> Leaf<T> {
        .init(connection: connection, component: component, parentPath: statePath)
    }
    #if nomore // leaf takes the change type
    func flag (_ name: String) -> Flag {
        .init(connection: connection, component: .plain(name), parentPath: statePath)
    }
    func flag (_ component: StatePath.PathComponent) -> Flag {
        .init(connection: connection, component: component, parentPath: statePath)
    }
    #endif
}
extension Leaf {
    /// Convert a Leaf to an ImmutableLeaf
    var immutable: ImmutableLeaf<T> {
        .init(connection: connection, component: component, parentPath: parentPath)
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

public struct MapValueCollection<Value: JSONTypeable, Index: JSONTypeable> : PathSpecified {
    public var connection: Connection
    public var statePath: StatePath
    var lastComponentName: String
    public init(connection: Connection, statePath: StatePath) {
        self.connection = connection
        if case let .wild(name) = statePath.components.last {
            lastComponentName = name
        } else {
            assertionFailure("Last path component of MapValueCollection statePath must be wild")
            lastComponentName = ""
        }
        self.statePath = statePath
    }
    public subscript(id: Index) -> Value? {
        if let value = connection.state[statePath] {
            return Value(value)
        }
        //            connection.register(path: )
        return nil
    }
    public func allValues() -> [Index: Value] {
        connection.register(self) // always re-register, in case
        var retval: [Index:Value] = [:]
        for state in connection.state {
            // is this "us(someID)"?
            if state.key.components.count == statePath.components.count && state.key.components[0 ..< statePath.components.count-1] == statePath.components[0 ..< statePath.components.count-1] {
                // yes, we want this
                if let (name, id) = Index.from(component: state.key.components.last) {
                    if name == lastComponentName {
                        retval[id] = Value(state.value)
                    }
                }
            }
        }
        return retval
    }
}

