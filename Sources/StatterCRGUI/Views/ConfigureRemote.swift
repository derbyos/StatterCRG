//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 9/19/23.
//

import SwiftUI

public struct ConfigureRemote<Action:RemoteControlAction> : View {
    public init(remote: RemoteControl<Action>) {
        _remote = .init(initialValue: remote)
    }
    @ObservedObject var remote: RemoteControl<Action>
    
    struct BindRemoteButton : View {
        @ObservedObject var remote: RemoteControl<Action>
        var action: Action
        @State var watching: Bool = false
        var body: some View {
            Capsule(style: .circular)
                .stroke(lineWidth: 1.0)
                .background(content: {
                    if watching {
                        Capsule(style: .circular)
                    }
                })
                .overlay(content: {
                    if let button = remote.event(for: action), let icon = remote.icons[button] {
                        Image(systemName: icon)
                            .imageScale(.large)
                            .foregroundColor(watching ? .red : .primary)
                    }
                })
                .frame(width: 65)
                .contentShape(Capsule(style: .circular))
                .onTapGesture {
                    if !watching {
                        for kv in remote.bindings {
                            if kv.value == action {
                                remote.bindings[kv.key] = nil
                            }
                        }
                        remote.state = .bindAction(action)
                    } else {
                        remote.state = .ignoringEvents
                    }
                }
                .onChange(of: remote.state) { _ in
                    switch remote.state {
                    case .ignoringEvents: watching = false
                    case .bindAction(let a): watching = a == action
                    case .sendAction: watching = false
                    }
                }
        }
    }
    public var body: some View {
        List {
            ForEach(Action.allCases.map{$0}, id: \.self) { action in
                HStack {
                    Text(action.description)
                    Spacer()
                    BindRemoteButton(remote: remote, action: action)
                }
            }
        }
    }
}

fileprivate enum TestAction : String, RemoteControlAction {
    var description: String { rawValue }
    
    case primary = "Primary"
    case secondary = "Secondary"
}
#Preview {
    ConfigureRemote(remote: RemoteControl<TestAction>())
}
