import SwiftUI

// MARK: - Timeline View Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    // MARK: - Indicator Customization

    /// Sets the shape of timeline indicators.
    public func timelineIndicatorShape(_ shape: TimelineIndicatorShape) -> some View {
        environment(\.timelineIndicatorShape, shape)
    }

    /// Sets the size of timeline indicators.
    public func timelineIndicatorSize(_ size: CGFloat) -> some View {
        environment(\.timelineIndicatorSize, size)
    }

    /// Sets a custom color for all timeline indicators, overriding status colors.
    public func timelineIndicatorColor(_ color: Color?) -> some View {
        environment(\.timelineIndicatorColor, color)
    }

    /// Sets a custom SF Symbol icon for timeline indicators.
    public func timelineIndicatorIcon(_ iconName: String?) -> some View {
        environment(\.timelineIndicatorIcon, iconName)
    }

    /// Sets the position of timeline indicators relative to content.
    public func timelineIndicatorPosition(_ position: TimelineIndicatorPosition) -> some View {
        environment(\.timelineIndicatorPosition, position)
    }

    // MARK: - Connector Customization

    /// Sets the width of timeline connectors.
    public func timelineConnectorWidth(_ width: CGFloat) -> some View {
        environment(\.timelineConnectorWidth, width)
    }

    /// Sets the color of timeline connectors.
    public func timelineConnectorColor(_ color: Color) -> some View {
        environment(\.timelineConnectorColor, color)
    }

    /// Sets the style of timeline connectors.
    public func timelineConnectorStyle(_ style: TimelineConnectorStyle) -> some View {
        environment(\.timelineConnectorStyle, style)
    }

    // MARK: - Layout Customization

    /// Sets the spacing between timeline items.
    public func timelineSpacing(_ spacing: CGFloat) -> some View {
        environment(\.timelineSpacing, spacing)
    }

    /// Sets the padding within timeline items.
    public func timelineItemPadding(_ padding: CGFloat) -> some View {
        environment(\.timelineItemPadding, padding)
    }

    // MARK: - Content Customization

    /// Sets whether timeline items can expand/collapse.
    public func timelineExpandable(_ expandable: Bool) -> some View {
        environment(\.timelineExpandable, expandable)
    }

    /// Sets whether timeline items are expanded by default.
    public func timelineDefaultExpanded(_ expanded: Bool) -> some View {
        environment(\.timelineDefaultExpanded, expanded)
    }

    // MARK: - Grouping Customization

    /// Sets how timeline items are grouped by date.
    public func timelineGrouping(_ grouping: TimelineGrouping) -> some View {
        environment(\.timelineGrouping, grouping)
    }

    /// Sets the format for timeline group headers.
    public func timelineGroupingFormat(_ format: TimelineGroupingFormat) -> some View {
        environment(\.timelineGroupingFormat, format)
    }

    // MARK: - Section Customization

    /// Sets the visual style for timeline sections.
    public func timelineSectionStyle(_ style: TimelineSectionStyle) -> some View {
        environment(\.timelineSectionStyle, style)
    }

    /// Sets whether timeline sections can be collapsed.
    public func timelineSectionCollapsible(_ collapsible: Bool) -> some View {
        environment(\.timelineSectionCollapsible, collapsible)
    }
}

// MARK: - Convenience Modifier Chains

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Applies a complete indicator customization.
    public func timelineIndicator(
        shape: TimelineIndicatorShape = .circle,
        size: CGFloat = 12,
        color: Color? = nil,
        icon: String? = nil
    ) -> some View {
        self
            .timelineIndicatorShape(shape)
            .timelineIndicatorSize(size)
            .timelineIndicatorColor(color)
            .timelineIndicatorIcon(icon)
    }

    /// Applies a complete connector customization.
    public func timelineConnector(
        width: CGFloat = 2,
        color: Color = .gray.opacity(0.3),
        style: TimelineConnectorStyle = .solid
    ) -> some View {
        self
            .timelineConnectorWidth(width)
            .timelineConnectorColor(color)
            .timelineConnectorStyle(style)
    }

    /// Applies a complete layout customization.
    public func timelineLayout(
        spacing: CGFloat = 16,
        itemPadding: CGFloat = 12,
        indicatorPosition: TimelineIndicatorPosition = .leading
    ) -> some View {
        self
            .timelineSpacing(spacing)
            .timelineItemPadding(itemPadding)
            .timelineIndicatorPosition(indicatorPosition)
    }

    // MARK: - Branch Customization

    /// Sets the width of lanes in branching timelines.
    ///
    /// This determines the horizontal spacing between parallel branches.
    /// Only affects timelines with parent-child relationships.
    ///
    /// - Parameter width: The width of each lane in points. Default is 200.
    public func timelineBranchLaneWidth(_ width: CGFloat) -> some View {
        environment(\.timelineBranchLaneWidth, width)
    }

    /// Sets whether automatic branch detection is enabled.
    ///
    /// When enabled, the timeline will automatically detect parent-child
    /// relationships and display branches. Disable to force linear layout
    /// even when parent IDs are present.
    ///
    /// - Parameter enabled: Whether branch detection is enabled. Default is true.
    public func timelineBranchDetection(_ enabled: Bool) -> some View {
        environment(\.timelineBranchDetectionEnabled, enabled)
    }

    /// Sets the curve radius for branch connectors.
    ///
    /// Controls how sharply connectors curve when moving between lanes.
    /// Larger values create smoother, more gradual curves.
    ///
    /// - Parameter radius: The curve radius in points. Default is 20.
    public func timelineBranchConnectorCurve(_ radius: CGFloat) -> some View {
        environment(\.timelineBranchConnectorCurve, radius)
    }

    /// Sets whether branch indicators are shown at branch/merge points.
    ///
    /// - Parameter enabled: Whether branch indicators are shown. Default is true.
    public func timelineBranchIndicators(_ enabled: Bool) -> some View {
        environment(\.timelineBranchIndicatorEnabled, enabled)
    }
}
