# Changelog

All notable changes to SwiftlyUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2025-12-04

### Added
- **Custom TimelineStatus creation** - TimelineStatus is now extensible via struct-based design
- Public initializer for creating custom timeline statuses with custom colors, icons, and display names
- `builtInStatuses` array for iterating over the 6 predefined statuses
- Comprehensive documentation with custom status examples
- New test coverage for custom status creation, equality, and hashing

### Changed
- **BREAKING:** TimelineStatus is now a struct instead of an enum
- **BREAKING:** Renamed `defaultIcon` property to `icon` for consistency (deprecated accessor provided for migration)
- Convenience methods (`isCompleted`, `isActive`, `isBlocked`) now use equality comparison instead of pattern matching

### Removed
- **BREAKING:** Pattern matching support (switch/case) on TimelineStatus - use if/else or ID-based logic instead
- **BREAKING:** `CaseIterable` conformance - use `builtInStatuses` array instead
- **BREAKING:** `rawValue` property - use `id` property instead

### Migration Guide

#### What Continues Working (No Changes Needed)

Most existing code continues to work unchanged:

```swift
// Static properties unchanged
let item = TimelineItem(date: Date(), title: "Task", status: .completed)

// Property access unchanged
let color = status.color
let name = status.displayName
let icon = status.icon  // (formerly defaultIcon)

// Convenience methods unchanged
if status.isCompleted { ... }

// Equality unchanged
if status == .completed { ... }
```

#### What Needs Migration

**Pattern Matching:**
```swift
// ❌ Old (no longer works)
switch status {
case .pending: print("Pending")
case .completed: print("Done")
}

// ✅ New
if status == .pending {
    print("Pending")
} else if status == .completed {
    print("Done")
}

// ✅ Or use ID-based logic
switch status.id {
case "pending": print("Pending")
case "completed": print("Done")
default: print("Other")
}
```

**Iteration:**
```swift
// ❌ Old (no longer works)
TimelineStatus.allCases.forEach { ... }

// ✅ New
TimelineStatus.builtInStatuses.forEach { ... }
```

#### New Capabilities - Custom Statuses

```swift
// Define custom statuses in your project
extension TimelineStatus {
    static let archived = TimelineStatus(
        id: "archived",
        displayName: "Archived",
        color: .gray,
        icon: "archivebox"
    )

    static let escalated = TimelineStatus(
        id: "escalated",
        displayName: "Escalated",
        color: .red,
        icon: "exclamationmark.3"
    )
}

// Use custom statuses just like built-in ones
let item = TimelineItem(date: Date(), title: "Old Task", status: .archived)

// Add custom categorization
extension TimelineStatus {
    var requiresAttention: Bool {
        self == .escalated || self == .blocked
    }
}
```

## [1.1.1] - Previous Release

See Git history for details.

## [1.1.0] - Previous Release

See Git history for details.

## [1.0.1] - Previous Release

See Git history for details.

## [1.0.0] - Initial Release

See Git history for details.

---

[Unreleased]: https://github.com/Swiftly-Developed/SwiftlyUI/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/Swiftly-Developed/SwiftlyUI/compare/v1.1.1...v2.0.0
[1.1.1]: https://github.com/Swiftly-Developed/SwiftlyUI/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/Swiftly-Developed/SwiftlyUI/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/Swiftly-Developed/SwiftlyUI/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Swiftly-Developed/SwiftlyUI/releases/tag/v1.0.0
