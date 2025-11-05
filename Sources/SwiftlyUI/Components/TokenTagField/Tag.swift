import SwiftUI

/// A model representing a tag with a name and color.
///
/// Tags are used in the `TokenTagField` component to represent discrete pieces of information
/// that can be added, edited, and removed by the user.
public struct Tag: Identifiable, Hashable, Sendable {
    /// The unique identifier for the tag.
    public let id: UUID

    /// The display name of the tag.
    public var name: String

    /// The color associated with the tag.
    public var color: Color

    /// Creates a new tag with the specified properties.
    /// - Parameters:
    ///   - id: The unique identifier. If not provided, a new UUID is generated.
    ///   - name: The display name of the tag.
    ///   - color: The color associated with the tag.
    public init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

// MARK: - Convenience Methods

public extension Tag {
    /// Generates a random color from the available predefined colors.
    /// - Returns: A random `Color` from the `availableColors` array.
    static func randomColor() -> Color {
        return availableColors.randomElement() ?? .blue
    }

    /// An array of predefined colors available for tags.
    static let availableColors: [Color] = [
        .blue, .green, .red, .purple, .orange,
        .pink, .yellow, .indigo, .teal, .cyan
    ]

    /// Creates a new tag with a random color.
    /// - Parameter name: The display name of the tag.
    /// - Returns: A new `Tag` with the specified name and a random color.
    static func withRandomColor(name: String) -> Tag {
        return Tag(name: name, color: randomColor())
    }

    /// Returns the human-readable name for a color.
    /// - Parameter color: The color to get the name for.
    /// - Returns: A string representation of the color name.
    static func colorName(for color: Color) -> String {
        switch color {
        case .blue: return "Blue"
        case .green: return "Green"
        case .red: return "Red"
        case .purple: return "Purple"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .yellow: return "Yellow"
        case .indigo: return "Indigo"
        case .teal: return "Teal"
        case .cyan: return "Cyan"
        default: return "Custom"
        }
    }
}