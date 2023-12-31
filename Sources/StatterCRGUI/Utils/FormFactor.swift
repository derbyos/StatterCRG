//
//  File.swift
//  
//
//  Created by gandreas on 7/25/23.
//

import Foundation
import SwiftUI

/// An enum defining what the target form factor size is
public enum FormFactorSize {
    /// for watch size, minimal space
    case small
    /// for compact devices
    case medium
    /// for full sized devices/windows
    case large
    /// for full screen presentation
    case jumbo
}

/// The different categories of font sizes
public enum FormFactorFontSize {
    /// Largest for things like visible score
    case score
    /// For major titles
    case title
    /// for sub titles
    case subtitle
    /// for general text
    case body
    /// for captions on areas
    case caption
}

public protocol FormFactor {
    /// What size is this form factor
    var size: FormFactorSize { get }
    
    /// How large should "normal lines" appear
    var lineWidth: CGFloat { get }
    
    /// A generic font scaling
    var fontScale: CGFloat { get }

    /// Various fonts
    var score: Font { get }
    var title: Font { get }
    var subtitle: Font { get }
    var body: Font { get }
    var caption: Font { get }
    
    var baseFontName: String? { get set }
}

// default values
public extension FormFactor {
    subscript(fontSize: FormFactorFontSize) -> Font {
        switch fontSize {
        case .score: return score
        case .body: return body
        case .caption: return caption
        case .subtitle: return subtitle
        case .title: return title
        }
    }
    var lineWidth: CGFloat { 1.0 }
    var fontScale: CGFloat { 1.0 }
    
    func customFont(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        if let baseFontName {
            return Font.custom(baseFontName, size: size * fontScale, relativeTo: style)
        } else if fontScale == 1 {
            return Font.system(style)
        } else {
            return Font.system(size: size * fontScale)
        }
    }
    var score: Font { customFont(size: 34, relativeTo: .largeTitle) }
    var title: Font { customFont(size: 28, relativeTo: .largeTitle) }
    var subtitle: Font { customFont(size: 20, relativeTo: .title3) }
    var body: Font { customFont(size: 17, relativeTo: .body) }
    var caption: Font { customFont(size: 12, relativeTo: .caption) }
    
    func with(fontName: String) -> Self {
        var retval = self
        retval.baseFontName = fontName
        return retval
    }
}

public struct WatchFormFactor : FormFactor {
    public init(baseFontName: String? = nil) {
        self.baseFontName = baseFontName
    }
    
    public var size: FormFactorSize { .small }
    public var baseFontName: String?
}

public struct CompactFormFactor : FormFactor {
    public init(baseFontName: String? = nil) {
        self.baseFontName = baseFontName
    }
    public var size: FormFactorSize { .medium }
    public var baseFontName: String?
}

public struct RegularFormFactor : FormFactor {
    public init(baseFontName: String? = nil) {
        self.baseFontName = baseFontName
    }
    public var size: FormFactorSize { .medium }
    public var baseFontName: String?
}

public struct WindowFormFactor : FormFactor {
    public init(baseFontName: String? = nil) {
        self.baseFontName = baseFontName
    }
    public var size: FormFactorSize { .large }
    public var baseFontName: String?
}

public struct DisplayFormFactor : FormFactor {
    public init(baseFontName: String? = nil) {
        self.baseFontName = baseFontName
    }
    public var size: FormFactorSize { .jumbo }
    public var baseFontName: String?
    
    public var fontScale: CGFloat { 4.0 }
}


struct FormFactorEnvironmentKey: EnvironmentKey {
    typealias Value = FormFactor
    
    // pick a default value based on the OS/user idiom
    #if os(watchOS)
    static var defaultValue: FormFactor = WatchFormFactor()
    #elseif os(tvOS)
    static var defaultValue: FormFactor = DisplayFormFactor()
    #elseif os(iOS)
    static var defaultValue: FormFactor = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return CompactFormFactor()
        case .pad:
            return RegularFormFactor()
        case .mac:
            return WindowFormFactor()
        case .tv:
            return DisplayFormFactor()
        case .carPlay:
            return WatchFormFactor()
        default:
            return RegularFormFactor()
        }
    }()
    #else
    static var defaultValue: FormFactor = WindowFormFactor()
    #endif
}

extension EnvironmentValues {
    public var formFactor : FormFactor {
        get {
            self[FormFactorEnvironmentKey.self]
        }
        set {
            self[FormFactorEnvironmentKey.self] = newValue
        }
    }
}


struct FontForFormFactor: ViewModifier {
    var size: FormFactorFontSize
    var forTime: Bool
    @Environment(\.formFactor) var formFactor
    func body(content: Content) -> some View {
        if forTime {
            content.font(formFactor[size].monospacedDigit())
        } else {
            content.font(formFactor[size])
        }
    }
}

struct MonospacedTime: ViewModifier {
    @Environment(\.font) var font
    func body(content: Content) -> some View {
        content.font(font?.monospacedDigit())
    }
}

struct FormFactorFontName: ViewModifier {
    @Environment(\.formFactor) var formFactor
    var name: String
    func body(content: Content) -> some View {
        content.formFactor(formFactor.with(fontName: name))
    }
}
public extension View {
    /// Specify the formfactor for presentation
    /// - Parameter style: The style to use
    /// - Returns: Modified view with this style
    func formFactor(_ style:FormFactor) -> some View {
        self.environment(\.formFactor, style)
    }
    
    /// Specify a font based on the current form factor and size.
    /// - Parameter size: The font size
    /// - Returns: A modified view that will have the font specified
    ///
    /// While it would be nice to have this as an extension to `Font` we
    /// can't do that because the current form factor is in the enviroment and
    /// there are no hooks to provide that value in font creation
    func formFactorFont(_ size: FormFactorFontSize, forTime: Bool = false) -> some View {
        self.modifier(FontForFormFactor(size: size, forTime: forTime))
    }
    
    /// Specify a custom font for the given form factor.
    /// - Parameter name: The font name
    /// - Returns: A modified view that will have the font specified
    func formFactorFontName(_ name: String) -> some View {
        self.modifier(FormFactorFontName(name: name))
    }

    /// Indicates that this view shows time in a monospaced form (if possible)
    func showingMonospacedTime() -> some View {
        self.modifier(MonospacedTime())
    }
}
