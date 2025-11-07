import SwiftUI

/// A custom layout for horizontal timeline that properly aligns indicators, connectors, and content.
///
/// This layout ensures:
/// - Indicators are evenly spaced horizontally
/// - Connector line runs continuously through all indicators
/// - Content is aligned below each indicator
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct HorizontalTimelineLayout: Layout {
    let itemSpacing: CGFloat
    let indicatorSize: CGFloat

    init(itemSpacing: CGFloat = 100, indicatorSize: CGFloat = 16) {
        self.itemSpacing = itemSpacing
        self.indicatorSize = indicatorSize
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        // Calculate total width needed
        let itemCount = subviews.count / 2 // Half are indicators, half are content
        let totalWidth = CGFloat(itemCount - 1) * itemSpacing + indicatorSize * 2

        // Calculate height (indicator + spacing + max content height)
        let contentSubviews = Array(subviews.dropFirst(itemCount))
        let maxContentHeight = contentSubviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        let totalHeight = indicatorSize + 20 + maxContentHeight // 20pt spacing between indicator and content

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let itemCount = subviews.count / 2
        let indicators = Array(subviews.prefix(itemCount))
        let content = Array(subviews.dropFirst(itemCount))

        // Place indicators in a row at the top
        for (index, indicator) in indicators.enumerated() {
            let x = bounds.minX + CGFloat(index) * itemSpacing + indicatorSize / 2
            let y = bounds.minY + indicatorSize / 2

            indicator.place(
                at: CGPoint(x: x, y: y),
                anchor: .center,
                proposal: ProposedViewSize(width: indicatorSize, height: indicatorSize)
            )
        }

        // Place content below each indicator
        for (index, contentView) in content.enumerated() {
            let contentSize = contentView.sizeThatFits(proposal)
            let x = bounds.minX + CGFloat(index) * itemSpacing + indicatorSize / 2
            let y = bounds.minY + indicatorSize + 20 // 20pt spacing

            contentView.place(
                at: CGPoint(x: x, y: y),
                anchor: .top,
                proposal: ProposedViewSize(width: contentSize.width, height: contentSize.height)
            )
        }
    }
}

/// Container view for horizontal timeline items with proper layout.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct HorizontalTimelineContainer<Content: View>: View {
    let items: [AnyTimelineItemWrapper]
    let selection: Set<AnyHashable>
    let itemSpacing: CGFloat
    let indicatorSize: CGFloat
    let content: (AnyTimelineItemWrapper) -> Content

    @Environment(\.timelineConnectorColor) private var connectorColor
    @Environment(\.timelineConnectorWidth) private var connectorWidth

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                // Background connector line
                if items.count > 1 {
                    connectorLine
                }

                // Layout with indicators and content
                HorizontalTimelineLayout(itemSpacing: itemSpacing, indicatorSize: indicatorSize) {
                    // First pass: indicators
                    ForEach(items, id: \.id) { item in
                        TimelineIndicatorView(
                            status: item.status,
                            isSelected: selection.contains(item.id)
                        )
                    }

                    // Second pass: content
                    ForEach(items, id: \.id) { item in
                        content(item)
                            .frame(width: 116)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
        }
    }

    private var connectorLine: some View {
        let lineY = 20 + indicatorSize / 2 // Vertical center of indicators
        let lineStart = 40 + indicatorSize / 2 // Start from center of first indicator
        let lineLength = CGFloat(items.count - 1) * itemSpacing

        return Rectangle()
            .fill(connectorColor)
            .frame(width: lineLength, height: connectorWidth)
            .position(x: lineStart + lineLength / 2, y: lineY)
    }
}
