# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftlyUI is a Swift Package Manager library project with Swift 6.2+ requirement. The project has a companion demo app in `/Users/benvanaken/Developer/SwiftlyUI-DemoApp` that demonstrates usage of the library.

## Development Commands

### Building and Testing
- **Build the package**: `swift build`
- **Run tests**: `swift test`
- **Clean build**: `swift package clean`

### Xcode Integration
The demo app can be opened in Xcode via the `.xcodeproj` file at `/Users/benvanaken/Developer/SwiftlyUI-DemoApp/SwiftlyUI-DemoApp.xcodeproj`

## Project Structure

- **Main library**: `Sources/SwiftlyUI/SwiftlyUI.swift` - Core library implementation
- **Package configuration**: `Package.swift` - Swift Package Manager configuration
- **Demo app**: Separate Xcode project at `/Users/benvanaken/Developer/SwiftlyUI-DemoApp`
  - Entry point: `SwiftlyUI_DemoAppApp.swift`
  - Main view: `ContentView.swift`

## Architecture Notes

This is a Swift Package Manager library project following standard SPM conventions. The library is designed to be consumed by SwiftUI applications, as demonstrated by the companion demo app which imports SwiftUI and uses the library.

The project uses Swift 6.2 as the minimum version and follows modern Swift conventions.