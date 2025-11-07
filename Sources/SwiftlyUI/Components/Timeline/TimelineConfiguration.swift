import SwiftUI

// MARK: - Indicator Shape

/// The shape of timeline indicators.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineIndicatorShape: Hashable, Sendable {
    /// A circular indicator.
    case circle

    /// A rounded square indicator with customizable corner radius.
    case roundedSquare(cornerRadius: CGFloat = 4)

    /// A square indicator.
    case square

    /// A diamond-shaped indicator.
    case diamond

    /// A custom shape provided as AnyShape.
    case custom
}

// MARK: - Connector Style

/// The visual style of connectors between timeline items.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineConnectorStyle: Hashable, Sendable {
    /// A solid line connector.
    case solid

    /// A dashed line connector.
    case dashed

    /// A dotted line connector.
    case dotted
}

// MARK: - Indicator Position

/// The position of timeline indicators relative to the content.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineIndicatorPosition: String, CaseIterable, Hashable, Sendable {
    /// Indicator positioned on the leading edge.
    case leading

    /// Indicator positioned on the trailing edge.
    case trailing

    /// Indicator positioned in the center.
    case center
}

// MARK: - Grouping Period

/// The time period used for grouping timeline items.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineGrouping: String, CaseIterable, Hashable, Sendable {
    /// No grouping - display all items sequentially.
    case none

    /// Group items by day.
    case day

    /// Group items by week.
    case week

    /// Group items by month.
    case month

    /// Group items by year.
    case year
}

// MARK: - Grouping Format

/// The format style for group headers.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineGroupingFormat: String, CaseIterable, Hashable, Sendable {
    /// Relative format (e.g., "Today", "Yesterday", "Last Week").
    case relative

    /// Absolute format (e.g., "January 15, 2024", "Week of Jan 15").
    case absolute

    /// Short format (e.g., "Jan 15", "W3 2024").
    case short
}

// MARK: - Section Style

/// The visual style for timeline sections.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum TimelineSectionStyle: String, CaseIterable, Hashable, Sendable {
    /// Section with a header text.
    case header

    /// Section with a horizontal separator.
    case separator

    /// Section with a card-style container.
    case card
}

// MARK: - Environment Keys for Customization

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorShapeKey: EnvironmentKey {
    static let defaultValue: TimelineIndicatorShape = .circle
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 16
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorIconKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineConnectorWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 2
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineConnectorColorKey: EnvironmentKey {
    static let defaultValue: Color = .gray.opacity(0.3)
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineConnectorStyleKey: EnvironmentKey {
    static let defaultValue: TimelineConnectorStyle = .solid
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorPositionKey: EnvironmentKey {
    static let defaultValue: TimelineIndicatorPosition = .leading
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 16
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineItemPaddingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 12
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineExpandableKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineDefaultExpandedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineGroupingKey: EnvironmentKey {
    static let defaultValue: TimelineGrouping = .none
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineGroupingFormatKey: EnvironmentKey {
    static let defaultValue: TimelineGroupingFormat = .relative
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineSectionStyleKey: EnvironmentKey {
    static let defaultValue: TimelineSectionStyle = .header
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineSectionCollapsibleKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

// MARK: - Environment Values Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var timelineIndicatorShape: TimelineIndicatorShape {
        get { self[TimelineIndicatorShapeKey.self] }
        set { self[TimelineIndicatorShapeKey.self] = newValue }
    }

    var timelineIndicatorSize: CGFloat {
        get { self[TimelineIndicatorSizeKey.self] }
        set { self[TimelineIndicatorSizeKey.self] = newValue }
    }

    var timelineIndicatorColor: Color? {
        get { self[TimelineIndicatorColorKey.self] }
        set { self[TimelineIndicatorColorKey.self] = newValue }
    }

    var timelineIndicatorIcon: String? {
        get { self[TimelineIndicatorIconKey.self] }
        set { self[TimelineIndicatorIconKey.self] = newValue }
    }

    var timelineConnectorWidth: CGFloat {
        get { self[TimelineConnectorWidthKey.self] }
        set { self[TimelineConnectorWidthKey.self] = newValue }
    }

    var timelineConnectorColor: Color {
        get { self[TimelineConnectorColorKey.self] }
        set { self[TimelineConnectorColorKey.self] = newValue }
    }

    var timelineConnectorStyle: TimelineConnectorStyle {
        get { self[TimelineConnectorStyleKey.self] }
        set { self[TimelineConnectorStyleKey.self] = newValue }
    }

    var timelineIndicatorPosition: TimelineIndicatorPosition {
        get { self[TimelineIndicatorPositionKey.self] }
        set { self[TimelineIndicatorPositionKey.self] = newValue }
    }

    var timelineSpacing: CGFloat {
        get { self[TimelineSpacingKey.self] }
        set { self[TimelineSpacingKey.self] = newValue }
    }

    var timelineItemPadding: CGFloat {
        get { self[TimelineItemPaddingKey.self] }
        set { self[TimelineItemPaddingKey.self] = newValue }
    }

    var timelineExpandable: Bool {
        get { self[TimelineExpandableKey.self] }
        set { self[TimelineExpandableKey.self] = newValue }
    }

    var timelineDefaultExpanded: Bool {
        get { self[TimelineDefaultExpandedKey.self] }
        set { self[TimelineDefaultExpandedKey.self] = newValue }
    }

    var timelineGrouping: TimelineGrouping {
        get { self[TimelineGroupingKey.self] }
        set { self[TimelineGroupingKey.self] = newValue }
    }

    var timelineGroupingFormat: TimelineGroupingFormat {
        get { self[TimelineGroupingFormatKey.self] }
        set { self[TimelineGroupingFormatKey.self] = newValue }
    }

    var timelineSectionStyle: TimelineSectionStyle {
        get { self[TimelineSectionStyleKey.self] }
        set { self[TimelineSectionStyleKey.self] = newValue }
    }

    var timelineSectionCollapsible: Bool {
        get { self[TimelineSectionCollapsibleKey.self] }
        set { self[TimelineSectionCollapsibleKey.self] = newValue }
    }
}
