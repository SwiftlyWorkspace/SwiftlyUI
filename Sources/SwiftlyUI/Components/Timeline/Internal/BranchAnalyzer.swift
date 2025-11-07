import SwiftUI

// MARK: - Branch Point Type

/// The type of branch operation occurring at a timeline item.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
enum BranchPointType: Hashable {
    /// A new branch is created from a parent branch.
    case create

    /// A branch merges back into another branch.
    case merge
}

// MARK: - Branch Point

/// Represents a point in the timeline where a branch operation occurs.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BranchPoint: Hashable {
    /// The ID of the item where the branch operation occurs.
    let itemId: AnyHashable

    /// The type of branch operation (create or merge).
    let type: BranchPointType

    /// The lane of the source (parent) item.
    let fromLane: Int

    /// The lane of the target (child) item.
    let toLane: Int
}

// MARK: - Branch Layout

/// Contains the complete branch layout information for a timeline.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BranchLayout {
    /// The total number of lanes needed to display all branches.
    let laneCount: Int

    /// Maps each item ID to its assigned lane index (0-based).
    let itemLanes: [AnyHashable: Int]

    /// All branch creation and merge points in the timeline.
    let branchPoints: [BranchPoint]

    /// Maps each item ID to its parent IDs for quick lookup.
    let parentMap: [AnyHashable: [AnyHashable]]
}

// MARK: - Branch Analyzer

/// Analyzes timeline items to detect branch structure and assign lane positions.
///
/// The analyzer processes items chronologically and uses parent-child relationships
/// to detect when branches are created or merged. It assigns each item to a lane
/// (horizontal position) to visualize parallel development tracks.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BranchAnalyzer {
    // MARK: - Analysis

    /// Analyzes timeline items and returns the complete branch layout.
    ///
    /// - Parameter items: Timeline items sorted chronologically by date.
    /// - Returns: A `BranchLayout` containing lane assignments and branch points.
    static func analyze(items: [AnyTimelineItemWrapper]) -> BranchLayout {
        // Quick check: if no items have parents, return simple layout
        let hasParents = items.contains { $0.parentIds != nil && !$0.parentIds!.isEmpty }
        guard hasParents else {
            return BranchLayout(
                laneCount: 1,
                itemLanes: Dictionary(uniqueKeysWithValues: items.map { ($0.id, 0) }),
                branchPoints: [],
                parentMap: [:]
            )
        }

        // Build parent map for quick lookup
        let parentMap = buildParentMap(items: items)

        // Assign lanes and detect branch points
        var itemLanes: [AnyHashable: Int] = [:]
        var branchPoints: [BranchPoint] = []
        var maxLane = 0

        // Process items chronologically
        for item in items {
            let lane = assignLane(
                for: item,
                parentMap: parentMap,
                itemLanes: &itemLanes,
                branchPoints: &branchPoints,
                maxLane: &maxLane
            )

            itemLanes[item.id] = lane
            maxLane = max(maxLane, lane)
        }

        return BranchLayout(
            laneCount: maxLane + 1,
            itemLanes: itemLanes,
            branchPoints: branchPoints,
            parentMap: parentMap
        )
    }

    // MARK: - Private Helpers

    /// Builds a map of item ID to parent IDs.
    private static func buildParentMap(items: [AnyTimelineItemWrapper]) -> [AnyHashable: [AnyHashable]] {
        var parentMap: [AnyHashable: [AnyHashable]] = [:]

        for item in items {
            if let parents = item.parentIds, !parents.isEmpty {
                parentMap[item.id] = parents
            }
        }

        return parentMap
    }

    /// Assigns a lane to an item based on its parent relationships.
    ///
    /// Rules:
    /// - If item has no parents: assign to lane 0 (main branch)
    /// - If item has one parent in the same lane: keep in that lane
    /// - If item has one parent in a different lane: may trigger branch creation
    /// - If item has multiple parents: merge point, choose appropriate lane
    private static func assignLane(
        for item: AnyTimelineItemWrapper,
        parentMap: [AnyHashable: [AnyHashable]],
        itemLanes: inout [AnyHashable: Int],
        branchPoints: inout [BranchPoint],
        maxLane: inout Int
    ) -> Int {
        guard let parents = parentMap[item.id], !parents.isEmpty else {
            // No parents: assign to main branch (lane 0)
            return 0
        }

        // Get parent lanes (filter out parents that haven't been processed yet)
        let parentLanes = parents.compactMap { parentId -> (id: AnyHashable, lane: Int)? in
            guard let lane = itemLanes[parentId] else { return nil }
            return (id: parentId, lane: lane)
        }

        guard !parentLanes.isEmpty else {
            // Parents not yet processed: assign to main branch
            return 0
        }

        if parentLanes.count == 1 {
            // Single parent case
            let parentLane = parentLanes[0].lane

            // Check if this continues the same branch or creates a new one
            // A new branch is created if the parent has multiple children
            let isNewBranch = shouldCreateNewBranch(
                parentId: parentLanes[0].id,
                childId: item.id,
                parentLane: parentLane,
                items: parentMap.keys,
                itemLanes: itemLanes,
                parentMap: parentMap
            )

            if isNewBranch {
                // Create new branch: assign to next available lane
                let newLane = maxLane + 1
                branchPoints.append(BranchPoint(
                    itemId: item.id,
                    type: .create,
                    fromLane: parentLane,
                    toLane: newLane
                ))
                return newLane
            } else {
                // Continue in parent's lane
                return parentLane
            }
        } else {
            // Multiple parents: merge point
            // Choose the lowest-numbered lane as the target
            let targetLane = parentLanes.map { $0.lane }.min() ?? 0

            // Create branch points for all non-target parents
            for parent in parentLanes where parent.lane != targetLane {
                branchPoints.append(BranchPoint(
                    itemId: item.id,
                    type: .merge,
                    fromLane: parent.lane,
                    toLane: targetLane
                ))
            }

            return targetLane
        }
    }

    /// Determines if a new branch should be created for a child item.
    ///
    /// A new branch is created when:
    /// - The parent has multiple children
    /// - This is not the first child in chronological order
    private static func shouldCreateNewBranch(
        parentId: AnyHashable,
        childId: AnyHashable,
        parentLane: Int,
        items: Dictionary<AnyHashable, [AnyHashable]>.Keys,
        itemLanes: [AnyHashable: Int],
        parentMap: [AnyHashable: [AnyHashable]]
    ) -> Bool {
        // Find all children of this parent
        let children = parentMap.filter { _, parents in
            parents.contains(parentId)
        }.map { $0.key }

        // If parent has only one child, no branch needed
        guard children.count > 1 else {
            return false
        }

        // Check if this child is the first one assigned to the parent's lane
        let childrenInSameLane = children.filter { childItemId in
            if let lane = itemLanes[childItemId] {
                return lane == parentLane
            }
            return false
        }

        // If no children have been assigned to the parent's lane yet,
        // this child continues the parent's branch (no new branch)
        if childrenInSameLane.isEmpty {
            return false
        }

        // If other children are already in the parent's lane,
        // this child needs a new branch
        return !childrenInSameLane.contains(childId)
    }
}
