//
//  main.swift
//  treemaker
//
//  Created by gandreas on 7/21/23.
//

import Foundation

var inputFileName : String
var outputFolder: String

if CommandLine.arguments.count < 2 {
    inputFileName = "/Users/gandreas/Sources/Statter/treemaker/TreeDefinition"
    outputFolder = "/Users/gandreas/Sources/Statter/Statter/GenTree"
} else {
    guard CommandLine.arguments.count == 3 else {
        fatalError()
    }
    inputFileName = CommandLine.arguments[1]
    outputFolder = CommandLine.arguments[2]
}

class AST {
    enum Kind : Equatable {
        case root
        case node(parent: String?)
        case leaf(String, immutable: Bool)
        case flag
        case key(String)
        case comment // stored in name
        case code // pass through verbatim
        case `enum`
        case `case`(String?)
        case `subscript`(String)
        case map(String, index: String) // like a subscript but maps optional ids
        case action
        case ref(String)
        case list(String)
    }
    var kind: Kind
    var name: String
    var children: [AST]
    init(kind: Kind, name: String) {
        self.kind = kind
        self.name = name
        children = []
    }
}

struct Document {
    var roots: [AST]
    var symbols: [String: AST]
}

enum Errors : Error {
    case syntaxError
    case missingNodeName
    case missingLeafType
    case rootNodeNotAtRoot
    case multipleNodeKeys
    case expected(String)
}

let indentBy = "    "

extension String {
    var initialLowercase: String {
        guard self.isEmpty == false else {
            return self
        }
        if self == "Operator" || self == "operator" {
            return "`operator`"
        }
        return self.first!.lowercased() + self.dropFirst()
    }
    func asPathParam(_ base: String, name: String) -> String {
        switch self {
        case "UUID", "UUID?":
            return ".id(\"\(base)\", id: \(name))"
        case "Int", "Int?":
            return ".number(\"\(base)\", param: \(name))"
        case "String", "String?":
            return ".name(\"\(base)\", name: \(name))"
        default:
            return ".name(\"\(base)\", name: \(name).rawValue)"
        }
    }
}
extension String {
    var plural : String {
        if hasSuffix("y") {
            return self.dropLast() + "ies"
        } else {
            return self + "s"
        }
    }
}
extension AST {
    var key: AST? {
        children.first(where: {
            if case .key = $0.kind {
                return true
            }
            return false
        })
    }
    var keyType: String? {
        if case let .key(type) = kind {
            return type
        }
        return nil
    }
    func generate() throws -> String {
//        guard kind == .root else {
//            throw Errors.rootNodeNotAtRoot
//        }
        var fileSrc = """
// \(name).swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation

"""
        fileSrc.append(try generate(parent: "", indent: "").joined(separator: "\n") + "\n")
        return fileSrc
    }
    
    func save(destURL: URL) throws {
//        guard kind == .root else {
//            throw Errors.rootNodeNotAtRoot
//        }
        switch kind {
        case .comment:
            return // do nothing with these in top level
        default:
            let fileURL = destURL.appending(path: "\(name).swift")
            let fileSrc = try generate()
            try fileSrc.data(using: .utf8)?.write(to: fileURL)
        }
    }
    
