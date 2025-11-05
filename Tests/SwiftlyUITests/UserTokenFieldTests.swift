import XCTest
import SwiftUI
@testable import SwiftlyUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class UserTokenFieldTests: XCTestCase {
    // MARK: - SwiftlyUIUser Creation Tests

    func testUserCreation() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )

        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.email, "john@example.com")
        XCTAssertNil(user.avatarURL)
        XCTAssertNil(user.avatarImage)
    }

    func testUserCreationWithAvatar() {
        let avatarURL = URL(string: "https://example.com/avatar.jpg")
        let user = SwiftlyUIUser(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com",
            avatarURL: avatarURL
        )

        XCTAssertEqual(user.avatarURL, avatarURL)
    }

    func testUserCreationWithCustomID() {
        let customID = UUID()
        let user = SwiftlyUIUser(
            id: customID,
            firstName: "Bob",
            lastName: "Johnson",
            email: "bob@example.com"
        )

        XCTAssertEqual(user.id, customID)
    }

    // MARK: - Initials Generation Tests

    func testInitialsGeneration() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )

        XCTAssertEqual(user.initials, "JD")
    }

    func testInitialsWithLowercase() {
        let user = SwiftlyUIUser(
            firstName: "jane",
            lastName: "smith",
            email: "jane@example.com"
        )

        XCTAssertEqual(user.initials, "JS")
    }

    func testInitialsWithEmptyFirstName() {
        let user = SwiftlyUIUser(
            firstName: "",
            lastName: "Doe",
            email: "doe@example.com"
        )

        XCTAssertEqual(user.initials, "D")
    }

    func testInitialsWithEmptyLastName() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "",
            email: "john@example.com"
        )

        XCTAssertEqual(user.initials, "J")
    }

    func testInitialsWithEmptyNames() {
        let user = SwiftlyUIUser(
            firstName: "",
            lastName: "",
            email: "anonymous@example.com"
        )

        XCTAssertEqual(user.initials, "?")
    }

    func testInitialsWithSingleCharacterNames() {
        let user = SwiftlyUIUser(
            firstName: "A",
            lastName: "B",
            email: "ab@example.com"
        )

        XCTAssertEqual(user.initials, "AB")
    }

    func testInitialsWithSpecialCharacters() {
        let user = SwiftlyUIUser(
            firstName: "José",
            lastName: "García",
            email: "jose@example.com"
        )

        XCTAssertEqual(user.initials, "JG")
    }

    func testInitialsWithSpaces() {
        let user = SwiftlyUIUser(
            firstName: " John ",
            lastName: " Doe ",
            email: "john@example.com"
        )

        // Should still extract first character regardless of leading spaces
        XCTAssertFalse(user.initials.isEmpty)
    }

    // MARK: - Display Name Tests

    func testDisplayName() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )

        XCTAssertEqual(user.displayName, "John Doe")
    }

    func testDisplayNameWithWhitespace() {
        let user = SwiftlyUIUser(
            firstName: " John ",
            lastName: " Doe ",
            email: "john@example.com"
        )

        XCTAssertEqual(user.displayName, "John   Doe")
    }

    func testDisplayNameWithEmptyLastName() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "",
            email: "john@example.com"
        )

        XCTAssertEqual(user.displayName, "John")
    }

    func testDisplayNameWithEmptyFirstName() {
        let user = SwiftlyUIUser(
            firstName: "",
            lastName: "Doe",
            email: "john@example.com"
        )

        XCTAssertEqual(user.displayName, "Doe")
    }

    func testDisplayNameWithEmptyNames() {
        let user = SwiftlyUIUser(
            firstName: "",
            lastName: "",
            email: "anonymous@example.com"
        )

        XCTAssertEqual(user.displayName, "")
    }

    // MARK: - Equality Tests

    func testUserEquality() {
        let id = UUID()
        let user1 = SwiftlyUIUser(
            id: id,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        let user2 = SwiftlyUIUser(
            id: id,
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com"
        )

        XCTAssertEqual(user1, user2, "Users with same ID should be equal")
    }

    func testUserInequality() {
        let user1 = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        let user2 = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )

        XCTAssertNotEqual(user1, user2, "Users with different IDs should not be equal")
    }

    // MARK: - Hashable Tests

    func testUserHashability() {
        let user1 = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        let user2 = SwiftlyUIUser(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com"
        )

        var set = Set<SwiftlyUIUser>()
        set.insert(user1)
        set.insert(user2)

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(user1))
        XCTAssertTrue(set.contains(user2))
    }

    func testUserHashConsistency() {
        let id = UUID()
        let user1 = SwiftlyUIUser(
            id: id,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        let user2 = SwiftlyUIUser(
            id: id,
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com"
        )

        XCTAssertEqual(user1.hashValue, user2.hashValue, "Users with same ID should have same hash")
    }

    // MARK: - Avatar Color Tests

    func testAvatarColorConsistency() {
        let id = UUID()
        let user1 = SwiftlyUIUser(
            id: id,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        let user2 = SwiftlyUIUser(
            id: id,
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@example.com"
        )

        // Same ID should produce same color
        XCTAssertEqual(user1.avatarColor, user2.avatarColor)
    }

    func testAvatarColorDeterministic() {
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )

        // Calling avatarColor multiple times should return the same value
        let color1 = user.avatarColor
        let color2 = user.avatarColor
        let color3 = user.avatarColor

        XCTAssertEqual(color1, color2)
        XCTAssertEqual(color2, color3)
    }

    // MARK: - Custom User Conformance Tests

    func testCustomUserConformance() {
        struct CustomUser: UserRepresentable {
            let id: UUID
            let firstName: String
            let lastName: String
            let email: String
            var avatarURL: URL?
            var avatarImage: Image?
        }

        let customUser = CustomUser(
            id: UUID(),
            firstName: "Custom",
            lastName: "User",
            email: "custom@example.com",
            avatarURL: nil,
            avatarImage: nil
        )

        XCTAssertEqual(customUser.displayName, "Custom User")
        XCTAssertEqual(customUser.initials, "CU")
        XCTAssertNotNil(customUser.avatarColor)
    }

    func testCustomUserWithMinimalProperties() {
        struct MinimalUser: UserRepresentable {
            let id: UUID
            let firstName: String
            let lastName: String
            let email: String
            var avatarURL: URL? { nil }
            var avatarImage: Image? { nil }
        }

        let minimalUser = MinimalUser(
            id: UUID(),
            firstName: "Min",
            lastName: "User",
            email: "min@example.com"
        )

        XCTAssertEqual(minimalUser.firstName, "Min")
        XCTAssertEqual(minimalUser.lastName, "User")
        XCTAssertNil(minimalUser.avatarURL)
        XCTAssertNil(minimalUser.avatarImage)
        XCTAssertEqual(minimalUser.displayName, "Min User")
        XCTAssertEqual(minimalUser.initials, "MU")
    }

    // MARK: - Edge Case Tests

    func testVeryLongNames() {
        let longFirstName = String(repeating: "A", count: 100)
        let longLastName = String(repeating: "B", count: 100)

        let user = SwiftlyUIUser(
            firstName: longFirstName,
            lastName: longLastName,
            email: "test@example.com"
        )

        XCTAssertEqual(user.initials, "AB")
        XCTAssertTrue(user.displayName.count > 100)
    }

    func testUnicodeCharacters() {
        let user = SwiftlyUIUser(
            firstName: "李",
            lastName: "明",
            email: "liming@example.com"
        )

        XCTAssertEqual(user.displayName, "李 明")
        XCTAssertFalse(user.initials.isEmpty)
    }

    func testEmailValidation() {
        // Note: The component doesn't validate email format,
        // but we test that it's stored correctly
        let user = SwiftlyUIUser(
            firstName: "John",
            lastName: "Doe",
            email: "not-an-email"
        )

        XCTAssertEqual(user.email, "not-an-email")
    }
}
