import XCTest
@testable import SwiftlyUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class TimelineTests: XCTestCase {

    // MARK: - TimelineItem Tests

    func testTimelineItemCreation() {
        let item = TimelineItem(
            date: Date(),
            title: "Test Title",
            description: "Test Description",
            status: .completed
        )

        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.title, "Test Title")
        XCTAssertEqual(item.description, "Test Description")
        XCTAssertEqual(item.status, .completed)
    }

    func testTimelineItemFactoryMethods() {
        let date = Date()

        let completed = TimelineItem.completed(date: date, title: "Completed Task")
        XCTAssertEqual(completed.status, .completed)
        XCTAssertEqual(completed.title, "Completed Task")

        let inProgress = TimelineItem.inProgress(date: date, title: "Active Task")
        XCTAssertEqual(inProgress.status, .inProgress)

        let pending = TimelineItem.pending(date: date, title: "Pending Task")
        XCTAssertEqual(pending.status, .pending)
    }

    func testTimelineItemProtocolConformance() {
        let item = TimelineItem(date: Date(), title: "Test")

        // Test TimelineItemRepresentable conformance
        XCTAssertEqual(item.timelineDate, item.date)
        XCTAssertEqual(item.timelineTitle, item.title)
        XCTAssertEqual(item.timelineDescription, item.description)
        XCTAssertEqual(item.timelineStatus, item.status)
    }

    func testTimelineItemHashable() {
        let date = Date()
        let item1 = TimelineItem(id: UUID(), date: date, title: "Item 1", status: .completed)
        let item2 = TimelineItem(id: item1.id, date: date, title: "Item 1", status: .completed)
        let item3 = TimelineItem(date: date, title: "Item 3")

        // Hashable includes all properties, so items with same ID but different properties are not equal
        XCTAssertEqual(item1, item2) // Same ID and same properties
        XCTAssertNotEqual(item1, item3) // Different ID

        // Test that items can be used in Sets (Hashable requirement)
        let set: Set<TimelineItem> = [item1, item2, item3]
        XCTAssertEqual(set.count, 2) // item1 and item2 are equal, so set has 2 unique items
    }

    // MARK: - TimelineStatus Tests

    func testTimelineStatusColors() {
        XCTAssertEqual(TimelineStatus.pending.color, .gray)
        XCTAssertEqual(TimelineStatus.inProgress.color, .blue)
        XCTAssertEqual(TimelineStatus.completed.color, .green)
        XCTAssertEqual(TimelineStatus.cancelled.color, .red)
        XCTAssertEqual(TimelineStatus.blocked.color, .orange)
        XCTAssertEqual(TimelineStatus.review.color, .purple)
    }

    func testTimelineStatusIcons() {
        XCTAssertEqual(TimelineStatus.pending.defaultIcon, "clock")
        XCTAssertEqual(TimelineStatus.inProgress.defaultIcon, "arrow.clockwise")
        XCTAssertEqual(TimelineStatus.completed.defaultIcon, "checkmark")
        XCTAssertEqual(TimelineStatus.cancelled.defaultIcon, "xmark")
        XCTAssertEqual(TimelineStatus.blocked.defaultIcon, "exclamationmark.triangle")
        XCTAssertEqual(TimelineStatus.review.defaultIcon, "eye")
    }

    func testTimelineStatusStates() {
        XCTAssertTrue(TimelineStatus.completed.isCompleted)
        XCTAssertFalse(TimelineStatus.pending.isCompleted)

        XCTAssertTrue(TimelineStatus.inProgress.isActive)
        XCTAssertTrue(TimelineStatus.review.isActive)
        XCTAssertFalse(TimelineStatus.completed.isActive)

        XCTAssertTrue(TimelineStatus.blocked.isBlocked)
        XCTAssertTrue(TimelineStatus.cancelled.isBlocked)
        XCTAssertFalse(TimelineStatus.pending.isBlocked)
    }

    // MARK: - Date Sorting Tests

    func testTimelineItemSorting() {
        let now = Date()
        let item1 = TimelineItem(date: now.addingTimeInterval(-3600), title: "Old")
        let item2 = TimelineItem(date: now, title: "Recent")
        let item3 = TimelineItem(date: now.addingTimeInterval(-7200), title: "Oldest")

        let items = [item1, item2, item3]
        let sorted = items.sorted { $0.timelineDate < $1.timelineDate }

        XCTAssertEqual(sorted[0].title, "Oldest")
        XCTAssertEqual(sorted[1].title, "Old")
        XCTAssertEqual(sorted[2].title, "Recent")
    }

    // MARK: - Custom Type Conformance Tests

    func testCustomTypeConformance() {
        struct CustomEvent: TimelineItemRepresentable {
            let id: UUID
            let timelineDate: Date
            let timelineTitle: String?
            let timelineDescription: String?
            let timelineStatus: TimelineStatus?

            var eventType: String
        }

        let event = CustomEvent(
            id: UUID(),
            timelineDate: Date(),
            timelineTitle: "Custom Event",
            timelineDescription: "Description",
            timelineStatus: .completed,
            eventType: "Meeting"
        )

        XCTAssertEqual(event.timelineTitle, "Custom Event")
        XCTAssertEqual(event.timelineStatus, .completed)
        XCTAssertEqual(event.eventType, "Meeting")
    }

    // MARK: - Configuration Type Tests

    func testTimelineIndicatorShape() {
        let circle = TimelineIndicatorShape.circle
        let square = TimelineIndicatorShape.square
        let roundedSquare = TimelineIndicatorShape.roundedSquare()
        let diamond = TimelineIndicatorShape.diamond

        XCTAssertEqual(circle, .circle)
        XCTAssertEqual(square, .square)
        XCTAssertEqual(diamond, .diamond)
        XCTAssertNotEqual(circle, square)
    }

    func testTimelineConnectorStyle() {
        let solid = TimelineConnectorStyle.solid
        let dashed = TimelineConnectorStyle.dashed
        let dotted = TimelineConnectorStyle.dotted

        XCTAssertEqual(solid, .solid)
        XCTAssertEqual(dashed, .dashed)
        XCTAssertEqual(dotted, .dotted)
        XCTAssertNotEqual(solid, dashed)
    }

    func testTimelineGrouping() {
        XCTAssertEqual(TimelineGrouping.none.rawValue, "none")
        XCTAssertEqual(TimelineGrouping.day.rawValue, "day")
        XCTAssertEqual(TimelineGrouping.week.rawValue, "week")
        XCTAssertEqual(TimelineGrouping.month.rawValue, "month")
        XCTAssertEqual(TimelineGrouping.year.rawValue, "year")
    }

    // MARK: - Edge Cases Tests

    func testEmptyTimelineItems() {
        let items: [TimelineItem] = []
        XCTAssertTrue(items.isEmpty)
        XCTAssertEqual(items.count, 0)
    }

    func testSingleTimelineItem() {
        let item = TimelineItem(date: Date(), title: "Single Item")
        let items = [item]

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Single Item")
    }

    func testTimelineItemWithoutOptionalFields() {
        let item = TimelineItem(date: Date())

        XCTAssertNil(item.title)
        XCTAssertNil(item.description)
        XCTAssertNil(item.status)
    }

    func testTimelineItemWithLongDescription() {
        let longDescription = String(repeating: "A", count: 1000)
        let item = TimelineItem(
            date: Date(),
            title: "Item",
            description: longDescription
        )

        XCTAssertEqual(item.description?.count, 1000)
    }

    // MARK: - Performance Tests

    func testLargeDatasetSorting() {
        measure {
            let items = (0..<1000).map { index in
                TimelineItem(
                    date: Date().addingTimeInterval(Double(index) * -60),
                    title: "Item \(index)"
                )
            }

            let _ = items.sorted { $0.timelineDate < $1.timelineDate }
        }
    }

    func testLargeDatasetFiltering() {
        let items = (0..<1000).map { index in
            TimelineItem(
                date: Date().addingTimeInterval(Double(index) * -60),
                title: "Item \(index)",
                status: index % 2 == 0 ? .completed : .inProgress
            )
        }

        measure {
            let _ = items.filter { $0.status == .completed }
        }
    }

    // MARK: - Type Wrapper Tests

    func testAnyTimelineItemWrapper() {
        let item = TimelineItem(
            date: Date(),
            title: "Test",
            description: "Description",
            status: .completed
        )

        let wrapper = AnyTimelineItemWrapper(item)

        XCTAssertEqual(wrapper.title, "Test")
        XCTAssertEqual(wrapper.description, "Description")
        XCTAssertEqual(wrapper.status, .completed)
        XCTAssertEqual(wrapper.date, item.date)
    }

    func testWrapperEquality() {
        let item1 = TimelineItem(id: UUID(), date: Date(), title: "Item 1")
        let item2 = TimelineItem(id: item1.id, date: Date(), title: "Item 2")
        let item3 = TimelineItem(date: Date(), title: "Item 3")

        let wrapper1 = AnyTimelineItemWrapper(item1)
        let wrapper2 = AnyTimelineItemWrapper(item2)
        let wrapper3 = AnyTimelineItemWrapper(item3)

        XCTAssertEqual(wrapper1, wrapper2) // Same ID
        XCTAssertNotEqual(wrapper1, wrapper3) // Different ID
    }

    func testWrapperHashable() {
        let item1 = TimelineItem(id: UUID(), date: Date(), title: "Item 1")
        let item2 = TimelineItem(date: Date(), title: "Item 2")

        let wrapper1 = AnyTimelineItemWrapper(item1)
        let wrapper2 = AnyTimelineItemWrapper(item2)

        var set = Set<AnyTimelineItemWrapper>()
        set.insert(wrapper1)
        set.insert(wrapper2)

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(wrapper1))
        XCTAssertTrue(set.contains(wrapper2))
    }

    // MARK: - Collection Tests

    func testMultipleStatusFiltering() {
        let items = [
            TimelineItem(date: Date(), title: "1", status: .completed),
            TimelineItem(date: Date(), title: "2", status: .inProgress),
            TimelineItem(date: Date(), title: "3", status: .completed),
            TimelineItem(date: Date(), title: "4", status: .pending),
            TimelineItem(date: Date(), title: "5", status: .completed)
        ]

        let completed = items.filter { $0.status == .completed }
        XCTAssertEqual(completed.count, 3)

        let active = items.filter { $0.status?.isActive == true }
        XCTAssertEqual(active.count, 1)
    }

    func testDateRangeFiltering() {
        let now = Date()
        let items = [
            TimelineItem(date: now.addingTimeInterval(-86400), title: "Yesterday"),
            TimelineItem(date: now, title: "Today"),
            TimelineItem(date: now.addingTimeInterval(-172800), title: "Two days ago")
        ]

        let yesterday = now.addingTimeInterval(-86400)
        let recentItems = items.filter { $0.date >= yesterday }

        XCTAssertEqual(recentItems.count, 2)
    }

    // MARK: - Sendable Conformance Tests

    func testTimelineItemSendable() {
        // TimelineItem should be Sendable
        let item = TimelineItem(date: Date(), title: "Test")

        Task {
            let _ = item // Should compile without warnings
        }
    }

    func testTimelineStatusSendable() {
        // TimelineStatus should be Sendable
        let status = TimelineStatus.completed

        Task {
            let _ = status // Should compile without warnings
        }
    }

    // MARK: - Branch Detection Tests

    func testTimelineItemWithParentIds() {
        let parent = TimelineItem(date: Date(), title: "Parent")
        let child = TimelineItem(
            date: Date().addingTimeInterval(100),
            title: "Child",
            parentIds: [parent.id]
        )

        XCTAssertNotNil(child.parentIds)
        XCTAssertEqual(child.parentIds?.count, 1)
        XCTAssertEqual(child.parentIds?.first, parent.id)
        XCTAssertEqual(child.timelineParentIds?.first, AnyHashable(parent.id))
    }

    func testTimelineItemWithParentConvenienceMethod() {
        let parent = TimelineItem(date: Date(), title: "Parent")
        let child = TimelineItem(date: Date(), title: "Child")
            .withParent(parent.id)

        XCTAssertEqual(child.parentIds?.count, 1)
        XCTAssertEqual(child.parentIds?.first, parent.id)
    }

    func testTimelineItemWithMultipleParents() {
        let parent1 = TimelineItem(date: Date(), title: "Parent 1")
        let parent2 = TimelineItem(date: Date(), title: "Parent 2")
        let merge = TimelineItem(date: Date(), title: "Merge")
            .withParents([parent1.id, parent2.id])

        XCTAssertEqual(merge.parentIds?.count, 2)
        XCTAssertTrue(merge.parentIds?.contains(parent1.id) == true)
        XCTAssertTrue(merge.parentIds?.contains(parent2.id) == true)
    }

    func testBranchAnalyzerNoParents() {
        // Simple linear timeline with no parent relationships
        let item1 = TimelineItem(date: Date(), title: "Item 1")
        let item2 = TimelineItem(date: Date().addingTimeInterval(100), title: "Item 2")

        let wrappers = [item1, item2].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        XCTAssertEqual(layout.laneCount, 1)
        XCTAssertEqual(layout.itemLanes.count, 2)
        XCTAssertEqual(layout.itemLanes[AnyHashable(item1.id)], 0)
        XCTAssertEqual(layout.itemLanes[AnyHashable(item2.id)], 0)
        XCTAssertTrue(layout.branchPoints.isEmpty)
    }

    func testBranchAnalyzerLinearHistory() {
        // Linear history with parent relationships
        let commit1 = TimelineItem(date: Date(), title: "Commit 1")
        let commit2 = TimelineItem(
            date: Date().addingTimeInterval(100),
            title: "Commit 2"
        ).withParent(commit1.id)
        let commit3 = TimelineItem(
            date: Date().addingTimeInterval(200),
            title: "Commit 3"
        ).withParent(commit2.id)

        let wrappers = [commit1, commit2, commit3].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        XCTAssertEqual(layout.laneCount, 1, "Linear history should use 1 lane")
        XCTAssertEqual(layout.itemLanes[AnyHashable(commit1.id)], 0)
        XCTAssertEqual(layout.itemLanes[AnyHashable(commit2.id)], 0)
        XCTAssertEqual(layout.itemLanes[AnyHashable(commit3.id)], 0)
        XCTAssertTrue(layout.branchPoints.isEmpty, "No branch operations in linear history")
    }

    func testBranchAnalyzerBranchCreation() {
        // Main branch with feature branch diverging
        let commit1 = TimelineItem(date: Date(), title: "Initial commit")
        let mainCommit = TimelineItem(
            date: Date().addingTimeInterval(100),
            title: "Main work"
        ).withParent(commit1.id)
        let featureCommit = TimelineItem(
            date: Date().addingTimeInterval(150),
            title: "Feature work"
        ).withParent(commit1.id)

        let wrappers = [commit1, mainCommit, featureCommit].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        XCTAssertEqual(layout.laneCount, 2, "Should have 2 lanes (main + feature)")
        XCTAssertEqual(layout.itemLanes[AnyHashable(commit1.id)], 0)
        XCTAssertEqual(layout.itemLanes[AnyHashable(mainCommit.id)], 0, "First child stays in parent lane")

        let featureLane = layout.itemLanes[AnyHashable(featureCommit.id)]
        XCTAssertNotNil(featureLane)
        XCTAssertNotEqual(featureLane, 0, "Feature branch should be in different lane")

        // Check for branch creation point
        let branchCreations = layout.branchPoints.filter { $0.type == .create }
        XCTAssertEqual(branchCreations.count, 1, "Should have 1 branch creation")
        XCTAssertEqual(branchCreations.first?.itemId, AnyHashable(featureCommit.id))
    }

    func testBranchAnalyzerMerge() {
        // Two branches merging
        let commit1 = TimelineItem(date: Date(), title: "Initial")
        let main2 = TimelineItem(
            date: Date().addingTimeInterval(100),
            title: "Main 2"
        ).withParent(commit1.id)
        let feature = TimelineItem(
            date: Date().addingTimeInterval(150),
            title: "Feature"
        ).withParent(commit1.id)
        let merge = TimelineItem(
            date: Date().addingTimeInterval(200),
            title: "Merge"
        ).withParents([main2.id, feature.id])

        let wrappers = [commit1, main2, feature, merge].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        XCTAssertGreaterThanOrEqual(layout.laneCount, 2, "Should have at least 2 lanes")

        // Check for merge point
        let mergePoints = layout.branchPoints.filter { $0.type == .merge }
        XCTAssertGreaterThan(mergePoints.count, 0, "Should have merge point(s)")

        // Verify merge target item
        let mergePointsForMergeCommit = mergePoints.filter { $0.itemId == AnyHashable(merge.id) }
        XCTAssertGreaterThan(mergePointsForMergeCommit.count, 0, "Merge commit should have branch points")
    }

    func testBranchAnalyzerComplexGraph() {
        // Complex branching with multiple branches and merges
        let c1 = TimelineItem(date: Date(), title: "C1")
        let c2 = TimelineItem(date: Date().addingTimeInterval(100), title: "C2").withParent(c1.id)
        let c3 = TimelineItem(date: Date().addingTimeInterval(150), title: "C3").withParent(c1.id)
        let c4 = TimelineItem(date: Date().addingTimeInterval(200), title: "C4").withParent(c2.id)
        let c5 = TimelineItem(date: Date().addingTimeInterval(250), title: "C5").withParent(c3.id)
        let c6 = TimelineItem(date: Date().addingTimeInterval(300), title: "C6").withParents([c4.id, c5.id])

        let wrappers = [c1, c2, c3, c4, c5, c6].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        // Should have multiple lanes for parallel development
        XCTAssertGreaterThanOrEqual(layout.laneCount, 2)

        // All items should be assigned to lanes
        XCTAssertEqual(layout.itemLanes.count, 6)

        // Should have both branch creations and merges
        XCTAssertGreaterThan(layout.branchPoints.count, 0)
    }

    func testBranchAnalyzerParentMap() {
        let commit1 = TimelineItem(date: Date(), title: "C1")
        let commit2 = TimelineItem(date: Date(), title: "C2").withParent(commit1.id)

        let wrappers = [commit1, commit2].map { AnyTimelineItemWrapper($0) }
        let layout = BranchAnalyzer.analyze(items: wrappers)

        XCTAssertEqual(layout.parentMap.count, 1)
        XCTAssertEqual(layout.parentMap[AnyHashable(commit2.id)]?.count, 1)
        XCTAssertEqual(layout.parentMap[AnyHashable(commit2.id)]?.first, AnyHashable(commit1.id))
    }
}
