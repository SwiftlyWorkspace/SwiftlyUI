import XCTest
@testable import SwiftlyUI
import SwiftUI

final class SwiftlyUITests: XCTestCase {

    // MARK: - Tag Tests

    func testTagCreation() {
        let tag = Tag(name: "Swift", color: .blue)

        XCTAssertEqual(tag.name, "Swift")
        XCTAssertEqual(tag.color, .blue)
        XCTAssertNotNil(tag.id)
    }

    func testTagRandomColor() {
        let color = Tag.randomColor()
        XCTAssertTrue(Tag.availableColors.contains(color))
    }

    func testTagWithRandomColor() {
        let tag = Tag.withRandomColor(name: "Test")

        XCTAssertEqual(tag.name, "Test")
        XCTAssertTrue(Tag.availableColors.contains(tag.color))
    }

    func testTagEquality() {
        let id = UUID()
        let tag1 = Tag(id: id, name: "Swift", color: .blue)
        let tag2 = Tag(id: id, name: "Swift", color: .blue)
        let tag3 = Tag(name: "Swift", color: .blue) // Different ID

        XCTAssertEqual(tag1, tag2)
        XCTAssertNotEqual(tag1, tag3)
    }

    func testTagHashable() {
        let tag1 = Tag(name: "Swift", color: .blue)
        let tag2 = Tag(name: "SwiftUI", color: .green)

        let tagSet: Set<Tag> = [tag1, tag2]
        XCTAssertEqual(tagSet.count, 2)
    }

    // MARK: - Color Name Tests

    func testColorNames() {
        XCTAssertEqual(Tag.colorName(for: .blue), "Blue")
        XCTAssertEqual(Tag.colorName(for: .green), "Green")
        XCTAssertEqual(Tag.colorName(for: .red), "Red")
        XCTAssertEqual(Tag.colorName(for: .purple), "Purple")
        XCTAssertEqual(Tag.colorName(for: .orange), "Orange")
        XCTAssertEqual(Tag.colorName(for: .pink), "Pink")
        XCTAssertEqual(Tag.colorName(for: .yellow), "Yellow")
        XCTAssertEqual(Tag.colorName(for: .indigo), "Indigo")
        XCTAssertEqual(Tag.colorName(for: .teal), "Teal")
        XCTAssertEqual(Tag.colorName(for: .cyan), "Cyan")
        XCTAssertEqual(Tag.colorName(for: .black), "Custom")
    }

    // MARK: - Available Colors Tests

    func testAvailableColors() {
        let expectedColors: [Color] = [
            .blue, .green, .red, .purple, .orange,
            .pink, .yellow, .indigo, .teal, .cyan
        ]

        XCTAssertEqual(Tag.availableColors.count, expectedColors.count)

        for color in expectedColors {
            XCTAssertTrue(Tag.availableColors.contains(color))
        }
    }
}