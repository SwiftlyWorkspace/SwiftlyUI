import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Cross-platform color extensions for SwiftlyUI components.
public extension Color {
    /// Background color for controls, adapting to the current platform.
    static var controlBackground: Color {
        #if canImport(UIKit)
        return Color(.systemBackground)
        #elseif canImport(AppKit)
        return Color(.controlBackgroundColor)
        #else
        return Color(.background)
        #endif
    }

    /// Background color for text fields and similar inputs.
    static var textBackground: Color {
        #if canImport(UIKit)
        return Color(.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(.textBackgroundColor)
        #else
        return Color(.background)
        #endif
    }

    /// Separator color for borders and dividers.
    static var separator: Color {
        #if canImport(UIKit)
        return Color(.separator)
        #elseif canImport(AppKit)
        return Color(.separatorColor)
        #else
        return Color(.secondary).opacity(0.3)
        #endif
    }

    /// Creates a color that adapts to light and dark modes.
    /// - Parameters:
    ///   - light: The color to use in light mode.
    ///   - dark: The color to use in dark mode.
    /// - Returns: An adaptive color that changes based on the current color scheme.
    static func adaptive(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #elseif canImport(AppKit)
        return Color(NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        })
        #else
        return light
        #endif
    }
}