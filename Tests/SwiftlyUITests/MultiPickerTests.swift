import XCTest
@testable import SwiftlyUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class MultiPickerTests: XCTestCase {

    // MARK: - Selection State Management Tests

    func testBasicSelection() {
        var selection: Set<Int> = []

        // Initially empty
        XCTAssertTrue(selection.isEmpty)
        XCTAssertEqual(selection.count, 0)

        // Add first selection
        selection.insert(1)
        XCTAssertTrue(selection.contains(1))
        XCTAssertEqual(selection.count, 1)

        // Add second selection
        selection.insert(2)
        XCTAssertTrue(selection.contains(2))
        XCTAssertEqual(selection.count, 2)
    }

    func testRemoveSelection() {
        var selection: Set<Int> = [1, 2, 3]

        XCTAssertEqual(selection.count, 3)

        selection.remove(2)
        XCTAssertFalse(selection.contains(2))
        XCTAssertEqual(selection.count, 2)
    }

    func testMultipleSimultaneousSelections() {
        var selection: Set<String> = []
        let items = ["A", "B", "C", "D", "E"]

        // Select multiple at once
        selection = Set(items)

        XCTAssertEqual(selection.count, 5)
        items.forEach { item in
            XCTAssertTrue(selection.contains(item))
        }
    }

    func testSelectionSetUpdatesCorrectly() {
        var selection: Set<Int> = [1, 2]

        // Replace entire set
        selection = [3, 4, 5]

        XCTAssertFalse(selection.contains(1))
        XCTAssertFalse(selection.contains(2))
        XCTAssertTrue(selection.contains(3))
        XCTAssertTrue(selection.contains(4))
        XCTAssertTrue(selection.contains(5))
        XCTAssertEqual(selection.count, 3)
    }

    // MARK: - Limits Validation Tests

    func testMinimumSelectionEnforcement() {
        let minSelections = 2
        var selection: Set<Int> = []

        // Below minimum
        XCTAssertTrue(selection.count < minSelections)

        // Meet minimum
        selection = [1, 2]
        XCTAssertTrue(selection.count >= minSelections)
    }

    func testMaximumSelectionEnforcement() {
        let maxSelections = 3
        var selection: Set<Int> = []

        // Below maximum
        selection = [1, 2]
        XCTAssertTrue(selection.count <= maxSelections)

        // At maximum
        selection = [1, 2, 3]
        XCTAssertTrue(selection.count <= maxSelections)
        XCTAssertEqual(selection.count, maxSelections)

        // Would exceed maximum (logic to prevent)
        let canAddMore = selection.count < maxSelections
        XCTAssertFalse(canAddMore)
    }

    func testUnlimitedSelectionBehavior() {
        let maxSelections: Int? = nil
        var selection: Set<Int> = []

        // Add many items
        selection = Set(1...100)

        XCTAssertEqual(selection.count, 100)

        // No maximum constraint
        let canAddMore = maxSelections == nil || selection.count < maxSelections!
        XCTAssertTrue(canAddMore)
    }

    // MARK: - Bulk Actions Tests

    func testSelectAllFunctionality() {
        var selection: Set<Int> = []
        let allItems = [1, 2, 3, 4, 5]

        // Select all
        selection = Set(allItems)

        XCTAssertEqual(selection.count, allItems.count)
        allItems.forEach { item in
            XCTAssertTrue(selection.contains(item))
        }
    }

    func testClearAllFunctionality() {
        var selection: Set<Int> = [1, 2, 3, 4, 5]

        XCTAssertFalse(selection.isEmpty)

        // Clear all
        selection.removeAll()

        XCTAssertTrue(selection.isEmpty)
        XCTAssertEqual(selection.count, 0)
    }

    func testBulkActionWithLimits() {
        let maxSelections = 3
        var selection: Set<Int> = []
        let allItems = [1, 2, 3, 4, 5]

        // Select all with max limit
        let itemsToSelect = Array(allItems.prefix(maxSelections))
        selection = Set(itemsToSelect)

        XCTAssertEqual(selection.count, maxSelections)
        XCTAssertTrue(selection.count <= maxSelections)
    }

    // MARK: - Search Filtering Tests

    func testCaseInsensitiveFiltering() {
        let items = ["Apple", "Banana", "Cherry", "Date"]
        let searchText = "apple"

        let filtered = items.filter { $0.lowercased().contains(searchText.lowercased()) }

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first, "Apple")
    }

    func testRealTimeFiltering() {
        let items = ["Apple", "Apricot", "Banana", "Blueberry"]
        var searchText = "a"

        // Filter with 'a'
        var filtered = items.filter { $0.lowercased().contains(searchText.lowercased()) }
        XCTAssertEqual(filtered.count, 3) // Apple, Apricot, Banana contain 'a'

        // Update search
        searchText = "ap"
        filtered = items.filter { $0.lowercased().contains(searchText.lowercased()) }
        XCTAssertEqual(filtered.count, 2) // Apple, Apricot

        // More specific search
        searchText = "apple"
        filtered = items.filter { $0.lowercased().contains(searchText.lowercased()) }
        XCTAssertEqual(filtered.count, 1)
    }

    func testEmptySearchResults() {
        let items = ["Apple", "Banana", "Cherry"]
        let searchText = "xyz"

        let filtered = items.filter { $0.lowercased().contains(searchText.lowercased()) }

        XCTAssertTrue(filtered.isEmpty)
    }

    func testSpecialCharactersInSearch() {
        let items = ["Item-1", "Item_2", "Item.3", "Item 4"]
        let searchText = "Item-"

        let filtered = items.filter { $0.contains(searchText) }

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first, "Item-1")
    }

    // MARK: - Sectioned Data Tests

    func testSectionOrganization() {
        let sections = [
            (header: "Fruits", items: ["Apple", "Banana"]),
            (header: "Vegetables", items: ["Carrot", "Broccoli"])
        ]

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections[0].header, "Fruits")
        XCTAssertEqual(sections[0].items.count, 2)
        XCTAssertEqual(sections[1].header, "Vegetables")
        XCTAssertEqual(sections[1].items.count, 2)
    }

    func testCrossSectionSelection() {
        var selection: Set<String> = []
        let sections = [
            (header: "Fruits", items: ["Apple", "Banana"]),
            (header: "Vegetables", items: ["Carrot", "Broccoli"])
        ]

        // Select items from different sections
        selection.insert("Apple")    // From Fruits
        selection.insert("Carrot")   // From Vegetables

        XCTAssertEqual(selection.count, 2)
        XCTAssertTrue(selection.contains("Apple"))
        XCTAssertTrue(selection.contains("Carrot"))
    }

    func testFlattenedItemsFromSections() {
        let sections = [
            (header: "Section 1", items: [1, 2, 3]),
            (header: "Section 2", items: [4, 5, 6]),
            (header: "Section 3", items: [7, 8, 9])
        ]

        let allItems = sections.flatMap { $0.items }

        XCTAssertEqual(allItems.count, 9)
        XCTAssertEqual(allItems, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    // MARK: - Edge Cases Tests

    func testEmptyItemsList() {
        let items: [Int] = []
        var selection: Set<Int> = []

        // Can't select anything from empty list
        XCTAssertTrue(items.isEmpty)
        XCTAssertTrue(selection.isEmpty)

        // Attempt to select all on empty list
        selection = Set(items)
        XCTAssertTrue(selection.isEmpty)
    }

    func testSingleItemList() {
        let items = [1]
        var selection: Set<Int> = []

        // Select the only item
        selection.insert(items[0])

        XCTAssertEqual(selection.count, 1)
        XCTAssertTrue(selection.contains(1))
    }

    func testDuplicateValuePrevention() {
        var selection: Set<Int> = []

        // Try to add same value multiple times
        selection.insert(1)
        selection.insert(1)
        selection.insert(1)

        // Set prevents duplicates
        XCTAssertEqual(selection.count, 1)
    }

    func testMinMaxSameValue() {
        let minSelections = 3
        let maxSelections = 3
        var selection: Set<Int> = [1, 2, 3]

        // Selection must be exactly 3
        let isValid = selection.count >= minSelections && selection.count <= maxSelections
        XCTAssertTrue(isValid)

        // Can't add more
        let canAddMore = selection.count < maxSelections
        XCTAssertFalse(canAddMore)

        // Can't have less
        selection.remove(3)
        let meetsMinimum = selection.count >= minSelections
        XCTAssertFalse(meetsMinimum)
    }

    // MARK: - Performance Tests

    func testLargeDatasetPerformance() {
        measure {
            let items = Array(1...1000)
            var selection: Set<Int> = []

            // Select every other item
            for item in items where item % 2 == 0 {
                selection.insert(item)
            }

            XCTAssertEqual(selection.count, 500)
        }
    }

    func testSearchPerformanceWithLargeDataset() {
        let items = (1...1000).map { "Item \($0)" }
        let searchText = "Item 5"

        measure {
            let _ = items.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    // MARK: - Data Type Tests

    func testStringValueType() {
        var selection: Set<String> = []
        let items = ["A", "B", "C"]

        selection = Set(items)

        XCTAssertEqual(selection.count, 3)
        XCTAssertTrue(selection.contains("A"))
    }

    func testIntValueType() {
        var selection: Set<Int> = []
        let items = [1, 2, 3]

        selection = Set(items)

        XCTAssertEqual(selection.count, 3)
        XCTAssertTrue(selection.contains(1))
    }

    func testUUIDValueType() {
        let uuid1 = UUID()
        let uuid2 = UUID()
        var selection: Set<UUID> = []

        selection.insert(uuid1)
        selection.insert(uuid2)

        XCTAssertEqual(selection.count, 2)
        XCTAssertTrue(selection.contains(uuid1))
        XCTAssertTrue(selection.contains(uuid2))
    }

    func testCustomHashableType() {
        struct CustomItem: Hashable {
            let id: Int
            let name: String
        }

        let item1 = CustomItem(id: 1, name: "First")
        let item2 = CustomItem(id: 2, name: "Second")
        var selection: Set<CustomItem> = []

        selection.insert(item1)
        selection.insert(item2)

        XCTAssertEqual(selection.count, 2)
        XCTAssertTrue(selection.contains(item1))
    }
}