    func generate(parent: String, indent: String) throws -> [String] {
        var lines : [String]
        switch kind {
        case .comment:
            return [indent + name + "\n"]
        case .code: // since the newline will be added
            return [indent + name]
        case .enum:
            lines = [
                "public enum \(name): String, EnumStringAsID {",
            ]
        case .`case`(let value):
            return [indent + "case \(name.initialLowercase) = \"\(value ?? name)\""]
        case .action:
            return [indent + "public func \(name.initialLowercase)() { connection.set(key: statePath.adding(\"\(name)\"), value: .bool(true), kind: .set) }"]
        case .root:
            lines = [
                "public struct \(name) : PathSpecified {",
                indentBy + "public var connection: Connection",
                indentBy + "public var statePath: StatePath { .init(components: [.plain(\"\(name)\")])}",
                "",
            ]
        case .list(let type):
            return [indent + "public var \(name.initialLowercase.plural) : MapNodeCollection<Self, \(type)> { .init(self,\"\(name)\") } \n"]
        case .node(let parent2):
            let fullParent = parent2 ?? parent
            let qname: String
            let qparent: String
            var protos: String = ""
            if fullParent.contains(" ") { // it is a template
                qname = name + "<P:PathSpecified>"
                qparent = "P"
            } else if fullParent.hasSuffix(">") {
                qname = name + "<P:PathSpecified>"
                qparent = fullParent
            } else {
                qname = name
                qparent = fullParent
            }
            if let key = self.key, key.keyType != nil {
                protos = "Id, Identifiable"
            }
            lines = [
                "public struct \(qname) : PathNode\(protos) {",
                indentBy + "public var parent: \(qparent)"
            ]
            // get non-optional
            if let keyType = self.key?.keyType?.trimmingCharacters(in: .punctuationCharacters) {
                lines += [
                    indentBy + "public var id: \(keyType)? { \(keyType).from(component: statePath.last)?.1 }",
                ]
            }

            // state path can either be plain, or some sort of parameter (or an optional one)
            #if nomore
            if let key, let keyType = key.keyType {
                if keyType.hasSuffix("?") {
                    lines += [
                        indentBy + "public var statePath: StatePath {",
                        indentBy + indentBy + "if let \(key.name) {",
                        indentBy + indentBy + indentBy + "return parent.adding(\(keyType.asPathParam(name, name: key.name.initialLowercase)))",
                        indentBy + indentBy + "} else {",
                        indentBy + indentBy + indentBy + "return  parent.adding(.wild(\"\(name)\"))",
                        indentBy + indentBy + "}",
                        indentBy + "}",
                        "",
                    ]
                } else {
                    lines += [
                        indentBy + "public var statePath: StatePath { parent.adding(\(keyType.asPathParam(name, name: key.name.initialLowercase)))}",
                        "",
                    ]
                }
            } else {
                lines += [
                    indentBy + "public var statePath: StatePath { parent.adding(.plain(\"\(name)\"))}",
                    "",
                ]
            }
            #else
            // make statePath be a variable so we can have multiple "containment"
            lines += [
                indentBy + "public let statePath: StatePath"
            ]
            #endif
        case .leaf(let type, immutable: let immutable):
            if !immutable {
                return [indent + "@Leaf public var \(name.initialLowercase): \(type)?\n"]
            } else { // immutable
                return [indent + "@ImmutableLeaf public var \(name.initialLowercase): \(type)?\n"]
            }
        case .ref(let type): // only support for named references
            return [indent + "public var \(name.initialLowercase): \(type) { \(type)(parent: self, statePath: self.adding(\"\(name)\"))}\n"]

        case .flag:
            return [indent + "@Flag public var \(name.initialLowercase): Bool?\n"]
        case .map(let type, index: let index):
            return [
                indent + "public typealias \(name)_Map = MapValueCollection<\(type), \(index)>",
                indent + "public var \(name.initialLowercase):\(name)_Map { .init(connection: connection, statePath: self.adding(.wild(\"\(name)\"))) }\n"
            ]

        case .subscript(let type):
            return [
                indent + "public struct \(name)_Subscript {",
                indent + indentBy + "var connection: Connection",
                indent + indentBy + "var statePath: StatePath",
                indent + indentBy + "public subscript(\(name.initialLowercase):\(name)) -> \(type)? {",
                indent + indentBy + indentBy + "let l = Leaf<\(type)>(connection: connection, component: .name(\"\(name)\", name: \(name.initialLowercase).rawValue), parentPath: statePath)",
                indent + indentBy + indentBy + "return l.wrappedValue",
                indent + indentBy + "}",
                indent + "}",
                indent + "public var \(name.initialLowercase):\(name)_Subscript { .init(connection: connection, statePath: statePath) }"
            ]
        case .key(_):
            // this is no longer stored, we make the state path in the init
            return []
//            return [indent + "public var \(name.initialLowercase) : \(type)\n"]
        }
        // now the children
        for child in children {
            lines.append(contentsOf: try child.generate(parent: name, indent: indentBy))
        }
        // now any additional init
        func declareLeafs(dummy: String = "parent") {
            // the leaf really needs to be `self.leaf("Name")` but
            // we can't use that until it is set, so two passes
            for child in children {
                switch child.kind {
                case .leaf(_, immutable: let immutable):
                    if !immutable {
                        lines.append(indentBy + indentBy + "_\(child.name.initialLowercase) = \(dummy).leaf(\"\(child.name)\")")
                    } else {
                        lines.append(indentBy + indentBy + "_\(child.name.initialLowercase) = \(dummy).leaf(\"\(child.name)\").immutable")
                    }
                case .flag:
                    lines.append(indentBy + indentBy + "_\(child.name.initialLowercase) = \(dummy).flag(\"\(child.name)\")")
                default:
                    break
                }
            }
            for child in children {
                switch child.kind {
                case .leaf(_, immutable: _), .flag:
                    lines.append(indentBy + indentBy + "_\(child.name.initialLowercase).parentPath = statePath")
                default:
                    break
                }
            }
        }

        func declareInit(parent2: String?) {
            let fullParent = parent2 ?? parent
            var parameters = ""
            if let key = self.key, let keyType = key.keyType {
                parameters = ", \(key.name.initialLowercase): \(keyType)"
                if keyType.hasSuffix("?") {
                    parameters.append(" = nil")
                }
            }
            let qparent: String
            if fullParent.contains(" ") {
                qparent = "P"
            } else {
                qparent = fullParent
            }
            lines.append(indentBy + "public init(parent: \(qparent)\(parameters)) {")
            lines.append(indentBy + indentBy + "self.parent = parent")

            if let key, let keyType = key.keyType {
                if keyType.hasSuffix("?") {
                    lines += [
                        indentBy + indentBy + "if let \(key.name) {",
                        indentBy + indentBy + indentBy + "statePath = parent.adding(\(keyType.asPathParam(name, name: key.name.initialLowercase)))",
                        indentBy + indentBy + "} else {",
                        indentBy + indentBy + indentBy + "statePath =  parent.adding(.wild(\"\(name)\"))",
                        indentBy + indentBy + "}",
                        "",
                    ]
                } else {
                    lines += [
                        indentBy + indentBy + "statePath = parent.adding(\(keyType.asPathParam(name, name: key.name.initialLowercase)))",
                        "",
                    ]
                }
            } else {
                lines += [
                    indentBy + indentBy + "statePath = parent.adding(.plain(\"\(name)\"))",
                    "",
                ]
            }
            
            declareLeafs()
            lines.append(indentBy + "}")
            // now make the generic version
            lines.append(indentBy + "public init(parent: \(qparent), statePath: StatePath) {")
            lines.append(indentBy + indentBy + "self.parent = parent")
            lines.append(indentBy + indentBy + "self.statePath = statePath")
            declareLeafs()
            lines.append(indentBy + "}")
            lines.append("}")

            // the declaration in the parent (either in this file or at the root as an extension)
            func addParentVar(indent: String = "", parent: String = "") {
                if let key, let keyType = key.keyType {
                    let qualified = keyType == "Kind" ? "\(name).Kind" : keyType
                    let defaultValue = keyType.hasSuffix("?") ? " = nil" : ""
                    lines.append("\(indent)public func \(name.initialLowercase)(_ \(key.name.initialLowercase): \(qualified)\(defaultValue)) -> \(name)\(parent) { .init(parent: self, \(key.name.initialLowercase): \(key.name.initialLowercase)) }")
                } else {
                    lines.append("\(indent)public var \(name.initialLowercase): \(name)\(parent) { .init(parent: self) }")
                }
            }
            if let parent2 {
                for aParent in parent2.components(separatedBy: " ") {
                    let qparent : String
                    if aParent.hasSuffix(">") {
                        qparent = aParent.split(separator: "<").first.flatMap{String($0)}!
                    } else {
                        qparent = aParent
                    }
                    lines += [ "extension \(qparent) {"]
                    if parent2.contains(" ") {
                        // needs to qualify this
                        addParentVar(indent: indentBy, parent: "<\(qparent)>")
                    } else if parent2.hasSuffix(">") {
                        // needs to qualify this
                        addParentVar(indent: indentBy, parent: "<P>")
                    } else {
                        addParentVar(indent: indentBy)
                    }
                    lines += [ "}"]
                }
            } else {
                addParentVar()
            }

        }
        switch kind {
        case .enum:
            lines.append("}")
        case .node(let parent2):
            declareInit(parent2: parent2)
        case .root:
            lines.append(indentBy + "public init(connection: Connection) {")
            lines.append(indentBy + indentBy + "self.connection = connection")
            lines.append(indentBy + indentBy + "let dummy = Leaf<Bool>(connection: connection, component: .wild(\"\"), parentPath: .init(components: []))")
            declareLeafs(dummy: "dummy")
            lines.append(indentBy + "}")
            lines.append("}")
        default:
            break
        }
        return lines.map{indent + $0}

    }
}

