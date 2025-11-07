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

    // MARK: - Initializers

    /// Creates a new timeline item with the specified properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier. If not provided, a new UUID is generated.
    ///   - date: The date/timestamp for this timeline item.
    ///   - title: An optional title for display.
    ///   - description: An optional description providing additional context.
    ///   - status: An optional status indicating the item's state.
    public init(
        id: UUID = UUID(),
        date: Date,
        title: String? = nil,
        description: String? = nil,
        status: TimelineStatus? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.status = status
    }
}

// MARK: - TimelineItemRepresentable Conformance

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineItem: TimelineItemRepresentable {
    public var timelineDate: Date { date }
    public var timelineTitle: String? { title }
    public var timelineDescription: String? { description }
    public var timelineStatus: TimelineStatus? { status }
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
}
