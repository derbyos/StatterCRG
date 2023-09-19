//
//  File.swift
//  
//
//  Created by gandreas on 9/19/23.
//

import Foundation
import SwiftUI
import Combine
#if os(iOS)
import GameController
#endif
/// Protocol for an action that can be triggered via a remote control.  The name is in the `description`
public protocol RemoteControlAction : Equatable, Hashable, CustomStringConvertible, CaseIterable {
    
}
/// A class to handle remote control interaction like game pads or BT keyboards
public class RemoteControl<Action:RemoteControlAction> : ObservableObject {
    
    public init() {
        #if os(iOS)
        watchForControllers()
        #endif
    }
    /// A publisher that sends actions corresponding to remove events
    public var actionReceived: PassthroughSubject<Action, Never> = .init()
    /// What do we do with a remote control event?
    public enum State : Equatable {
        /// Ignore the remote events
        case ignoringEvents
        /// Default to sending the action
        case sendAction
        /// Binding the even to this action
        case bindAction(Action)
    }
    /// Our current event handling state
    @Published public var state: State = .ignoringEvents
    
    /// The current map of event -> actions
    @Published public var bindings: [RemoteEvent : Action] = [:]
    /// Buttons on remote events
    public enum RemoteEvent : Hashable, Equatable {
        case buttonA
        case buttonB
        case buttonX
        case buttonY
        case leftShoulder
        case rightShoulder
        case buttonMenu
        case buttonOptions
        case buttonHome
        case up
        case down
        case left
        case right
    }
    /// The icons that correspond to the various buttons
    @Published public var icons: [RemoteEvent: String] = [
        .buttonA: "a.circle",
        .buttonB: "b.circle",
        .buttonX: "x.circle",
        .buttonY: "y.circle",
        .up: "dpad.up.filled",
        .down: "dpad.down.filled",
        .left: "dpad.left.filled",
        .right: "dpad.right.filled",
        .leftShoulder: "lt.rectangle.roundedtop",
        .rightShoulder: "rt.rectangle.roundedtop",
    ]
    /// Get the current event for this action (we assume a single event per action)
    func event(for action: Action) -> RemoteEvent? {
        bindings.first(where: {$0.value == action})?.key
    }
    #if os(iOS)
    // Note that we assume only a single game controller, otherwise the debounce logic will get confused
    var buttons: Set<RemoteEvent> = []
    func send(event: RemoteEvent, pressed: Bool) {
        // needs to be done on main event loop
        DispatchQueue.main.async { [self] in
            if pressed {
                if buttons.contains(event) {
                    // didn't change
                } else {
                    // send the event, ignore it, bind it, whatever
                    buttons.insert(event)
                    switch state {
                    case .ignoringEvents:
                        break // do nothing
                    case .sendAction:
                        if let action = bindings[event] {
                            actionReceived.send(action)
                        }
                    case .bindAction(let action):
                        // we only support binding a single event to a single action
                        bindings.forEach { (k,v) in
                            if v == action {
                                bindings[k] = nil
                            }
                        }
                        bindings[event] = action
                    }
                }
            } else {
                buttons.remove(event)
            }
        }
    }
    func watchForControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers(_:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    @objc func connectControllers(_ notif: Notification) {
        for controller in GCController.controllers() {
            // note that we don't care which controller sends the info, they will all map the same
            if let extended = controller.extendedGamepad {
                if let icon = extended.buttonA.sfSymbolsName { icons[.buttonA] = icon }
                if let icon = extended.buttonB.sfSymbolsName { icons[.buttonB] = icon }
                if let icon = extended.buttonX.sfSymbolsName { icons[.buttonX] = icon }
                if let icon = extended.buttonY.sfSymbolsName { icons[.buttonY] = icon }
                if let icon = extended.leftShoulder.sfSymbolsName { icons[.leftShoulder] = icon }
                if let icon = extended.rightShoulder.sfSymbolsName { icons[.rightShoulder] = icon }
                if let icon = extended.buttonMenu.sfSymbolsName { icons[.buttonMenu] = icon }
                if let icon = extended.buttonHome?.sfSymbolsName { icons[.buttonHome] = icon }
                if let icon = extended.buttonOptions?.sfSymbolsName { icons[.buttonOptions] = icon }
                if let icon = extended.leftThumbstick.up.sfSymbolsName { icons[.up] = icon }
                if let icon = extended.leftThumbstick.down.sfSymbolsName { icons[.down] = icon }
                if let icon = extended.leftThumbstick.left.sfSymbolsName { icons[.left] = icon }
                if let icon = extended.leftThumbstick.right.sfSymbolsName { icons[.right] = icon }
                if let icon = extended.rightThumbstick.up.sfSymbolsName { icons[.up] = icon }
                if let icon = extended.rightThumbstick.down.sfSymbolsName { icons[.down] = icon }
                if let icon = extended.rightThumbstick.left.sfSymbolsName { icons[.left] = icon }
                if let icon = extended.rightThumbstick.right.sfSymbolsName { icons[.right] = icon }
                if let icon = extended.dpad.up.sfSymbolsName { icons[.up] = icon }
                if let icon = extended.dpad.down.sfSymbolsName { icons[.down] = icon }
                if let icon = extended.dpad.left.sfSymbolsName { icons[.left] = icon }
                if let icon = extended.dpad.right.sfSymbolsName { icons[.right] = icon }
                extended.valueChangedHandler = { [weak self] gamepad, element in
                    guard let self else { return }
                    if gamepad.buttonA == element {
                        self.send(event: .buttonA, pressed: gamepad.buttonA.isPressed)
                    }
                    if gamepad.buttonB == element {
                        self.send(event: .buttonB, pressed: gamepad.buttonB.isPressed)
                    }
                    if gamepad.buttonX == element {
                        self.send(event: .buttonX, pressed: gamepad.buttonX.isPressed)
                    }
                    if gamepad.buttonY == element {
                        self.send(event: .buttonY, pressed: gamepad.buttonY.isPressed)
                    }
                    if gamepad.buttonMenu == element {
                        self.send(event: .buttonMenu, pressed: gamepad.buttonMenu.isPressed)
                    }
                    if gamepad.buttonOptions == element {
                        self.send(event: .buttonOptions, pressed: gamepad.buttonOptions?.isPressed == true)
                    }
                    if gamepad.buttonHome == element {
                        self.send(event: .buttonHome, pressed: gamepad.buttonHome?.isPressed == true)
                    }
                    if gamepad.leftShoulder == element {
                        self.send(event: .leftShoulder, pressed: gamepad.leftShoulder.isPressed)
                    }
                    if gamepad.rightShoulder == element {
                        self.send(event: .rightShoulder, pressed: gamepad.rightShoulder.isPressed)
                    }
                    if gamepad.dpad == element {
                        self.send(event: .left, pressed: gamepad.dpad.left.isPressed)
                        self.send(event: .right, pressed: gamepad.dpad.right.isPressed)
                        self.send(event: .up, pressed: gamepad.dpad.up.isPressed)
                        self.send(event: .down, pressed: gamepad.dpad.down.isPressed)
                    }
                    if gamepad.leftThumbstick == element {
                        self.send(event: .left, pressed: gamepad.leftThumbstick.xAxis.value < -0.5)
                        self.send(event: .right, pressed: gamepad.leftThumbstick.xAxis.value > 0.5)
                        self.send(event: .down, pressed: gamepad.leftThumbstick.yAxis.value < -0.5)
                        self.send(event: .up, pressed: gamepad.leftThumbstick.yAxis.value > 0.5)
                    }
                    if gamepad.rightThumbstick == element {
                        self.send(event: .left, pressed: gamepad.rightThumbstick.xAxis.value < -0.5)
                        self.send(event: .right, pressed: gamepad.rightThumbstick.xAxis.value > 0.5)
                        self.send(event: .down, pressed: gamepad.rightThumbstick.yAxis.value < -0.5)
                        self.send(event: .up, pressed: gamepad.rightThumbstick.yAxis.value > 0.5)
                    }
                }
            } else if let basic = controller.gamepad {
                if let icon = basic.buttonA.sfSymbolsName { icons[.buttonA] = icon }
                if let icon = basic.buttonB.sfSymbolsName { icons[.buttonB] = icon }
                if let icon = basic.buttonX.sfSymbolsName { icons[.buttonX] = icon }
                if let icon = basic.buttonY.sfSymbolsName { icons[.buttonY] = icon }
                if let icon = basic.leftShoulder.sfSymbolsName { icons[.leftShoulder] = icon }
                if let icon = basic.rightShoulder.sfSymbolsName { icons[.rightShoulder] = icon }
                if let icon = basic.dpad.up.sfSymbolsName { icons[.up] = icon }
                if let icon = basic.dpad.down.sfSymbolsName { icons[.down] = icon }
                if let icon = basic.dpad.left.sfSymbolsName { icons[.left] = icon }
                if let icon = basic.dpad.right.sfSymbolsName { icons[.right] = icon }
                basic.valueChangedHandler = { [weak self] gamepad, element in
                    guard let self else { return }
                    if gamepad.buttonA == element {
                        self.send(event: .buttonA, pressed: gamepad.buttonA.isPressed)
                    }
                    if gamepad.buttonB == element {
                        self.send(event: .buttonB, pressed: gamepad.buttonB.isPressed)
                    }
                    if gamepad.buttonX == element {
                        self.send(event: .buttonX, pressed: gamepad.buttonX.isPressed)
                    }
                    if gamepad.buttonY == element {
                        self.send(event: .buttonY, pressed: gamepad.buttonY.isPressed)
                    }
                    if gamepad.leftShoulder == element {
                        self.send(event: .leftShoulder, pressed: gamepad.leftShoulder.isPressed)
                    }
                    if gamepad.rightShoulder == element {
                        self.send(event: .rightShoulder, pressed: gamepad.rightShoulder.isPressed)
                    }
                    if gamepad.dpad == element {
                        self.send(event: .left, pressed: gamepad.dpad.left.isPressed)
                        self.send(event: .right, pressed: gamepad.dpad.right.isPressed)
                        self.send(event: .up, pressed: gamepad.dpad.up.isPressed)
                        self.send(event: .down, pressed: gamepad.dpad.down.isPressed)
                    }
                }
            } else if let micro = controller.microGamepad {
                if let icon = micro.buttonA.sfSymbolsName { icons[.buttonA] = icon }
                if let icon = micro.buttonX.sfSymbolsName { icons[.buttonX] = icon }
                if let icon = micro.buttonMenu.sfSymbolsName { icons[.buttonMenu] = icon }
                if let icon = micro.dpad.up.sfSymbolsName { icons[.up] = icon }
                if let icon = micro.dpad.down.sfSymbolsName { icons[.down] = icon }
                if let icon = micro.dpad.left.sfSymbolsName { icons[.left] = icon }
                if let icon = micro.dpad.right.sfSymbolsName { icons[.right] = icon }
                micro.valueChangedHandler = { [weak self] gamepad, element in
                    guard let self else { return }
                    if gamepad.buttonA == element {
                        self.send(event: .buttonA, pressed: gamepad.buttonA.isPressed)
                    }
                    if gamepad.buttonX == element {
                        self.send(event: .buttonX, pressed: gamepad.buttonX.isPressed)
                    }
                    if gamepad.buttonMenu == element {
                        self.send(event: .buttonMenu, pressed: gamepad.buttonMenu.isPressed)
                    }
                    if gamepad.dpad == element {
                        self.send(event: .left, pressed: gamepad.dpad.left.isPressed)
                        self.send(event: .right, pressed: gamepad.dpad.right.isPressed)
                        self.send(event: .up, pressed: gamepad.dpad.up.isPressed)
                        self.send(event: .down, pressed: gamepad.dpad.down.isPressed)
                    }
                }
            }
        }
    }
    @objc func disconnectControllers(_ notif: Notification) {
    }
    #endif
}