func parseAST(source: String) throws -> [AST] {
    var document: [AST] = []
    var astStack: [AST] = [] {
        willSet {
            // automatically link as part of the parent
            if let parent = astStack.last, let child = newValue.last, astStack.count + 1 == newValue.count {
                parent.children.append(child)
            }
        }
    }
    var lineNum = 0
    for line in source.split(separator: "\n") {
        lineNum += 1
        let trim = line.trimmingCharacters(in: .whitespaces)
        if trim.hasPrefix("//") || trim.isEmpty {
            if astStack.isEmpty {
                document.append(.init(kind: .comment, name: trim))
            } else {
                astStack.last?.children.append(.init(kind: .comment, name: trim))
            }
            continue // a comment
        } else if trim.hasPrefix("!") {
            let code = AST(kind: .code, name: .init(trim.dropFirst().trimmingCharacters(in: .whitespaces)))
            if astStack.isEmpty {
                document.append(code)
            } else {
                astStack.last?.children.append(code)
            }
            continue // verbatim code
        }
        let parts = trim.components(separatedBy: .whitespaces)
            .flatMap { str in
                // strip punct into its own token
                var retval : [String] = []
                var next: String = ""
                func finishCurrent() {
                    if next != "" {
                        retval.append(next)
                    }
                    next = ""
                }
                for c in str {
                    switch c {
                    case "[", "]", ":", "(", ")", "{", "}", ".":
                        finishCurrent()
                        retval.append(.init(c))
                    default:
                        next.append(c)
                    }
                }
                finishCurrent()
                return retval
            }
        // this to make parsing the parts more like a tokenizer
        var tokenIndex = 0
        var token : String? {
            if tokenIndex < parts.count {
                return parts[tokenIndex]
            } else {
                return nil
            }
        }
        var isAtEOL: Bool {
            tokenIndex >= parts.count
        }
        @discardableResult
        func nextToken() -> String? {
            tokenIndex += 1
            return token
        }
        func hasNext(_ str: String) -> Bool {
            tokenIndex += 1
            if token == str {
                return true
            }
            tokenIndex -= 1
            return false
        }
        func expect(_ str: String) throws {
            guard nextToken() == str else {
                print("Error line \(lineNum): expected \(str), in \(parts)")
                throw Errors.expected(str)
            }
        }
        func nextTokenList() -> String? {
            tokenIndex += 1
            if token == "{" {
                tokenIndex -= 1
                return nil
            }
            var retval = token
            if retval?.hasPrefix("<") == true {
                retval = retval.map{String($0.dropFirst())}
                while true {
                    tokenIndex += 1
                    if let next = token {
                        retval?.append(" ")
                        if next.hasSuffix(">") == true {
                            retval?.append(String(next.dropLast()))
                            break
                        } else {
                            retval?.append(next)
                        }
                    } else {
                        break
                    }
                }
            }
            return retval
        }
        func rest() -> String {
            guard tokenIndex < parts.count - 1 else {
                return ""
            }
            return .init(parts[(tokenIndex+1)...].joined(separator: " "))
        }
        switch token {
        case "}":
            _ = astStack.popLast()
        case "root":
            guard astStack.isEmpty else {
                throw Errors.rootNodeNotAtRoot
            }
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            let node = AST(kind: .root, name: name)
            document.append(node)
            astStack.append(node)
            try expect("{")
        case "node":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            let node: AST
            if let parent = nextTokenList() {
                node = .init(kind: .node(parent: parent), name: name)
            } else {
                node = .init(kind: .node(parent: nil), name: name)
            }
            if astStack.isEmpty {
                document.append(node)
            }
            astStack.append(node)
            try expect("{")
        case "ref":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .ref(type), name: name))
        case "leaf", "var":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .leaf(type, immutable: false), name: name))
        case "let":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .leaf(type, immutable: true), name: name))
        case "list":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .list(type), name: name))
        case "flag":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
