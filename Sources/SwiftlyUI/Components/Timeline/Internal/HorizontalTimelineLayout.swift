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

        // First subview is connector line, rest are divided between indicators and content
        let itemCount = (subviews.count - 1) / 2
        let totalWidth = CGFloat(max(0, itemCount - 1)) * itemSpacing + indicatorSize * 2

        // Calculate height (indicator + spacing + max content height)
        let contentStartIndex = 1 + itemCount
        let contentSubviews = Array(subviews.dropFirst(contentStartIndex))
        let maxContentHeight = contentSubviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        let totalHeight = indicatorSize + 20 + maxContentHeight

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let itemCount = (subviews.count - 1) / 2

        // First subview is the connector line
        let connectorLine = subviews[0]
        let indicators = Array(subviews[1...(itemCount)])
        let content = Array(subviews.dropFirst(itemCount + 1))

        // Place connector line through all indicator positions
        if itemCount > 1 {
            let firstX = bounds.minX + indicatorSize / 2
            let lastX = bounds.minX + CGFloat(itemCount - 1) * itemSpacing + indicatorSize / 2
            let lineLength = lastX - firstX
            let lineY = bounds.minY + indicatorSize / 2

            connectorLine.place(
                at: CGPoint(x: firstX, y: lineY),
                anchor: .leading,
                proposal: ProposedViewSize(width: lineLength, height: 2)
            )
        }

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
            let y = bounds.minY + indicatorSize + 20

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
            HorizontalTimelineLayout(itemSpacing: itemSpacing, indicatorSize: indicatorSize) {
                // Connector line as first subview
                Rectangle()
                    .fill(connectorColor)
                    .frame(height: connectorWidth)

                // Indicators
                ForEach(items, id: \.id) { item in
                    TimelineIndicatorView(
                        status: item.status,
                        isSelected: selection.contains(item.id)
                    )
                }

                // Content
                ForEach(items, id: \.id) { item in
                    content(item)
                        .frame(width: 116)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
        }
    }
}
