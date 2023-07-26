//
//  Connection.swift
//  Statter
//
//  Created by gandreas on 7/19/23.
//

import Foundation
import SwiftUI
import Combine

//@dynamicMemberLookup
/// The primary connection with the scoreboard server
public class Connection : ObservableObject, Equatable {
    /// Create a connection to a scoreboard server.  The connection won't
    /// be active until ``connect()`` is called
    /// - Parameters:
    ///   - host: The scoreboard server host
    ///   - port: The scoreboard server port
    ///   - operatorName: The scoreboard server name
    ///   - source: The starting source refrence
    ///   - urlSession: A custom urlSession
    ///   - webSocketFailedHandler: A handler to call if websockets fail
    public init(host: String? = "10.0.0.10", port: Int = 8000, operatorName: String = "statter", source: Connection.Source = .root, urlSession: URLSession = .shared, webSocketFailedHandler: (() -> Void)? = nil) {
        self.host = host
        self.port = port
        self.operatorName = operatorName
        self.source = source
        self.urlSession = urlSession
        self.webSocketFailedHandler = webSocketFailedHandler
    }
    
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.webSocket == rhs.webSocket && lhs.webSocketURL == rhs.webSocketURL
    }
    
    /// Errors that can be generated
    public enum Errors : Error {
        case noConnection
    }
    /// The scoreboard URL host
    public var host: String? = "10.0.0.10"
    /// The scoreboard URL port
    public var port: Int = 8000
    
    /// The name of the NSO operator (if specified).  This should be
    /// only changed before changing source or
    public var operatorName: String? {
        didSet {
            operatorName = nil
        }
    }

    
    /// If we are editing a team, we specify this
    public var teamEditing: String? {
        didSet {
            operatorName = nil
        }
    }

    /// The various kinds of "views" of the scoreboard.  This apparently
    /// helps in the delivery of messages based on what the screen should show
    public enum Source : String {
        /// Root of the display
        case root
        /// Scoreboard operator
        case sbo = "/nso/sbo"
        /// Jam timer
        case jt = "/nso/jt"
        /// Scoreboard view
        case sb = "/views/standard"
        ///
        //  /settings/teams/?team=Black
    }
    /// What the current source for the view should be
    /// This will disconnect and start a new connection when changed
    @Published public var source: Source = .root {
        didSet {
            webSocket?.cancel(with: .normalClosure, reason: nil)
            webSocket = nil
            state = [:]
            registered = []
            connect()
        }
    }
    /// Derived base URL based on host and port
    var baseURL: URL? {
        guard let host else {
            return nil
        }
        return URL(string: "ws://\(host):\(port)/WS")
    }
    
    /// Get the url on the server for some asset path
    /// - Parameter path: The asset path
    /// - Returns: The url, if possible
    public func url(for path: String?) -> URL? {
        guard let host, let path else {
            return nil
        }
        return URL(string: "http://\(host):\(port)")?.appendingPathComponent(path)
    }
    /// The URL for the web socket API
    var webSocketURL: URL? {
        var source: String
        // Add game and operator to the source
        if let gameID = game?.game {
            source = self.source.rawValue + "?game=\(gameID)&"
        } else {
            source = self.source.rawValue + "?"
        }
        if let teamEditing {
            source += "team=\(teamEditing)"
        } else if let operatorName {
            source += "operator=\(operatorName)"
        }
//        #if os(watchOS)
//        let platform = "appleWatch; ARM64 Mac OS X 10_15_7"
//        #else
        let platform = "Macintosh; Intel Mac OS X 10_15_7"
//        #endif
        return baseURL?.appending(queryItems: [
//            .init(name:"source", value: "/nso/sbo/?game=b6003f5f-f4a4-477c-8856-ccdf363fa4ff"),
            // This is not required, but helps figure out which device is which.
//            .init(name:"source", value: "/nso/plt/?zoomable=0&team=1&game=b6003f5f-f4a4-477c-8856-ccdf363fa4ff"),
            .init(name:"source", value:source),
            .init(name:"platform", value: platform)
        ])
    }


    /// support for custom url sessions
    var urlSession : URLSession = .shared
    
    /// Various debugging flags
    public struct DebugFlags: OptionSet {
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public var rawValue: Int
        static let webSockets = DebugFlags(rawValue: 1 << 0)
        static let outgoing = DebugFlags(rawValue: 1 << 1)
        static let incoming = DebugFlags(rawValue: 1 << 2)
        static let registering = DebugFlags(rawValue: 1 << 3)
    }
    /// what are the currently active debugging flags?
    public var debugFlags: [DebugFlags] = []

    /// The current web socket task - use a single web socket if possible
    @Published var webSocket : URLSessionWebSocketTask?
    
    /// Are we currently connected (or at least do we have a socket task)
    public var isConnected: Bool {
        webSocket != nil
    }
    
    // Since not everything is SwiftUI, we provide addtional hooks for observing data changes on the scoreboard
    
    public struct StateDataChangeMessage {
        var path: StatePath
        var oldValue: JSONValue?
        var newValue: JSONValue
    }
    public var stateDataDidChange : PassthroughSubject<StateDataChangeMessage, Never> = .init()
    ///
    /// Create the websocket task, if possible (but not started yet)
    /// - Returns: The new websocket task
    func createWebSocket() -> URLSessionWebSocketTask? {
        guard let webSocketURL else {
            return nil
        }
        var urlRequest = URLRequest(url: webSocketURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)

        // add the protocol we support
//        urlRequest.addValue("graphql-transport-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol") // newer server
        urlRequest.addValue("websocket", forHTTPHeaderField: "Upgrade")
        urlRequest.addValue("Upgrade", forHTTPHeaderField: "Connection")

        let retval = urlSession.webSocketTask(with: urlRequest)
//            retval.delegate = delegate
        return retval
    }
    
    
    /// The first step on openning a web socket, which opens the we socket, authorizes it,
    /// and then finally calls the closure
    /// - Parameter then: The closure to call after openning and authenticating the web socket
    func openWebSocket(then: @escaping (Result<URLSessionWebSocketTask, Error>)->Void) {
        if let webSocket = webSocket {
            then(.success(webSocket))
        } else {
            guard let socket = createWebSocket() else {
                then(.failure(Errors.noConnection))
                return
            }
            webSocket = socket
            socket.resume()
            if debugFlags.contains(.webSockets) {
                print("WS:Starting ping [\(socket.taskIdentifier)]")
            }
            sendDelayedPing(socket)
            then(.success(socket))
        }
    }

    /// A count of the number of pings that have failed in the websocket task
    /// Note this needs to be per socket (since reconnecting after suspension will
    /// cause multiple task - both one that works and another that fails, with the
    /// working one reseting "failed" to zero and the failing one never going away)
    var failedPings : [Int: Int] = [:]
    /// A ping that we send (every 10 seconds) to make sure the websocket stays alive
    /// - Parameter socket: The socket task to ping.
    func sendDelayedPing(_ socket: URLSessionWebSocketTask, delay: TimeInterval = 30.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.debugFlags.contains(.webSockets) {
                print("WS: Websocket ping")
            }
            socket.sendPing { [self] error in
                let nextDelay: TimeInterval
                if let error = error {
                    if debugFlags.contains(.webSockets) {
                        print("WS: ping error [\(socket.taskIdentifier)] \(error)")
                    }
                    nextDelay = 3 // every 3 seconds if we fail
                    self.failedPings[socket.taskIdentifier] = self.failedPings[socket.taskIdentifier, default: 0] + 1
//                    failedPings += 1
                    if self.failedPings[socket.taskIdentifier, default: 0] >= 3 {
                        // well now we've got problems
                        self.failedPings[socket.taskIdentifier] = nil
                        if self.webSocket == socket {
                            DispatchQueue.main.async {
                                self.webSocket = nil // try opening a new connection (but only if it is this socket)
                                // indicate that things bailed after we nilled out websocket
                                // so we don't open one just before closing it.  Don't complain
                                // if our socket isn't the "current" socket
                                self.webSocketFailedHandler?()
                            }
                        }
                        return // and don't keep pinging
                    }
                } else {
                    self.failedPings[socket.taskIdentifier] = nil
                    nextDelay = 20 // only every 20 seconds if we work
//                    failedPings = 0
//                    gLog.status("Websocket pong")
                }
                self.sendDelayedPing(socket, delay: nextDelay)
            }
        }
    }

    /// The handler to call on web socket failure
    public var webSocketFailedHandler: (()->Void)?
    
    /// An error that we ran into while dealing with the socket
    @Published public var error: Error?
    
    /// Start connecting to the server and get some basic operations
    public func connect() {
        openWebSocket { [self] result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success(_):
                self.error = nil
                _ = ws.device.name // this will register it
                _ = scoreBoard.currentGame.game
                _ = ws.device.id
                _ = ws.client.remoteAddress
//                _ = scoreBoard.version(.release)
                _ = scoreBoard.version[.release]
                _ = scoreBoard.clients.device().comment
                self.getPacket()
            }
        }
    }
    
    /// The WS of the current connection
    public var ws: WS { .init(connection: self) }
    /// The root ScoreBoard of the current connection
    public var scoreBoard: ScoreBoard { .init(connection: self) }
    
    /// Used to track what paths we need to register to
    var toRegister: [PathSpecified] = []
    /// Defer adding a path to register, allowing us to collect multiple paths into a single transaction
    /// - Parameter path: The path to add
    public func register(path: PathSpecified) {
        if debugFlags.contains(.registering) {
            print("=== Register \(path.statePath.description)")
        }
        if toRegister.contains(where: { $0.statePath.description == path.statePath.description }) {
            return
        }
        if registered.contains(path.statePath) {
            // already registered
            return
        }
        toRegister.append(path)
        DispatchQueue.main.async {
            guard self.toRegister.isEmpty == false else {
                return
            }
            self.register()
        }
    }
    /// Register paths with the scoreboard
    /// - Parameter paths: Paths to explicitly register
    ///
    /// Note that any access to a ``Leaf`` value will implicitly register
    /// that with the scoreboard, but those registrations won't happen
    /// until this routine is called (which will happen automatically ever time
    /// we process a message from the server)
    public func register(_ paths: PathSpecified...) {
        guard let webSocket else {
            if debugFlags.contains(.webSockets) {
                print("Defer Registering for \(paths.map{$0.statePath.description}.joined(separator: ", "))")
            }
            toRegister.append(contentsOf: paths)
            return
        }
        struct RegisterCommand: Codable {
            var action: String = "Register"
            var paths: [StatePath]
        }
        let command = RegisterCommand(paths: toRegister.map{$0.statePath} + paths.map{$0.statePath})
        registered.formUnion(toRegister.map{$0.statePath})
        registered.formUnion(paths.map{$0.statePath})
        toRegister = []
        send(command: command)
    }
    
    /// Actually send data over the websocket
    /// - Parameter command: <#command description#>
    public func send<Command: Encodable>(command: Command) {
        guard let webSocket else {
            // do we want to collect and defer this?
            return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        if let data = try? encoder.encode(command), let src = String(data: data, encoding: .utf8) {
            if debugFlags.contains(.outgoing) {
                print(">>> Sent \(src)")
            }
            webSocket.send(.string(src)) { error in
                // we use the callback version since this is self contained anyway
                DispatchQueue.main.async {
                    if error == nil {
//                        if self.debugFlags.contains(.registering) {
//                            "Registered for \((command.paths.map{$0.description}).joined(separator: ", "))")
//                        }
                    } else {
                        print(error!)
                        self.error = error
                    }
                }
            }
        }
    }
    /// What the server thinks our device "name" is
    @Published public var deviceName: String?
        
    /// The current game
    @Published public var game: Game?
    
    /// Get the next packet and process it.  We also flush the register
    /// Once the message is recieved we queue up another call to get the next packet
    func getPacket() {
        if toRegister.isEmpty == false {
            // we had stuff to register initially but couldn't
            register()
        }
        webSocket?.receive { result in
            if self.debugFlags.contains(.incoming) {
                print("<<< \(result)")
            }
            DispatchQueue.main.async { [self] in
                switch result {
                case .failure(let error):
                    self.error = error
                case .success(let message):
                    let data: Data?
                    switch message {
                    case .data(let d): data = d
                    case .string(let s): data = s.data(using: .utf8)
                    @unknown default:
                        fatalError()
                    }
                    struct StateMessage: Decodable {
                        var state: [String : JSONValue]
                    }
                    if let data, let newState = try? JSONDecoder().decode(StateMessage.self, from: data) {
                        self.objectWillChange.send()
                        for newStatePair in newState.state {
                            // should check the key for special handling
                            let key = StatePath(from: newStatePair.key)
                            switch key.description {
                            case "WS.Device.Name":
                                deviceName = newStatePair.value.stringValue
                            case "ScoreBoard.CurrentGame.Game":
//                                print("Current game = \(newStatePair.value)")
                                guard let id = newStatePair.value.stringValue.flatMap({UUID(uuidString: $0)}) else {
                                    break
                                }
//                                self.game = ScoreBoard(connection: self).game(id)
                                self.game = ScoreBoard(connection: self).currentGame
                            default:
                                break
                            }
                            let oldValue = state[key]
                            state[key] = newStatePair.value
                            stateDataDidChange.send(.init(path: key, oldValue: oldValue, newValue: newStatePair.value))
                        }
                    } else {
                        if let data {
//                            print("Unable to decode data")
                            if let string = String(data: data, encoding: .utf8) {
                                print(string)
                            }
                        }
                    }
                    error = nil
                    getPacket()
                }
            }
        }
    }
    
    /// This is the master state that contains what the current values from the SB are
    public var state: [StatePath: JSONValue] = [:]
    
    /// A list of everything we've registered (so we only do it once)
    var registered = Set<StatePath>()
    
    /// used to determine the current state change
    var stateChange = StateChange.set
    
    /// Convenience to fetch state via a path
    public subscript(path: PathSpecified) -> JSONValue? {
        state[path.statePath]
    }
}
