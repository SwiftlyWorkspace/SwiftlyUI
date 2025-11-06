# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ CRITICAL RULES - READ FIRST

**NEVER KILL XCODE**: Do NOT use `killall Xcode` or any command that terminates Xcode. This is extremely disruptive to the developer's workflow. If Xcode needs to reload something, ask the user to do it manually or suggest they restart Xcode themselves. This rule is non-negotiable.

## Project Overview

SwiftlyUI is a Swift Package Manager library providing reusable SwiftUI components for iOS, macOS, tvOS, and watchOS. The project has a companion demo app in `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` that demonstrates usage of the library.

## Development Commands

### Building and Testing
- **Build the package**: `swift build`
- **Run tests**: `swift test`
- **Run specific test**: `swift test --filter <TestClassName>.<testMethodName>`
- **Clean build**: `swift package clean`

**Note**: Package.swift files are only evaluated by Swift Package Manager and should never be compiled as regular Swift code. If working with Xcode projects that also use SPM, ensure Package.swift is not added to the "Compile Sources" build phase.

### Demo App Development
The demo app is located at `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` and can be opened in Xcode via the `SwiftlyUI-DemoApp.xcodeproj` file. To build the demo app:
```bash
cd /Users/benvanaken/Developer/SwiftlyUI-DemoApp
swift build
```

## Project Structure

### Core Library (`Sources/SwiftlyUI/`)
- **`SwiftlyUI.swift`** - Main module file with documentation and re-exports
- **`Components/TokenTagField/`** - Token tag input component
  - `TokenTagField.swift` - Main component with auto-completion, inline editing, and keyboard navigation
  - `Tag.swift` - Tag data model (Identifiable, Hashable, Sendable) with predefined colors and helper methods
  - `TagChip.swift` - Individual tag view with edit/remove capabilities
- **`Components/UserTokenField/`** - User selection component
  - `UserTokenField.swift` - Search-based user selection with avatar display and auto-completion
  - `SwiftlyUIUser.swift` - Concrete user implementation for convenience (with optional firstName/lastName)
  - `UserRepresentable.swift` - Protocol for custom user types with computed displayName, initials, and avatarColor
  - `UserChip.swift` - Individual user chip with avatar (Image/URL/initials fallback) and remove button
- **`Components/MultiPicker/`** - Multi-selection picker system (iOS 16.0+ / macOS 13.0+)
  - `MultiPicker.swift` - Base multi-selection picker component with tuple-based API
  - `SearchableMultiPicker.swift` - Multi-picker with built-in search/filter functionality
  - `GroupedMultiPicker.swift` - Multi-picker with section/category support
  - `MultiPickerStyle.swift` - Style protocol and built-in styles (inline, navigationLink, sheet, menu)
  - `Internal/` - Internal supporting views (checkbox, row, NSMenuPresenter for macOS native menus)
- **`Components/Layout/`** - Layout components
  - `FlowLayout.swift` - Flexible flow layout container that wraps views into rows
  - `AdaptiveTokenLayout.swift` - Token/chip layout with overflow indicator (used in MultiPicker labels)
- **`Extensions/`** - SwiftUI extensions
  - `Color+Extensions.swift` - Cross-platform color utilities (controlBackground, textBackground, separator, adaptive light/dark mode colors)

### Tests
- **`Tests/SwiftlyUITests/`** - Unit tests for all components

### Demo App (`/Users/benvanaken/Developer/SwiftlyUI-DemoApp`)
- Separate Xcode project demonstrating component usage
- Contains examples and integration patterns

## Platform Requirements

- **Package Minimum**: iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+ (as defined in Package.swift)
- **Swift**: 5.7+
- **Note**: Individual components may use `@available` attributes for specific OS versions:
  - MultiPicker system requires iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
  - TokenTagField and UserTokenField work on iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+

## Architecture Notes

This is a Swift Package Manager library following standard SPM conventions. Key architectural patterns:

- **Component Organization**: Components are organized by functionality under `Sources/SwiftlyUI/Components/`, with each component in its own subdirectory containing all related files (models, views, helpers)
- **Public API Entry Point**: The main `SwiftlyUI.swift` file serves as the public API entry point and includes comprehensive documentation for all components
- **Platform Compatibility**: Cross-platform support is achieved through conditional compilation (`#if canImport(UIKit)` / `#if canImport(AppKit)`) in extensions
- **Progressive Enhancement**: Components use `@available` attributes to provide newer features on supported platforms while maintaining backward compatibility
- **Data Models**: Models like `Tag` and `SwiftlyUIUser` conform to `Identifiable`, `Hashable`, and `Sendable` for proper SwiftUI integration and concurrency support
- **Protocol-Oriented Design**: Components like `UserTokenField` use protocols (e.g., `UserRepresentable`) to work with custom types, providing flexibility while maintaining type safety
- **Avatar Handling**: User components support three avatar modes with automatic fallback: SwiftUI Image → URL-based async loading → colored initials
- **MultiPicker Style System**: Uses a protocol-based style system similar to SwiftUI's native pickers, with four built-in styles (inline, navigationLink, sheet, menu) and platform-specific defaults (menu on macOS, inline elsewhere)
- **Type-Safe Multi-Selection**: MultiPicker system works with any Hashable type (Int, String, UUID, custom types) using Set<SelectionValue> for selections
- **Testing Structure**: Unit tests in `Tests/SwiftlyUITests/` focus on data models and logic; view components are tested via manual testing in the demo app

## Component Development Guidelines

When adding new components, follow these patterns (detailed in CONTRIBUTING.md):

1. **File Structure**: Create component in `Sources/SwiftlyUI/Components/<ComponentName>/` with supporting files
2. **Availability Attributes**: Use `@available` attributes matching platform requirements
3. **Documentation**: Include comprehensive doc comments with examples for all public APIs
4. **Code Organization**: Use `// MARK:` comments to organize Properties, Initializers, Body, Private Methods
5. **Testing**: Add unit tests in `Tests/SwiftlyUITests/` focusing on data models and logic
6. **Public API**: Update `SwiftlyUI.swift` if adding new re-exports
7. **Demo Integration**: Add usage examples in the demo app at `/Users/benvanaken/Developer/SwiftlyUI-DemoApp`
8. **Preview**: Include `#Preview` block for component development

## Cross-References

- **Demo App**: `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` - Comprehensive demonstration app showing all components in action
- **Demo App CLAUDE.md**: `/Users/benvanaken/Developer/SwiftlyUI-DemoApp/CLAUDE.md` - Development guidance for the demo application
- **CONTRIBUTING.md**: Detailed contribution guidelines including component templates and code style