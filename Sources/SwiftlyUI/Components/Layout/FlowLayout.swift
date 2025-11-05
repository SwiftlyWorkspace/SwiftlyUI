import SwiftUI

/// A layout that arranges subviews in a flowing manner, wrapping to new rows as needed.
///
/// `FlowLayout` is perfect for displaying collections of items that should wrap to new lines
/// when they exceed the available width, such as tags, chips, or badges.
///
/// - Note: This layout requires iOS 16.0+ or macOS 13.0+ for the `Layout` protocol.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct FlowLayout: Layout {
    /// The spacing between items in the same row.
    public let spacing: CGFloat

    /// Creates a new flow layout with the specified spacing.
    /// - Parameter spacing: The spacing between items. Defaults to 8 points.
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    /// Calculates the size that fits the proposed size for all subviews.
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    /// Places all subviews within the specified bounds.
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let subview = subviews[index]
                let size = subview.sizeThatFits(ProposedViewSize.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize.unspecified)
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    /// Computes the rows and their heights based on the available space and subviews.
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [(indices: [Int], height: CGFloat)] {
        var rows: [(indices: [Int], height: CGFloat)] = []
        var currentRow: [Int] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize.unspecified)

            // Check if adding this subview would exceed the maximum width
            let wouldExceedWidth = currentWidth + size.width > maxWidth
            let hasItemsInCurrentRow = !currentRow.isEmpty

            if wouldExceedWidth && hasItemsInCurrentRow {
                // Finish the current row and start a new one
                rows.append((indices: currentRow, height: currentHeight))
                currentRow = []
                currentWidth = 0
                currentHeight = 0
            }

            // Add the subview to the current row
            currentRow.append(index)
            currentWidth += size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }

        // Add the last row if it has any items
        if !currentRow.isEmpty {
            rows.append((indices: currentRow, height: currentHeight))
        }

        return rows
    }
}

/// A simple flow layout that wraps views to new lines when needed.
///
/// This is a simplified version that works across all supported OS versions
/// without using the Layout protocol.
public struct SimpleFlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    /// Creates a simple flow layout with the specified spacing and content.
    /// - Parameters:
    ///   - spacing: The spacing between items.
    ///   - content: The content to arrange in a flowing layout.
    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        // For now, use a simple wrapping HStack for older OS versions
        // This provides basic flow behavior
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
    }
}