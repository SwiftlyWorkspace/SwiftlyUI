import SwiftUI

// MARK: - Timeline Style Protocol

/// A type that specifies the appearance and behavior of a timeline.
///
/// Create custom timeline styles by conforming to this protocol and
/// implementing the `makeBody(configuration:)` method. The configuration
/// provides access to the timeline's content and state.
///
/// ## Example
/// ```swift
/// struct MyCustomTimelineStyle: TimelineStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         VStack(spacing: 20) {
///             configuration.content
///         }
///     }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public protocol TimelineStyle {
    /// The type of view representing the body of the timeline.
    associatedtype Body: View

    /// The properties of a timeline.
    typealias Configuration = TimelineStyleConfiguration

    /// Creates a view that represents the body of a timeline.
    ///
    /// - Parameter configuration: The properties of the timeline, including
    ///   its content and configuration options.
    /// - Returns: A view that represents the styled timeline.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}

// MARK: - Timeline Style Configuration

/// The configuration for a timeline style.
///
/// This configuration provides the necessary data for rendering a timeline,
/// including the items to display and any customization options.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TimelineStyleConfiguration {
    /// The items to display in the timeline.
    public let items: [AnyTimelineItemWrapper]

    /// The content view for the timeline.
    public let content: AnyView

    /// Whether the timeline supports selection.
    public let allowsSelection: Bool

    /// The current selection set.
    public let selection: Set<AnyHashable>

    /// Custom tap action for timeline items.
    public let onItemTap: ((AnyTimelineItemWrapper) -> Void)?
}

// MARK: - Type-Erased Timeline Item Wrapper

/// A type-erased wrapper for timeline items.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AnyTimelineItemWrapper: Identifiable, Hashable {
    public let id: AnyHashable
    public let date: Date
    public let title: String?
    public let description: String?
    public let status: TimelineStatus?

    public init<Item: TimelineItemRepresentable>(_ item: Item) {
        self.id = AnyHashable(item.id)
        self.date = item.timelineDate
        self.title = item.timelineTitle
        self.description = item.timelineDescription
        self.status = item.timelineStatus
    }

    public static func == (lhs: AnyTimelineItemWrapper, rhs: AnyTimelineItemWrapper) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Type-Erased Timeline Style

/// A type-erased timeline style.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AnyTimelineStyle: TimelineStyle {
    private let _makeBody: (Configuration) -> AnyView

    public init<S: TimelineStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Environment Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TimelineStyleKey: EnvironmentKey {
    #if os(macOS)
    static let defaultValue: AnyTimelineStyle = AnyTimelineStyle(VerticalTimelineStyle())
    #else
    static let defaultValue: AnyTimelineStyle = AnyTimelineStyle(VerticalTimelineStyle())
    #endif
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var timelineStyle: AnyTimelineStyle {
        get { self[TimelineStyleKey.self] }
        set { self[TimelineStyleKey.self] = newValue }
    }
}

// MARK: - View Modifier

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Sets the style for timelines within this view.
    ///
    /// ## Example
    /// ```swift
    /// Timeline(items: events)
    ///     .timelineStyle(.vertical)
    /// ```
    ///
    /// - Parameter style: The timeline style to apply.
    /// - Returns: A view with the specified timeline style applied.
    public func timelineStyle<S: TimelineStyle>(_ style: S) -> some View {
        environment(\.timelineStyle, AnyTimelineStyle(style))
    }
}

// MARK: - Vertical Timeline Style

/// A timeline style that displays items in a vertical layout.
///
/// This is the default timeline style, displaying items chronologically
/// from top to bottom with indicators on the left (or right) side.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct VerticalTimelineStyle: TimelineStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(configuration.items) { item in
                    TimelineItemRow(
                        item: item,
                        isLast: item.id == configuration.items.last?.id,
                        allowsSelection: configuration.allowsSelection,
                        isSelected: configuration.selection.contains(item.id),
                        onTap: configuration.onItemTap
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Horizontal Timeline Style

/// A timeline style that displays items in a horizontal layout.
///
/// Useful for step-by-step processes or progress indicators.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct HorizontalTimelineStyle: TimelineStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(configuration.items) { item in
                    HorizontalTimelineItemRow(
                        item: item,
                        isLast: item.id == configuration.items.last?.id,
                        allowsSelection: configuration.allowsSelection,
                        isSelected: configuration.selection.contains(item.id),
                        onTap: configuration.onItemTap
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Compact Timeline Style

/// A compact timeline style with minimal spacing and smaller indicators.
///
/// Ideal for displaying many items in a constrained space.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct CompactTimelineStyle: TimelineStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(configuration.items) { item in
                    CompactTimelineItemRow(
                        item: item,
                        isLast: item.id == configuration.items.last?.id,
                        allowsSelection: configuration.allowsSelection,
                        isSelected: configuration.selection.contains(item.id),
                        onTap: configuration.onItemTap
                    )
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
    }
}

// MARK: - GitHub Timeline Style

/// A timeline style inspired by GitHub's activity feed.
///
/// Features a clean, card-based design with compact indicators.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct GitHubTimelineStyle: TimelineStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(configuration.items) { item in
                    GitHubTimelineItemRow(
                        item: item,
                        isLast: item.id == configuration.items.last?.id,
                        allowsSelection: configuration.allowsSelection,
                        isSelected: configuration.selection.contains(item.id),
                        onTap: configuration.onItemTap
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Style Convenience Properties

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineStyle where Self == VerticalTimelineStyle {
    /// A vertical timeline style.
    public static var vertical: VerticalTimelineStyle { VerticalTimelineStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineStyle where Self == HorizontalTimelineStyle {
    /// A horizontal timeline style.
    public static var horizontal: HorizontalTimelineStyle { HorizontalTimelineStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineStyle where Self == CompactTimelineStyle {
    /// A compact timeline style.
    public static var compact: CompactTimelineStyle { CompactTimelineStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension TimelineStyle where Self == GitHubTimelineStyle {
    /// A GitHub-inspired timeline style.
    public static var github: GitHubTimelineStyle { GitHubTimelineStyle() }
}

// MARK: - Temporary Placeholder Row Views

// These will be replaced with proper implementations in later commits

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TimelineItemRow: View {
    let item: AnyTimelineItemWrapper
    let isLast: Bool
    let allowsSelection: Bool
    let isSelected: Bool
    let onTap: ((AnyTimelineItemWrapper) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Placeholder indicator
            Circle()
                .fill(item.status?.color ?? .gray)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                if let title = item.title {
                    Text(title)
                        .font(.headline)
                }
                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(item.date, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?(item)
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct HorizontalTimelineItemRow: View {
    let item: AnyTimelineItemWrapper
    let isLast: Bool
    let allowsSelection: Bool
    let isSelected: Bool
    let onTap: ((AnyTimelineItemWrapper) -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(item.status?.color ?? .gray)
                .frame(width: 12, height: 12)

            if let title = item.title {
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 80)
        .padding(.horizontal, 8)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct CompactTimelineItemRow: View {
    let item: AnyTimelineItemWrapper
    let isLast: Bool
    let allowsSelection: Bool
    let isSelected: Bool
    let onTap: ((AnyTimelineItemWrapper) -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(item.status?.color ?? .gray)
                .frame(width: 8, height: 8)

            if let title = item.title {
                Text(title)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct GitHubTimelineItemRow: View {
    let item: AnyTimelineItemWrapper
    let isLast: Bool
    let allowsSelection: Bool
    let isSelected: Bool
    let onTap: ((AnyTimelineItemWrapper) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(item.status?.color ?? .gray)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                if let title = item.title {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(item.date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
