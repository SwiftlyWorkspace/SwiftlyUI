import SwiftUI

/// Container view for Git-style branching timeline.
/// Shows branch graph on left, items in chronological column on right.
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

    // MARK: - Body

    var body: some View {
        let branchLayout = BranchAnalyzer.analyze(items: items)
        let graphWidth = CGFloat(branchLayout.laneCount) * laneWidth

        let _ = debugPrintLayout(branchLayout)

        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .center, spacing: 16) {
                        // LEFT: Branch graph visualization
                        branchGraphView(
                            for: item,
                            index: index,
                            layout: branchLayout,
                            graphWidth: graphWidth
                        )
                        .frame(width: graphWidth, height: itemSpacing)

                        // RIGHT: Timeline item content (single column)
                        content(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: itemSpacing)
                }
            }
            .padding()
        }
    }

    // MARK: - Private Views

    /// Debug helper to print lane assignments
    private func debugPrintLayout(_ layout: BranchLayout) {
        #if DEBUG
        print("\n=== BRANCH LAYOUT DEBUG ===")
        print("Total lanes: \(layout.laneCount)")
        for (index, item) in items.enumerated() {
            let lane = layout.itemLanes[item.id] ?? -1
            let parents = layout.parentMap[item.id] ?? []
            let reachTo = reachIndex(for: index, itemId: item.id, lane: lane, layout: layout)
            print("[\(index)] Lane \(lane): '\(item.title ?? "No title")' reaches to index \(reachTo) - Parents: \(parents.count)")
        }
        print("=========================\n")
        #endif
    }

    /// Check if a lane is active at a specific row (should have a line drawn)
    /// A lane is active in segments between items and their merges/next items
    private func isLaneActiveAt(index: Int, lane: Int, layout: BranchLayout) -> Bool {
        // Find all items on this lane at or before this index
        let previousItemsOnLane = items.enumerated().compactMap { itemIndex, item in
            layout.itemLanes[item.id] == lane && itemIndex <= index ? (itemIndex, item) : nil
        }

        guard let (lastItemIndex, lastItem) = previousItemsOnLane.last else {
            return false
        }

        // If this IS the item's row, it's active
        if lastItemIndex == index {
            return true
        }

        // Find where this item's line should extend to
        let reachToIndex = reachIndex(for: lastItemIndex, itemId: lastItem.id, lane: lane, layout: layout)

        // Lane is active if current index is between the item and where it reaches
        return index <= reachToIndex
    }

    /// Compute where an item's line should reach to
    /// Returns the index of the next item on same lane, or the merge point, whichever comes first
    private func reachIndex(for itemIndex: Int, itemId: AnyHashable, lane: Int, layout: BranchLayout) -> Int {
        // Find next item on the same lane that is actually a direct child
        let nextItemOnLane = items.enumerated().first { nextIndex, nextItem in
            guard nextIndex > itemIndex && layout.itemLanes[nextItem.id] == lane else {
                return false
            }
            // Only consider it a continuation if this item is a parent of the next item
            return layout.parentMap[nextItem.id]?.contains(itemId) ?? false
        }

        // Find first child that merges (is on a different lane)
        let mergePoint = items.enumerated().first { childIndex, childItem in
            childIndex > itemIndex &&
            layout.itemLanes[childItem.id] != lane &&
            (layout.parentMap[childItem.id]?.contains(itemId) ?? false)
        }

        // Return whichever comes first
        if let nextOnLane = nextItemOnLane?.0, let merge = mergePoint?.0 {
            return min(nextOnLane, merge)
        } else if let nextOnLane = nextItemOnLane?.0 {
            return nextOnLane
        } else if let merge = mergePoint?.0 {
            return merge
        } else {
            return itemIndex  // No continuation, end at this item
        }
    }

    /// Renders the branch graph (lanes, connectors, indicator) for one item.
    @ViewBuilder
    private func branchGraphView(
        for item: AnyTimelineItemWrapper,
        index: Int,
        layout: BranchLayout,
        graphWidth: CGFloat
    ) -> some View {
        let itemLane = layout.itemLanes[item.id] ?? 0
        let indicatorX = CGFloat(itemLane) * laneWidth + laneWidth / 2
        let centerY = itemSpacing / 2

        ZStack(alignment: .topLeading) {
            // Draw lines for all lanes
            ForEach(0..<layout.laneCount, id: \.self) { lane in
                let laneX = CGFloat(lane) * laneWidth + laneWidth / 2

                // Check if this lane is active at this row
                if isLaneActiveAt(index: index, lane: lane, layout: layout) {
                    if lane == itemLane {
                        // This is the current item's lane
                        Group {
                            // Draw connectors from parents to this item
                            if let parents = layout.parentMap[item.id], !parents.isEmpty {
                                ForEach(Array(parents.enumerated()), id: \.offset) { _, parentId in
                                    if let _ = items.firstIndex(where: { $0.id == parentId }),
                                       let parentLane = layout.itemLanes[parentId] {
                                        let parentX = CGFloat(parentLane) * laneWidth + laneWidth / 2

                                        connectorPath(
                                            from: CGPoint(x: parentX, y: 0),
                                            to: CGPoint(x: laneX, y: centerY),
                                            sameLane: parentLane == itemLane
                                        )
                                    }
                                }
                            }

                            // Draw line from item to bottom (if lane continues to next row)
                            if index < items.count - 1 && isLaneActiveAt(index: index + 1, lane: lane, layout: layout) {
                                Path { path in
                                    path.move(to: CGPoint(x: laneX, y: centerY))
                                    path.addLine(to: CGPoint(x: laneX, y: itemSpacing))
                                }
                                .stroke(connectorColor, lineWidth: connectorWidth)
                            }
                        }
                    } else {
                        // This is a different lane - check if we should draw a pass-through line

                        // Check if this lane continues below
                        let continuesBelow = index < items.count - 1 && isLaneActiveAt(index: index + 1, lane: lane, layout: layout)

                        // Check if this lane is merging into the current item AND not continuing
                        // (if it's continuing, it's a branch point, not a merge endpoint)
                        let isMergingAndEnding = layout.parentMap[item.id]?.contains { parentId in
                            layout.itemLanes[parentId] == lane
                        } ?? false && !continuesBelow

                        // Don't draw pass-through if merging and ending here (merge connector handles it)
                        if !isMergingAndEnding {
                            Path { path in
                                path.move(to: CGPoint(x: laneX, y: 0))
                                if continuesBelow {
                                    // Lane continues below - draw full line
                                    path.addLine(to: CGPoint(x: laneX, y: itemSpacing))
                                } else {
                                    // Lane ends here - draw to center
                                    path.addLine(to: CGPoint(x: laneX, y: centerY))
                                }
                            }
                            .stroke(connectorColor, lineWidth: connectorWidth)
                        }
                    }
                }
            }

            // Draw indicator at center
            TimelineIndicatorView(
                status: item.status,
                isSelected: selection.contains(item.id)
            )
            .environment(\.timelineIndicatorSize, 12)
            .position(x: indicatorX, y: centerY)
        }
        .frame(width: graphWidth, height: itemSpacing)
    }

    /// Creates a path from parent to child item.
    @ViewBuilder
    private func connectorPath(from: CGPoint, to: CGPoint, sameLane: Bool) -> some View {
        if sameLane {
            // Straight vertical line
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(connectorColor, lineWidth: connectorWidth)
        } else {
            // Curved line for branch/merge
            Path { path in
                path.move(to: from)

                let midY = (from.y + to.y) / 2
                let control1 = CGPoint(x: from.x, y: midY)
                let control2 = CGPoint(x: to.x, y: midY)

                path.addCurve(to: to, control1: control1, control2: control2)
            }
            .stroke(connectorColor, lineWidth: connectorWidth)
        }
    }
}
