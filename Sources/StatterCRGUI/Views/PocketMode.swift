//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 9/19/23.
//

import SwiftUI

/// A wrapper view that includes the ability to "lock" the screen (and also handles dimming?) so
/// the app can be put in a pocket yet still be kept live
struct PocketMode<Content:View>: View {
    init(lockWidth: CGFloat = 300, @ViewBuilder content: @escaping (Bool) -> Content) {
        self.lockWidth = lockWidth
        self.content = content
    }
    var lockWidth: CGFloat = 300
    var thumbSize: CGFloat = 55
    var lockHeight: CGFloat = 50
    @State private var isUnlocked = true
    @GestureState private var dragWidth: CGFloat = 55
    var content: (Bool)->Content
    
    @State var defaultBrightness: CGFloat = 1.0
    #if targetEnvironment(simulator)
    @State var screenBrightness: CGFloat = 1.0
    #else
    var screenBrightness: CGFloat {
        get {
            #if os(iOS)
            UIScreen.main.brightness
            #else
            1.0
            #endif
        }
        nonmutating set {
            #if os(iOS)
            UIScreen.main.brightness = newValue
            #else
            #endif
        }
    }
    #endif
    var body: some View {
        VStack {
            content(isUnlocked)
                .disabled(isUnlocked == false)
            #if targetEnvironment(simulator)
            Rectangle()
                .foregroundColor(.init(white: Double(screenBrightness)))
            #endif
            Spacer()
            Group {
                if isUnlocked {
                    Button(action: {
                        isUnlocked = false
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .circular)
                                .foregroundColor(Color.red)
                            Text("Lock")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    })
                    .buttonStyle(.borderless)
                } else {
                    // slide to unlock
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 15, style: .circular)
                            .foregroundColor(Color.green)
                            .overlay(alignment: .center) {
                                Text("Slide To Unlock")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        RoundedRectangle(cornerRadius: 14, style: .circular)
                            .inset(by: 2)
                            .foregroundColor(.blue)
                            .frame(width: dragWidth, height: lockHeight - 1, alignment: .leading)
                            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: dragWidth)
                            .onTapGesture {
                                screenBrightness = defaultBrightness * 0.75
                            }
                            .overlay(alignment: .trailing) {
                                RoundedRectangle(cornerRadius: 13, style: .circular)
                                    .inset(by: 2)
                                    .foregroundColor(.white)
                                    .gesture(
                                        DragGesture(coordinateSpace: .global)
                                            .updating($dragWidth, body: { value, state, _ in
                                                screenBrightness = defaultBrightness * 0.75
                                                if value.translation.width > 0 {
                                                    state = min(50 + value.translation.width, lockWidth)
                                                }
                                                if state >= lockWidth {
                                                    DispatchQueue.main.async {
                                                        withAnimation {
                                                            isUnlocked = true
                                                        }
                                                    }
                                                }
                                            })
                                    )
                                    .frame(width: thumbSize-2, height: lockHeight-2)
                                    .padding(.trailing, 0.5)
                                //                            .offset(x: lockWidth - thumbSize, y: 0)
                                    .overlay {
                                        if dragWidth >= lockWidth {
                                            Image(systemName: "lock.open")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "lock")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: dragWidth)
                            }
                    }
                }
            }
            .frame(width: lockWidth, height: lockHeight)
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // if we tap on it while locked, restore brightness
            if isUnlocked == false {
                screenBrightness = defaultBrightness * 0.75
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    // if still locked after 5 seconds, dim
                    if isUnlocked == false {
                        screenBrightness = 0.0
                    }
                }
                )
            }
        }
        .onChange(of: isUnlocked, perform: { value in
            if isUnlocked {
                screenBrightness = defaultBrightness
            } else {
                screenBrightness = 0.0
            }
        })
        .onAppear {
            defaultBrightness = screenBrightness
        }
    }
}

#Preview {
    PocketMode { unlocked in
        if unlocked {
            Image(systemName: "lock.open")
        } else {
            Image(systemName: "lock")
        }
        Text("Stuff")
    }
}
