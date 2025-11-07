import SwiftUI

/// A wrapper model representing a timeline item with metadata.
///
/// `TimelineItem` provides a convenient way to create timeline items directly
/// without defining a custom type that conforms to `TimelineItemRepresentable`.
/// It's useful for simple timelines or prototyping.
///
/// ## Example
/// ```swift
/// let item = TimelineItem(
///     date: Date(),
///     title: "Task Completed",
///     description: "Successfully finished the project milestone",
///     status: .completed
/// )
/// ```
///
/// ## Usage with Timeline
/// ```swift
/// let events = [
///     TimelineItem(date: date1, title: "Started", status: .completed),
///     TimelineItem(date: date2, title: "In Progress", status: .inProgress),
///     TimelineItem(date: date3, title: "Pending", status: .pending)
/// ]
///
/// Timeline(items: events)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TimelineItem: Identifiable, Hashable, Sendable {
    // MARK: - Properties

    /// The unique identifier for the timeline item.
    public let id: UUID

    /// The date/timestamp for this timeline item.
    public var date: Date

    /// An optional title for the timeline item.
    public var title: String?

    /// An optional description for the timeline item.
    public var description: String?

    /// An optional status for the timeline item.
    public var status: TimelineStatus?

    /// The IDs of parent timeline items, enabling branch visualization.
    ///
    /// When parent IDs are provided, timeline styles that support branching
    /// (like the GitHub style) will automatically detect and visualize branch
    /// relationships, merges, and splits.
    public var parentIds: [UUID]?

    // MARK: - Initializers

    /// Creates a new timeline item with the specified properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier. If not provided, a new UUID is generated.
    ///   - date: The date/timestamp for this timeline item.
    ///   - title: An optional title for display.
    ///   - description: An optional description providing additional context.
    ///   - status: An optional status indicating the item's state.
    ///   - parentIds: Optional array of parent item IDs for branch visualization.
    public init(
        id: UUID = UUID(),
        date: Date,
        title: String? = nil,
        description: String? = nil,
        status: TimelineStatus? = nil,
        parentIds: [UUID]? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.status = status
        self.parentIds = parentIds
    }
}

// MARK: - TimelineItemRepresentable Conformance

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineItem: TimelineItemRepresentable {
    public var timelineDate: Date { date }
    public var timelineTitle: String? { title }
    public var timelineDescription: String? { description }
    public var timelineStatus: TimelineStatus? { status }
    public var timelineParentIds: [AnyHashable]? {
        parentIds?.map { AnyHashable($0) }
    }
}

// MARK: - Convenience Factory Methods

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension TimelineItem {
    /// Creates a timeline item with a completed status.
    ///
    /// - Parameters:
    ///   - date: The date/timestamp for this item.
    ///   - title: The title for display.
    ///   - description: An optional description.
    /// - Returns: A new timeline item with `.completed` status.
    static func completed(
        date: Date,
        title: String,
        description: String? = nil
    ) -> TimelineItem {
        TimelineItem(date: date, title: title, description: description, status: .completed)
    }

    /// Creates a timeline item with an in-progress status.
    ///
    /// - Parameters:
    ///   - date: The date/timestamp for this item.
    ///   - title: The title for display.
    ///   - description: An optional description.
    /// - Returns: A new timeline item with `.inProgress` status.
    static func inProgress(
        date: Date,
        title: String,
        description: String? = nil
    ) -> TimelineItem {
        TimelineItem(date: date, title: title, description: description, status: .inProgress)
    }

    /// Creates a timeline item with a pending status.
    ///
    /// - Parameters:
    ///   - date: The date/timestamp for this item.
    ///   - title: The title for display.
    ///   - description: An optional description.
    /// - Returns: A new timeline item with `.pending` status.
    static func pending(
        date: Date,
        title: String,
        description: String? = nil
    ) -> TimelineItem {
        TimelineItem(date: date, title: title, description: description, status: .pending)
    }

    /// Returns a copy of this item with a single parent ID set.
    ///
    /// This creates a linear chain from the parent item to this item.
    ///
    /// - Parameter parentId: The ID of the parent timeline item.
    /// - Returns: A new timeline item with the specified parent.
    ///
    /// ## Example
    /// ```swift
    /// let commit1 = TimelineItem(date: date1, title: "Initial commit")
    /// let commit2 = TimelineItem(date: date2, title: "Second commit")
    ///     .withParent(commit1.id)
    /// ```
    func withParent(_ parentId: UUID) -> TimelineItem {
        TimelineItem(
            id: id,
            date: date,
            title: title,
            description: description,
            status: status,
            parentIds: [parentId]
        )
    }

    /// Returns a copy of this item with multiple parent IDs set.
    ///
    /// This creates a merge point where multiple branches converge into this item.
    ///
    /// - Parameter parentIds: The IDs of the parent timeline items.
    /// - Returns: A new timeline item with the specified parents.
    ///
    /// ## Example
    /// ```swift
    /// let mainCommit = TimelineItem(date: date1, title: "Main work")
    /// let featureCommit = TimelineItem(date: date2, title: "Feature work")
    /// let mergeCommit = TimelineItem(date: date3, title: "Merge feature")
    ///     .withParents([mainCommit.id, featureCommit.id])
    /// ```
    func withParents(_ parentIds: [UUID]) -> TimelineItem {
        TimelineItem(
            id: id,
            date: date,
            title: title,
            description: description,
            status: status,
            parentIds: parentIds
        )
    }
}
