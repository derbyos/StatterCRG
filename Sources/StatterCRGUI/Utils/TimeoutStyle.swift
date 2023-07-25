//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 7/24/23.
//

import SwiftUI
import StatterCRG

/// Something to draw timeouts
public protocol TimeoutStyle {
    associatedtype Result: View
    func body(for: Team) -> Result
}

protocol AbstractTimeoutStyle {
    func body(for: Team) -> AnyView
}
struct WrappedTimeoutStyle<T:TimeoutStyle>: AbstractTimeoutStyle {
    var style: T
    init(style: T) {
        self.style = style
    }
    public func body(for team: Team) -> AnyView {
        AnyView(style.body(for: team))
    }
}
struct TimeoutStyleEnvironmentKey: EnvironmentKey {
    typealias Value = AbstractTimeoutStyle
    
    static var defaultValue: AbstractTimeoutStyle = WrappedTimeoutStyle(style:DefaultTimeoutStyle())
}

extension EnvironmentValues {
    var timeoutStyle : any AbstractTimeoutStyle {
        get {
            self[TimeoutStyleEnvironmentKey.self]
        }
        set {
            self[TimeoutStyleEnvironmentKey.self] = newValue
        }
    }
}

public extension View {
    /// Apply a style to the timeouts display
    /// - Parameter style: The style to use
    /// - Returns: Modified view with this style
    func timeoutStyle<S: TimeoutStyle>(_ style:S) -> some View {
        self.environment(\.timeoutStyle, WrappedTimeoutStyle(style: style))
    }
}

public extension TimeoutStyle where Self == DefaultTimeoutStyle {
    
    static var `default`: DefaultTimeoutStyle {
        DefaultTimeoutStyle()
    }
}

public extension TimeoutStyle where Self == VerticalTimeoutStyle {
    static func vertical(separated: Bool) -> VerticalTimeoutStyle {
        VerticalTimeoutStyle(separated: separated)
    }
}

public struct DefaultTimeoutStyle : TimeoutStyle {
    @ViewBuilder public func body(for team: Team) -> some View {
        VerticalTimeoutStyle(separated: true)
            .body(for: team)
    }
}
public struct VerticalTimeoutStyle : TimeoutStyle {
    public init(separated: Bool = true) {
        self.separated = separated
    }
    
    struct TimeoutBox<C:View> : View {
        @EnvironmentObject var theme: Theme
        @Environment(\.timeoutDotStyle) var dotStyle
        var content: C
        init(@ViewBuilder content: ()->C) {
            self.content = content()
        }
        var body: some View {
            content
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: dotStyle.cornerRadius)
                )
        }
    }

    var separated: Bool
    
    struct TimeoutDotView : View {
        var dot: TimeoutDot
        @Environment(\.timeoutDotStyle) var dotStyle
        var body: some View {
            AnyView(dotStyle.body(for: dot))
        }
    }
    @ViewBuilder func timeoutView(for team: Team) -> some View {
        VStack {
            ForEach(0..<3) {
                if $0 < (team.timeouts ?? 0) {
                    TimeoutDotView(dot: TimeoutDot.unused)
                } else {
                    TimeoutDotView(dot: TimeoutDot.used)
                }
            }
            .foregroundColor(.backgroundFill)
        }
    }
    @ViewBuilder func officialReviewView(for team: Team) -> some View {
        if let officialReviews = team.officialReviews, officialReviews > 0 {
            if team.retainedOfficialReview == true {
                TimeoutDotView(dot: TimeoutDot.retained)
            } else {
                TimeoutDotView(dot: TimeoutDot.unused)
            }
        } else {
            TimeoutDotView(dot: TimeoutDot.used)
        }

    }

    @ViewBuilder public func body(for team: Team) -> some View {
        if separated {
            VStack {
                TimeoutBox {
                    timeoutView(for: team)
                }
                TimeoutBox {
                    officialReviewView(for: team)
                }
            }
        } else {
            TimeoutBox {
                VStack {
                    timeoutView(for: team)
//                    Divider().frame(width: 16)
//                        .foregroundColor(.black)
                    Rectangle().frame(width: 16, height: 1)
                        .foregroundColor(.primary)
                    officialReviewView(for: team)
                }
            }
        }
    }
}


public extension View {
    /// Apply a style to the dots in a timeouts display
    /// - Parameter style: The style to use
    /// - Returns: Modified view with this style
    func timeoutDotStyle<S: TimeoutDotStyle>(_ style:S) -> some View {
        self.environment(\.timeoutDotStyle, style)
    }
}


public protocol TimeoutDotStyle {
    associatedtype Result: View
    func body(for: TimeoutDot) -> Result
    var cornerRadius: CGFloat { get }
    var hideUsed: Bool { get }
}

struct TimeoutDotStyleEnvironmentKey: EnvironmentKey {
    typealias Value = TimeoutDotStyle
    
    static var defaultValue: any TimeoutDotStyle = DefaultTimeoutDotStyle()
}

extension EnvironmentValues {
    public var timeoutDotStyle : any TimeoutDotStyle {
        get {
            self[TimeoutDotStyleEnvironmentKey.self]
        }
        set {
            self[TimeoutDotStyleEnvironmentKey.self] = newValue
        }
    }
}

extension TimeoutDotStyle where Self == DefaultTimeoutDotStyle {
    public static var `default` : DefaultTimeoutDotStyle { .init() }
}
public struct DefaultTimeoutDotStyle : TimeoutDotStyle {
    @ViewBuilder public func body(for dot: TimeoutDot) -> some View {
        RoundTimeoutDotStyle(hideUsed: true)
            .body(for: dot)
    }
    public var hideUsed: Bool { true }
    public var cornerRadius: CGFloat {
        RoundTimeoutDotStyle(hideUsed: true).cornerRadius
    }

}

extension TimeoutDotStyle where Self == RoundTimeoutDotStyle {
    public static func round(hideUsed: Bool = true) -> RoundTimeoutDotStyle {
        .init(hideUsed: hideUsed)
    }
}

public struct RoundTimeoutDotStyle : TimeoutDotStyle {
    public init(hideUsed: Bool) {
        self.hideUsed = hideUsed
    }
    
    @ViewBuilder public func body(for dot: TimeoutDot) -> some View {
        switch dot {
        case .unused: Image(systemName: "circle.fill")
        case .used: Image(systemName: "circle").opacity(hideUsed ? 0.0 : 1.0)
        case .retained: Image(systemName: "plus.circle.fill")
        }
    }
    public var hideUsed: Bool
    public var cornerRadius: CGFloat {
        8
    }
    
    
}

extension TimeoutDotStyle where Self == SquareTimeoutDotStyle {
    public static func square(hideUsed: Bool = true) -> SquareTimeoutDotStyle {
        .init(hideUsed: hideUsed)
    }
}

public struct SquareTimeoutDotStyle : TimeoutDotStyle {
    public init(hideUsed: Bool) {
        self.hideUsed = hideUsed
    }
    public var cornerRadius: CGFloat {
        2
    }
    @ViewBuilder public func body(for dot: TimeoutDot) -> some View {
        switch dot {
        case .unused: Image(systemName: "square.fill")
        case .used: Image(systemName: "square").opacity(hideUsed ? 0.0 : 1.0)
        case .retained: Image(systemName: "square.circle.fill")
        }
    }
    public var hideUsed: Bool

}
