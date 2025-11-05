import SwiftUI

/// A concrete user implementation for SwiftlyUI components.
///
/// Use this struct when you don't have your own user model, or as a reference
/// for conforming your existing models to `UserRepresentable`. This type provides
/// a simple, ready-to-use user representation with support for avatar images and URLs.
///
/// ## Example
/// ```swift
/// // With full name
/// let user1 = SwiftlyUIUser(
///     firstName: "John",
///     lastName: "Doe",
///     email: "john@example.com",
///     avatarImage: Image(systemName: "person.circle.fill")
/// )
///
/// // With email only (names are optional)
/// let user2 = SwiftlyUIUser(
///     email: "jane@example.com"
/// )
/// ```
///
/// ## Features
/// - Conforms to `UserRepresentable`, `Hashable`, and `Equatable`
/// - Supports both image and URL-based avatars
/// - Automatic UUID generation for unique identification
/// - Thread-safe with `Sendable` conformance
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SwiftlyUIUser: UserRepresentable {
    // MARK: - Properties

    /// Unique identifier for the user
    public let id: UUID

    /// The user's first name (optional)
    public var firstName: String?

    /// The user's last name (optional)
    public var lastName: String?

    /// The user's email address
    public var email: String

    /// Optional URL to the user's avatar image
    public var avatarURL: URL?

    /// Optional SwiftUI Image for the user's avatar
    public var avatarImage: Image?

    // MARK: - Initializers

    /// Creates a new SwiftlyUI user.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (defaults to a new UUID)
    ///   - firstName: The user's first name (optional)
    ///   - lastName: The user's last name (optional)
    ///   - email: The user's email address
    ///   - avatarURL: Optional URL to the user's avatar image
    ///   - avatarImage: Optional SwiftUI Image for the user's avatar
    public init(
        id: UUID = UUID(),
        firstName: String? = nil,
        lastName: String? = nil,
        email: String,
        avatarURL: URL? = nil,
        avatarImage: Image? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarURL = avatarURL
        self.avatarImage = avatarImage
    }
}

// MARK: - Hashable & Equatable

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension SwiftlyUIUser: Hashable, Equatable {
    /// Compares two users for equality based on their unique identifiers.
    public static func == (lhs: SwiftlyUIUser, rhs: SwiftlyUIUser) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the user's unique identifier for use in collections.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
