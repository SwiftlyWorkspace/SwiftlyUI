import SwiftUI

/// A view that displays a single timeline item with indicator, connector, and content.
///
/// This internal view handles the layout and interaction for individual timeline items,
/// including expand/collapse functionality for long content.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineItemView: View {
    // MARK: - Properties

    let item: AnyTimelineItemWrapper
    let isLast: Bool
    let allowsSelection: Bool
    let isSelected: Bool
    let onTap: ((AnyTimelineItemWrapper) -> Void)?
    let customContent: AnyView?

    @State private var isExpanded: Bool = false

    @Environment(\.timelineIndicatorPosition) private var indicatorPosition
    @Environment(\.timelineSpacing) private var spacing
    @Environment(\.timelineItemPadding) private var padding
    @Environment(\.timelineExpandable) private var expandable
    @Environment(\.timelineDefaultExpanded) private var defaultExpanded

    // MARK: - Initializers

    init(
        item: AnyTimelineItemWrapper,
        isLast: Bool,
        allowsSelection: Bool,
        isSelected: Bool,
        onTap: ((AnyTimelineItemWrapper) -> Void)?,
        customContent: AnyView? = nil
    ) {
        self.item = item
        self.isLast = isLast
        self.allowsSelection = allowsSelection
        self.isSelected = isSelected
        self.onTap = onTap
        self.customContent = customContent
        self._isExpanded = State(initialValue: defaultExpanded)
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Leading indicator
            if indicatorPosition == .leading {
                indicatorColumn
            }

            // Content
            VStack(alignment: .leading, spacing: 0) {
                contentView
                    .padding(padding)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let onTap = onTap {
                            onTap(item)
                        }
                    }

                // Spacing after item
                if !isLast {
                    Spacer()
                        .frame(height: spacing)
                }
            }

            // Trailing indicator
            if indicatorPosition == .trailing {
                indicatorColumn
            }
        }
    }

    // MARK: - Private Views

    private var indicatorColumn: some View {
        VStack(spacing: 0) {
            TimelineIndicatorView(status: item.status, isSelected: isSelected)

            if !isLast {
                TimelineConnectorView(isVertical: true)
                    .frame(height: nil)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if let customContent = customContent {
            customContent
        } else {
            defaultContent
        }
    }

    @ViewBuilder
    private var defaultContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            if let title = item.title {
                Text(title)
                    .font(.headline)
            }

            // Description with expand/collapse
            if let description = item.description {
                if expandable && isLongDescription {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isExpanded ? description : truncatedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(isExpanded ? "Show Less" : "Show More")
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            }
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Date and Status
            HStack(spacing: 12) {
                // Relative date
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(item.date, style: .relative)
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)

                // Status badge
                if let status = item.status {
                    HStack(spacing: 4) {
                        Image(systemName: status.defaultIcon)
                            .font(.caption2)
                        Text(status.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.color.opacity(0.15))
                    .foregroundStyle(status.color)
                    .clipShape(Capsule())
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var isLongDescription: Bool {
        (item.description?.count ?? 0) > 150
    }

    private var truncatedDescription: String {
        guard let description = item.description, isLongDescription else {
            return item.description ?? ""
        }
        return String(description.prefix(150)) + "..."
    }
}

// MARK: - Preview

#Preview("Timeline Item View") {
    VStack(spacing: 0) {
        TimelineItemView(
            item: AnyTimelineItemWrapper(
                TimelineItem(
                    date: Date().addingTimeInterval(-3600),
                    title: "Task Completed",
                    description: "Successfully finished the project milestone and delivered all requirements on time.",
                    status: .completed
                )
            ),
            isLast: false,
            allowsSelection: false,
            isSelected: false,
            onTap: nil
        )

        TimelineItemView(
            item: AnyTimelineItemWrapper(
                TimelineItem(
                    date: Date().addingTimeInterval(-1800),
                    title: "In Progress",
                    description: "Currently working on implementation. This is a very long description that will need to be truncated and will show the expand/collapse functionality. It contains multiple sentences to demonstrate how the component handles longer text content. The user can click 'Show More' to see the full text.",
                    status: .inProgress
                )
            ),
            isLast: false,
            allowsSelection: true,
            isSelected: false,
            onTap: { _ in }
        )

        TimelineItemView(
            item: AnyTimelineItemWrapper(
                TimelineItem(
                    date: Date(),
                    title: "Pending Review",
                    description: "Waiting for approval",
                    status: .review
                )
            ),
            isLast: true,
            allowsSelection: true,
            isSelected: true,
            onTap: { _ in }
        )
    }
    .padding()
}

#Preview("Different Indicator Positions") {
    VStack(spacing: 40) {
        // Leading position (default)
        TimelineItemView(
            item: AnyTimelineItemWrapper(
                TimelineItem(
                    date: Date(),
                    title: "Leading Indicator",
                    description: "Indicator on the left side",
                    status: .completed
                )
            ),
            isLast: false,
            allowsSelection: false,
            isSelected: false,
            onTap: nil
        )
        .environment(\.timelineIndicatorPosition, .leading)

        Divider()

        // Trailing position
        TimelineItemView(
            item: AnyTimelineItemWrapper(
                TimelineItem(
                    date: Date(),
                    title: "Trailing Indicator",
                    description: "Indicator on the right side",
                    status: .inProgress
                )
            ),
            isLast: true,
            allowsSelection: false,
            isSelected: false,
            onTap: nil
        )
        .environment(\.timelineIndicatorPosition, .trailing)
    }
    .padding()
}
