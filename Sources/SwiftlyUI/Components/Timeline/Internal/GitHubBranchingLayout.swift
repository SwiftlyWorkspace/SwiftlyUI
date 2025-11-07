import SwiftUI

/// A custom layout for GitHub-style branching timeline visualization.
///
/// This layout analyzes timeline items to detect branch relationships, then positions
/// items in horizontal lanes with branch and merge visualization using curved connectors.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct GitHubBranchingLayout: Layout {
    // MARK: - Properties

    let items: [AnyTimelineItemWrapper]
    let laneWidth: CGFloat
    let itemSpacing: CGFloat

    init(items: [AnyTimelineItemWrapper], laneWidth: CGFloat = 60, itemSpacing: CGFloat = 80) {
        self.items = items
        self.laneWidth = laneWidth
        self.itemSpacing = itemSpacing
    }

    // MARK: - Layout Protocol

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) -> CGSize {
        let layout = cache.branchLayout
        let totalWidth = CGFloat(layout.laneCount) * laneWidth
        let totalHeight = CGFloat(items.count) * itemSpacing

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        let itemPositions = cache.itemPositions

        // Place each item in its assigned lane
        for (index, subview) in subviews.enumerated() {
            guard index < items.count else { continue }

            let item = items[index]
            guard let position = itemPositions[item.id] else { continue }

            let size = subview.sizeThatFits(proposal)
            subview.place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                anchor: .center,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    func makeCache(subviews: Subviews) -> LayoutCache {
        let branchLayout = BranchAnalyzer.analyze(items: items)

        // Calculate positions for all items
        var itemPositions: [AnyHashable: CGPoint] = [:]

        for (index, item) in items.enumerated() {
            guard let lane = branchLayout.itemLanes[item.id] else { continue }

            let x = CGFloat(lane) * laneWidth + laneWidth / 2
            let y = CGFloat(index) * itemSpacing + itemSpacing / 2

            itemPositions[item.id] = CGPoint(x: x, y: y)
        }

        return LayoutCache(
            branchLayout: branchLayout,
            itemPositions: itemPositions,
            laneWidth: laneWidth,
            itemSpacing: itemSpacing
        )
    }

    // MARK: - Layout Cache

    struct LayoutCache {
        let branchLayout: BranchLayout
        let itemPositions: [AnyHashable: CGPoint]
        let laneWidth: CGFloat
        let itemSpacing: CGFloat
    }
}

/// Container view that combines GitHubBranchingLayout with connectors and indicators.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct GitHubBranchingContainer<Content: View>: View {
    // MARK: - Properties

    let items: [AnyTimelineItemWrapper]
    let selection: Set<AnyHashable>
    let laneWidth: CGFloat
    let itemSpacing: CGFloat
    let content: (AnyTimelineItemWrapper) -> Content

    @Environment(\.timelineConnectorColor) private var connectorColor
    @Environment(\.timelineConnectorWidth) private var connectorWidth

    // MARK: - Private State

    @State private var branchLayout: BranchLayout?
    @State private var itemPositions: [AnyHashable: CGPoint] = [:]

    // MARK: - Body

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Layer 1: Connectors (background)
                if let layout = branchLayout {
                    connectorLayer(layout: layout)
                }

                // Layer 2: Branch indicators (mid-layer)
                if let layout = branchLayout {
                    branchIndicatorLayer(layout: layout)
                }

                // Layer 3: Item cards (foreground)
                GitHubBranchingLayout(
                    items: items,
                    laneWidth: laneWidth,
                    itemSpacing: itemSpacing
                ) {
                    ForEach(items, id: \.id) { item in
                        content(item)
                            .frame(minWidth: laneWidth * 0.9)
                    }
                }
            }
            .padding()
            .onAppear {
                analyzeBranches()
            }
        }
    }

    // MARK: - Private Views

    /// Renders all connector lines between items.
    private func connectorLayer(layout: BranchLayout) -> some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            if let parents = layout.parentMap[item.id],
               !parents.isEmpty,
               let toPosition = itemPositions[item.id] {

                ForEach(Array(parents.enumerated()), id: \.offset) { _, parentId in
                    if let fromPosition = itemPositions[parentId] {
                        connectorView(from: fromPosition, to: toPosition, layout: layout)
                    }
                }
            }
        }
    }

    /// Renders a single connector between two items.
    private func connectorView(from: CGPoint, to: CGPoint, layout: BranchLayout) -> some View {
        let connectorType: BranchConnectorType

        if abs(from.x - to.x) < 1 {
            // Same lane: straight line
            connectorType = .straight(from: from, to: to)
        } else if from.x < to.x {
            // Moving right: branch creation
            connectorType = .curveRight(from: from, to: to)
        } else {
            // Moving left: branch merge
            connectorType = .curveLeft(from: from, to: to)
        }

        return BranchConnectorView(connectorType: connectorType)
    }

    /// Renders branch indicators at branch/merge points.
    private func branchIndicatorLayer(layout: BranchLayout) -> some View {
        ForEach(layout.branchPoints, id: \.itemId) { branchPoint in
            if let position = itemPositions[branchPoint.itemId] {
                BranchIndicatorView(branchPoint: branchPoint)
                    .position(x: position.x, y: position.y - 20) // Slightly above the item
            }
        }
    }

    // MARK: - Private Methods

    /// Analyzes items to detect branch structure and calculate positions.
    private func analyzeBranches() {
        let layout = BranchAnalyzer.analyze(items: items)
        self.branchLayout = layout

        // Calculate positions
        var positions: [AnyHashable: CGPoint] = [:]

        for (index, item) in items.enumerated() {
            guard let lane = layout.itemLanes[item.id] else { continue }

            let x = CGFloat(lane) * laneWidth + laneWidth / 2
            let y = CGFloat(index) * itemSpacing + itemSpacing / 2

            positions[item.id] = CGPoint(x: x, y: y)
        }

        self.itemPositions = positions
    }
}
