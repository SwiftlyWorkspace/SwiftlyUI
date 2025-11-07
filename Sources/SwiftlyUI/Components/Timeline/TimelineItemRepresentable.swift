import SwiftUI

/// A protocol that defines the required properties for timeline items.
///
/// Conform your custom types to this protocol to use them with the `Timeline` component.
/// The protocol provides default implementations for optional properties, making it easy
/// to adopt with minimal boilerplate.
///
/// ## Example
/// ```swift
/// struct ProjectMilestone: TimelineItemRepresentable {
///     let id: UUID
///     let timelineDate: Date
///     let timelineTitle: String?
///     let timelineDescription: String?
///     let timelineStatus: TimelineStatus?
///
///     var name: String
///     var isCompleted: Bool
/// }
/// ```
///
/// ## Automatic Conformance
/// If your type already has properties matching the protocol requirements,
/// you can provide simple computed property mappings:
/// ```swift
/// extension MyEvent: TimelineItemRepresentable {
///     var timelineDate: Date { eventDate }
///     var timelineTitle: String? { eventName }
///     var timelineDescription: String? { eventDetails }
///     var timelineStatus: TimelineStatus? {
///         isCompleted ? .completed : .inProgress
///     }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public protocol TimelineItemRepresentable: Identifiable {
    /// The date/timestamp for this timeline item.
    ///
    /// This property is used for sorting timeline items chronologically.
    var timelineDate: Date { get }

    /// An optional title for the timeline item.
    ///
    /// If provided, this will be displayed as the main heading for the item.
    var timelineTitle: String? { get }

    /// An optional description for the timeline item.
    ///
    /// This provides additional context or details about the timeline event.
    /// Long descriptions may be truncated with an expand/collapse option.
    var timelineDescription: String? { get }

    /// An optional status for the timeline item.
    ///
    /// The status determines the visual appearance of the timeline indicator,
    /// including its color and icon.
    var timelineStatus: TimelineStatus? { get }

    /// The IDs of parent timeline items, if any.
    ///
    /// This property enables automatic branch detection and visualization in timeline styles
    /// that support branching (like the GitHub style). When parent IDs are provided:
    /// - Items with one parent form a linear chain in the same branch
    /// - Items with a parent from a different branch trigger branch creation visualization
    /// - Items with multiple parents trigger merge visualization
    ///
    /// ## Example
    /// ```swift
    /// // Linear history
    /// let commit2 = TimelineItem(title: "Second commit", parentIds: [commit1.id])
    ///
    /// // Branch creation (parent in different branch triggers new branch)
    /// let featureBranch = TimelineItem(title: "Feature work", parentIds: [commit1.id])
    ///
    /// // Merge (multiple parents)
    /// let mergeCommit = TimelineItem(title: "Merge feature", parentIds: [commit2.id, featureBranch.id])
    /// ```
    ///
    /// If `nil` or empty, the item is treated as having no parent relationships.
    /// The timeline will automatically detect branch structure from parent-child relationships.
    var timelineParentIds: [AnyHashable]? { get }
}

// MARK: - Default Implementations

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineItemRepresentable {
    /// Default implementation returns nil for title.
    var timelineTitle: String? { nil }

    /// Default implementation returns nil for description.
    var timelineDescription: String? { nil }

    /// Default implementation returns nil for status.
    var timelineStatus: TimelineStatus? { nil }

    /// Default implementation returns nil for parent IDs.
    ///
    /// Items without parent IDs are treated as standalone items with no
    /// branch relationships, and will be displayed in a simple linear timeline.
    var timelineParentIds: [AnyHashable]? { nil }
}
