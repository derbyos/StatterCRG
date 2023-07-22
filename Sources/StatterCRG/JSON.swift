//
//  JSON.swift
//  Statter
//
//  Created by gandreas on 7/19/23.
//

import Foundation
/// Encapsulate arbitray JSON values which can be loaded/saved as needed
public enum JSONValue: Codable, Equatable, Hashable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .int(let i): try container.encode(i)
        case .double(let d): try container.encode(d)
        case .bool(let b): try container.encode(b)
        case .object(let o): try container.encode(o)
        case .array(let a): try container.encode(a)
        case .null: try container.encodeNil()
        }
    }
    
    public init(from string: String) throws {
        if let data = string.data(using: .utf8) {
            self = try JSONDecoder().decode(JSONValue.self, from: data)
        } else{
            self = .null
        }
    }

    public init(_ value: Bool) {
        self = .bool(value)
    }
    public init(_ value: Int) {
        self = .int(value)
    }
    public init(_ value: Double) {
        self = .double(value)
    }
    public init(_ value: String) {
        self = .string(value)
    }
    public init(_ value: [Any]) {
        self = .array(value.compactMap({JSONValue($0)}))
    }
    public init(_ value: [String:Any]) {
        self = .object(value.compactMapValues({JSONValue($0)}))
    }
    public init?(_ value: Any) {
        if let x = value as? Bool {
            self = .bool(x)
        } else if let x = value as? Int {
            self = .int(x)
        } else if let x = value as? Double {
            self = .double(x)
        } else if let x = value as? String {
            self = .string(x)
        } else if let x = value as? Array<Any> {
            self = .array(x.compactMap({JSONValue($0)}))
        } else if let x = value as? Dictionary<String, Any> {
            self = .object(x.compactMapValues({JSONValue($0)}))
        } else {
            return nil
        }
    }

    
    public var stringValue: String? {
        switch self {
        case .string(let str):
            return str
        default:
            return nil
        }
    }
    public var intValue: Int? {
        switch self {
        case .int(let i):
            return i
        default:
            return nil
        }
    }
    public var doubleValue: Double? {
        switch self {
        case .double(let d):
            return d
        default:
            return nil
        }
    }
    public var numberValue: Double? {
        switch self {
        case .double(let d):
            return d
        case .int(let i):
            return Double(i)
        default:
            return nil
        }
    }
    public var boolValue: Bool? {
        switch self {
        case .bool(let i):
            return i
        default:
            return nil
        }
    }

    public var arrayValue: [JSONValue]? {
        switch self {
        case .array(let a):
            return a
        default:
            return nil
        }
    }
    public var objectValue: [String:JSONValue]? {
        switch self {
        case.object(let obj):
            return obj
        default:
            return nil
        }
    }

    public var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else {
            return "<JSONValue>"
        }
        return String(data: data, encoding: .utf8) ?? "<JSONValue>"
    }

}


protocol JSONTypeable {
    init?(_ json: JSONValue)
    var asJSON: JSONValue { get }
}
extension Int : JSONTypeable {
    init?(_ json: JSONValue) {
        guard let value = json.intValue else {
            return nil
        }
        self = value
    }
    var asJSON: JSONValue { .int(self) }
}
extension Bool : JSONTypeable {
    init?(_ json: JSONValue) {
        if let value = json.boolValue {
            self = value
        } else if json.stringValue?.lowercased() == "true" {
            self = true
        } else if json.stringValue?.lowercased() == "false" {
            self = false
        } else {
            return nil
        }
    }
    var asJSON: JSONValue { .bool(self) }
}
extension String : JSONTypeable {
    init?(_ json: JSONValue) {
        guard let value = json.stringValue else {
            return nil
        }
        self = value
    }
    var asJSON: JSONValue { .string(self) }
}
extension UUID : JSONTypeable {
    init?(_ json: JSONValue) {
        guard let value = json.stringValue.flatMap({UUID(uuidString: $0)}) else {
            return nil
        }
        self = value
    }
    var asJSON: JSONValue { .string(self.uuidString) }
}
