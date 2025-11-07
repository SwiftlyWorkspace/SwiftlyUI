# Release Guide for SwiftlyUI

This guide explains how to create a new release of SwiftlyUI with proper semantic versioning.

## Prerequisites

- All changes committed and pushed to `main` branch
- All tests passing
- Documentation updated
- CHANGELOG.md updated (if you have one)

## Creating a Release

### 1. Choose a Version Number

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backwards compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes (backwards compatible)

### 2. Create and Push the Tag

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Create an annotated tag
git tag -a 1.0.0 -m "Release version 1.0.0

- Initial public release
- TokenTagField component
- UserTokenField component
- MultiPicker system (MultiPicker, SearchableMultiPicker, GroupedMultiPicker)
- Layout components (FlowLayout, AdaptiveTokenLayout)
"

# Push the tag to GitHub
git push origin 1.0.0
```

### 3. Create a GitHub Release

1. Go to https://github.com/SwiftlyWorkspace/SwiftlyUI/releases
2. Click "Create a new release"
3. Select the tag you just created (1.0.0)
4. Set the release title: "v1.0.0"
5. Add release notes describing:
   - New features
   - Bug fixes
   - Breaking changes (if any)
   - Migration guide (if needed)
6. Click "Publish release"

### 4. Update the Demo App

Once you've created a release tag, update the DemoApp's Package.swift:

```swift
dependencies: [
    // Switch from branch tracking to semantic versioning:
    .package(url: "https://github.com/SwiftlyWorkspace/SwiftlyUI.git", from: "1.0.0"),
],
```

Then commit and push the DemoApp changes:

```bash
cd /Users/benvanaken/Developer/SwiftlyUI-DemoApp
# Edit Package.swift as shown above
git add Package.swift
git commit -m "Update to use SwiftlyUI v1.0.0"
git push origin main
```

## Example Release Notes Template

```markdown
# SwiftlyUI v1.0.0

Initial public release of SwiftlyUI - A collection of reusable SwiftUI components.

## ✨ Features

### Token & Tag Components
- **TokenTagField**: Advanced tag input with auto-completion and inline editing
- **UserTokenField**: User selection with search, avatars, and multi-mode support

### Multi-Selection Pickers
- **MultiPicker**: General multi-selection with ViewBuilder API
- **SearchableMultiPicker**: Multi-picker with built-in search
- **GroupedMultiPicker**: Multi-picker with sectioned data support
- Multiple styles: inline, navigationLink, sheet, menu
- Selection limits (min/max)
- Bulk actions (Select All, Clear All)

### Layout Components
- **FlowLayout**: Flexible flow layout container
- **AdaptiveTokenLayout**: Token display with overflow indicators

## 📋 Requirements

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 5.7+
- Xcode 14.0+

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftlyWorkspace/SwiftlyUI.git", from: "1.0.0")
]
```

Or add via Xcode: File → Add Package Dependencies

## 📱 Demo App

Try the demo app: https://github.com/SwiftlyWorkspace/SwiftlyUI-DemoApp

## 📖 Documentation

Full documentation available in the [docs](docs/) folder and inline code comments.
```

## Subsequent Releases

For future releases, follow the same process:

1. Make your changes on `main` or feature branches
2. Merge to `main`
3. Create a new tag with incremented version
4. Create GitHub release
5. Update demo app if needed

## Pre-release Versions

For beta or alpha releases:

```bash
git tag -a 1.1.0-beta.1 -m "Beta release for testing"
git push origin 1.1.0-beta.1
```

In Package.swift, users can opt into pre-releases:
```swift
.package(url: "https://github.com/SwiftlyWorkspace/SwiftlyUI.git", from: "1.1.0-beta.1")
```
