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
        let item1 = TimelineItem(id: UUID(), date: Date(), title: "Item 1")
        let item2 = TimelineItem(id: item1.id, date: Date(), title: "Item 2")
        let item3 = TimelineItem(date: Date(), title: "Item 3")

        XCTAssertEqual(item1, item2) // Same ID
        XCTAssertNotEqual(item1, item3) // Different ID
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
}