//            astStack.last?.children.append(.init(kind: .flag, name: name))
            astStack.last?.children.append(.init(kind: .leaf("Bool", immutable: false), name: name))
        case "subscript":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .subscript(type), name: name))
        case "map":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect("[")
            guard let index = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect("]")
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .map(type, index: index), name: name))
        case "key":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            try expect(":")
            guard let type = nextToken() else {
                throw Errors.missingLeafType
            }
            astStack.last?.children.append(.init(kind: .key(type), name: name))
        case "enum":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            astStack.append(.init(kind: .enum, name: name))
            try expect("{")
        case "case":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            if hasNext("=") {
                let value = nextToken()
                astStack.last?.children.append(.init(kind: .case(value), name: name))
            } else {
                astStack.last?.children.append(.init(kind: .case(nil), name: name))
            }
        case "action":
            guard let name = nextToken() else {
                throw Errors.missingNodeName
            }
            astStack.last?.children.append(.init(kind: .action, name: name))
        default:
            throw Errors.syntaxError
        }
    }
    return document
}

do {
    let source = try String(contentsOfFile: inputFileName)
    let destURL = URL(fileURLWithPath: outputFolder, isDirectory: false)
    try FileManager.default.createDirectory(at: destURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    let document = try parseAST(source: source)
//    var output = ""
    for root in document {
        switch root.kind {
        case .node, .root:
            print("=========\(root.name)=======")
//            print(try root.generate())
//            output.append(try root.generate())
//            output.append("\n")
            try root.save(destURL: destURL)
        default:
            break
        }
    }
//    try output.data(using: .utf8)?.write(to: destURL)
} catch {
    print("Error: \(error)")
    exit(-1)
}
    
