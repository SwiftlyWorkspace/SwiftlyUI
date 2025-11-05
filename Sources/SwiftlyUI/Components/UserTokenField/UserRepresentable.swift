import SwiftUI

/// A protocol that represents a user in the UserTokenField component.
///
/// Conform your existing user types to this protocol to use them with UserTokenField.
/// The protocol requires basic user information and provides computed properties
/// for display name, initials, and avatar color generation.
///
/// ## Example
/// ```swift
/// struct MyUser: UserRepresentable {
///     let id: UUID
///     let firstName: String
///     let lastName: String
///     let email: String
///     var avatarURL: URL?
///     var avatarImage: Image?
/// }
/// ```
///
/// ## Protocol Extensions
/// The protocol provides computed properties for:
/// - `displayName`: Full name combining firstName and lastName
/// - `initials`: First letter of firstName + first letter of lastName
/// - `avatarColor`: Consistent color based on user ID for avatar backgrounds
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public protocol UserRepresentable: Identifiable, Sendable {
    /// The user's first name (optional)
    var firstName: String? { get }

    /// The user's last name (optional)
    var lastName: String? { get }

    /// The user's email address
    var email: String { get }

    /// Optional URL to the user's avatar image
    var avatarURL: URL? { get }

    /// Optional SwiftUI Image for the user's avatar
    var avatarImage: Image? { get }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension UserRepresentable {
    /// The user's full name (firstName + lastName)
    ///
    /// Returns the combined first and last name with proper spacing.
    /// If both names are nil, returns the email address.
    /// Trailing and leading whitespace is trimmed.
    var displayName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? email : fullName
    }

    /// The user's initials (first letter of firstName + first letter of lastName)
    ///
    /// Returns a two-character string with the uppercased first letters of the
    /// first and last names. Falls back to email initials if names are not provided.
    ///
    /// ## Examples
    /// - "John Doe" → "JD"
    /// - "Jane Smith" → "JS"
    /// - nil, nil (email: "john@example.com") → "JO" (from email)
    /// - "" → "?"
    var initials: String {
        let first = firstName?.first?.uppercased() ?? ""
        let last = lastName?.first?.uppercased() ?? ""
        let combined = first + last

        if !combined.isEmpty {
            return combined
        }

        // Fallback to email initials
        let emailParts = email.components(separatedBy: "@")
        if let username = emailParts.first, !username.isEmpty {
            let firstTwo = String(username.prefix(2)).uppercased()
            return firstTwo.count >= 2 ? firstTwo : firstTwo + "?"
        }

        return "?"
    }

    /// Generates a consistent color for the user based on their ID
    ///
    /// Uses a deterministic hash-based approach to select from a predefined
    /// color palette. The same user ID will always produce the same color,
    /// providing visual consistency across the application.
    ///
    /// Used for avatar background when no image is provided.
    var avatarColor: Color {
        let colors: [Color] = [
            .blue, .green, .red, .purple, .orange,
            .pink, .yellow, .indigo, .teal, .cyan
        ]
        let hash = abs(id.hashValue)
        return colors[hash % colors.count]
    }
}
