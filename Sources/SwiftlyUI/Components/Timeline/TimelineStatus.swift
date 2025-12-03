import SwiftUI

/// A status type representing the state of a timeline item.
///
/// `TimelineStatus` provides predefined states with associated colors and icons
/// that follow SwiftUI's semantic color system. You can create custom statuses
/// to represent application-specific states.
///
/// ## Using Built-in Statuses
/// ```swift
/// let item = TimelineItem(date: Date(), title: "Task", status: .completed)
/// ```
///
/// ## Creating Custom Statuses
/// ```swift
/// extension TimelineStatus {
///     static let archived = TimelineStatus(
///         id: "archived",
///         displayName: "Archived",
///         color: .gray,
///         icon: "archivebox"
///     )
///
///     static let escalated = TimelineStatus(
///         id: "escalated",
///         displayName: "Escalated",
///         color: .red,
///         icon: "exclamationmark.3"
///     )
/// }
/// ```
///
/// ## Custom Status Categories
/// ```swift
/// extension TimelineStatus {
///     var isArchived: Bool {
///         self == .archived
///     }
///
///     var requiresAttention: Bool {
///         self == .escalated || self == .blocked
///     }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TimelineStatus: Identifiable, Hashable, Sendable {
    // MARK: - Properties

    /// The unique identifier for this status.
    public let id: String

    /// A human-readable display name for the status.
    public let displayName: String

    /// The color associated with this status.
    ///
    /// Used by timeline indicators when no custom color is specified.
    /// Follows SwiftUI's semantic color system and adapts to light/dark mode.
    public let color: Color

    /// The SF Symbol name for this status.
    ///
    /// Used by timeline indicators when no custom icon is specified.
    public let icon: String

    // MARK: - Initializer

    /// Creates a new timeline status with the specified properties.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this status. Used for equality comparison.
    ///   - displayName: A human-readable name displayed in the UI.
    ///   - color: The color associated with this status.
    ///   - icon: An SF Symbol name for the status icon.
    ///
    /// ## Example
    /// ```swift
    /// let customStatus = TimelineStatus(
    ///     id: "in_review",
    ///     displayName: "In Review",
    ///     color: .purple,
    ///     icon: "eye"
    /// )
    /// ```
    public init(
        id: String,
        displayName: String,
        color: Color,
        icon: String
    ) {
        self.id = id
        self.displayName = displayName
        self.color = color
        self.icon = icon
    }
}

// MARK: - Built-in Statuses

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineStatus {
    /// A status indicating a pending or waiting state.
    static let pending = TimelineStatus(
        id: "pending",
        displayName: "Pending",
        color: .gray,
        icon: "clock"
    )

    /// A status indicating active work in progress.
    static let inProgress = TimelineStatus(
        id: "in_progress",
        displayName: "In Progress",
        color: .blue,
        icon: "arrow.clockwise"
    )

    /// A status indicating successful completion.
    static let completed = TimelineStatus(
        id: "completed",
        displayName: "Completed",
        color: .green,
        icon: "checkmark"
    )

    /// A status indicating cancellation.
    static let cancelled = TimelineStatus(
        id: "cancelled",
        displayName: "Cancelled",
        color: .red,
        icon: "xmark"
    )

    /// A status indicating a blocked or impeded state.
    static let blocked = TimelineStatus(
        id: "blocked",
        displayName: "Blocked",
        color: .orange,
        icon: "exclamationmark.triangle"
    )

    /// A status indicating an item under review.
    static let review = TimelineStatus(
        id: "review",
        displayName: "Under Review",
        color: .purple,
        icon: "eye"
    )

    /// An array of all built-in timeline statuses.
    ///
    /// Use this for iterating over the predefined statuses. Custom statuses
    /// defined in extensions are not included in this array.
    ///
    /// ## Example
    /// ```swift
    /// TimelineStatus.builtInStatuses.forEach { status in
    ///     print(status.displayName)
    /// }
    /// ```
    static let builtInStatuses: [TimelineStatus] = [
        .pending,
        .inProgress,
        .completed,
        .cancelled,
        .blocked,
        .review
    ]
}

// MARK: - Convenience Properties

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineStatus {
    /// Returns whether this status represents a completed state.
    ///
    /// By default, only the built-in `.completed` status returns true.
    /// Extend this property to include custom completion statuses:
    ///
    /// ```swift
    /// extension TimelineStatus {
    ///     var isCompleted: Bool {
    ///         self == .completed || self == .archived
    ///     }
    /// }
    /// ```
    var isCompleted: Bool {
        self == .completed
    }

    /// Returns whether this status represents an active/ongoing state.
    ///
    /// By default, `.inProgress` and `.review` return true.
    /// Extend this property to include custom active statuses:
    ///
    /// ```swift
    /// extension TimelineStatus {
    ///     var isActive: Bool {
    ///         self == .inProgress || self == .review || self == .inTesting
    ///     }
    /// }
    /// ```
    var isActive: Bool {
        self == .inProgress || self == .review
    }

    /// Returns whether this status represents a blocked/problem state.
    ///
    /// By default, `.blocked` and `.cancelled` return true.
    /// Extend this property to include custom blocked statuses:
    ///
    /// ```swift
    /// extension TimelineStatus {
    ///     var isBlocked: Bool {
    ///         self == .blocked || self == .cancelled || self == .onHold
    ///     }
    /// }
    /// ```
    var isBlocked: Bool {
        self == .blocked || self == .cancelled
    }
}

// MARK: - Deprecated Properties

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineStatus {
    /// The default icon for this status.
    ///
    /// - Note: This property is deprecated. Use the `icon` property directly.
    @available(*, deprecated, renamed: "icon", message: "Use the 'icon' property directly")
    var defaultIcon: String {
        icon
    }
}
