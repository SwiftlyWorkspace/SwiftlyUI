# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftlyUI is a Swift Package Manager library providing reusable SwiftUI components for iOS, macOS, tvOS, and watchOS. The project has a companion demo app in `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` that demonstrates usage of the library.

## Development Commands

### Building and Testing
- **Build the package**: `swift build`
- **Run tests**: `swift test`
- **Clean build**: `swift package clean`

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
  - `TokenTagField.swift` - Main component (requires iOS 16+/macOS 13+)
  - `Tag.swift` - Tag data model
  - `TagChip.swift` - Individual tag view
- **`Components/Layout/`** - Layout components
  - `FlowLayout.swift` - Flexible flow layout container
- **`Extensions/`** - SwiftUI extensions
  - `Color+Extensions.swift` - Color utility extensions

### Tests
- **`Tests/SwiftlyUITests/`** - Unit tests for all components

### Demo App (`/Users/benvanaken/Developer/SwiftlyUI-DemoApp`)
- Separate Xcode project demonstrating component usage
- Contains examples and integration patterns

## Platform Requirements

- **Minimum**: iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- **Swift**: 5.7+
- **Advanced Components**: Some components like `TokenTagField` require iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+

## Architecture Notes

This is a Swift Package Manager library following standard SPM conventions. Components are organized by functionality under `Sources/SwiftlyUI/Components/`. The library uses `@available` attributes to provide progressive enhancement - newer components require higher OS versions for advanced features while maintaining backward compatibility where possible.

The main `SwiftlyUI.swift` file serves as the public API entry point and includes comprehensive documentation for all components. Each component is self-contained within its subdirectory and includes its own data models and supporting views.

## Cross-References

- **Demo App**: `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` - Comprehensive demonstration app showing all components in action
- **Demo App CLAUDE.md**: `/Users/benvanaken/Developer/SwiftlyUI-DemoApp/CLAUDE.md` - Development guidance for the demo application