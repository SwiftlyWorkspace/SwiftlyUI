import SwiftUI

/// A status type representing the state of a timeline item.
///
/// `TimelineStatus` provides predefined states with associated colors and icons
/// that follow SwiftUI's semantic color system. Each status has a default visual
/// appearance, but can be customized using timeline modifiers.
///
/// ## Example
/// ```swift
/// Timeline(items: tasks) { task in
///     Text(task.name)
/// }
/// ```
///
/// ## Custom Status Colors
/// You can override the default status colors using view modifiers:
/// ```swift
/// Timeline(items: tasks)
///     .timelineIndicatorColor(.blue) // Override all indicators
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineStatus: String, CaseIterable, Identifiable, Hashable, Sendable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case blocked = "Blocked"
    case review = "Under Review"

    // MARK: - Identifiable

    public var id: String { rawValue }

    // MARK: - Default Colors

    /// The default color for this status.
    ///
    /// These colors follow SwiftUI's semantic color system and adapt to
    /// light and dark mode automatically.
    public var color: Color {
        switch self {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        case .blocked:
            return .orange
        case .review:
            return .purple
        }
    }

    // MARK: - Default Icons

    /// The default SF Symbol name for this status.
    ///
    /// These icons provide visual context for the timeline item's state.
    public var defaultIcon: String {
        switch self {
        case .pending:
            return "clock"
        case .inProgress:
            return "arrow.clockwise"
        case .completed:
            return "checkmark"
        case .cancelled:
            return "xmark"
        case .blocked:
            return "exclamationmark.triangle"
        case .review:
            return "eye"
        }
    }

    // MARK: - Display Name

    /// A human-readable display name for the status.
    public var displayName: String {
        rawValue
    }
}

// MARK: - Convenience Methods

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineStatus {
    /// Returns whether this status represents a completed state.
    var isCompleted: Bool {
        self == .completed
    }

    /// Returns whether this status represents an active/ongoing state.
    var isActive: Bool {
        self == .inProgress || self == .review
    }

    /// Returns whether this status represents a blocked/problem state.
    var isBlocked: Bool {
        self == .blocked || self == .cancelled
    }
}
