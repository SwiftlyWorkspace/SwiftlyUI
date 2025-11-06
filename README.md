# SwiftlyUI

A collection of reusable SwiftUI components designed for modern iOS, macOS, tvOS, and watchOS applications.

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B%20%7C%20tvOS%2015%2B%20%7C%20watchOS%208%2B-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Features

SwiftlyUI provides a comprehensive set of customizable components that integrate seamlessly with your SwiftUI applications:

- **🏷️ Token Tag Field** - A powerful tag input component with auto-completion and inline editing
- **📱 Cross-Platform** - Works on iOS, macOS, tvOS, and watchOS
- **🎨 Customizable** - Extensive styling and theming options
- **♿ Accessible** - Built with accessibility in mind
- **🧪 Well-Tested** - Comprehensive unit tests and documentation

## 🚀 Quick Start

### Swift Package Manager

Add SwiftlyUI to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourusername/SwiftlyUI.git`
3. Click Add Package

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftlyUI.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import SwiftUI
import SwiftlyUI

struct ContentView: View {
    @State private var tags: [Tag] = []
    @State private var inputText = ""

    let suggestedTags: [Tag] = [
        Tag(name: "Swift", color: .orange),
        Tag(name: "SwiftUI", color: .blue),
        Tag(name: "iOS", color: .green)
    ]

    var body: some View {
        VStack {
            Text("My Tags")
                .font(.title)

            TokenTagField(
                tags: $tags,
                inputText: $inputText,
                suggestedTags: suggestedTags,
                onAdd: { newTag in
                    tags.append(newTag)
                },
                onRemove: { tagToRemove in
                    tags.removeAll { $0.id == tagToRemove.id }
                },
                onUpdate: { updatedTag in
                    if let index = tags.firstIndex(where: { $0.id == updatedTag.id }) {
                        tags[index] = updatedTag
                    }
                }
            )
        }
        .padding()
    }
}
```

## 🏷️ Token Tag Field

The `TokenTagField` is a sophisticated tag input component that provides:

### Key Features

- ✅ **Tag Creation**: Add new tags by typing and pressing Enter
- ✏️ **Inline Editing**: Double-tap any tag to edit its name
- 🎨 **Color Customization**: Choose from 10 predefined colors or set custom colors
- 💡 **Auto-completion**: Smart suggestions based on your input
- ⌨️ **Keyboard Navigation**: Full keyboard support including backspace to delete
- 📏 **Customizable Limits**: Set maximum number of tags and custom styling
- 🔄 **Real-time Updates**: Immediate visual feedback for all interactions

### Advanced Usage

```swift
TokenTagField(
    tags: $tags,
    inputText: $inputText,
    suggestedTags: suggestedTags,
    maxTags: 5,
    placeholder: "Enter skills...",
    onAdd: { newTag in
        // Custom add logic
        tags.append(newTag)
        analytics.track("tag_added", tag: newTag.name)
    },
    onRemove: { tagToRemove in
        // Custom remove logic
        tags.removeAll { $0.id == tagToRemove.id }
        analytics.track("tag_removed", tag: tagToRemove.name)
    },
    onUpdate: { updatedTag in
        // Custom update logic
        if let index = tags.firstIndex(where: { $0.id == updatedTag.id }) {
            tags[index] = updatedTag
            analytics.track("tag_updated", from: tags[index].name, to: updatedTag.name)
        }
    }
)
```

### Tag Model

```swift
public struct Tag: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var color: Color

    public init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}
```

## ☑️ Multi-Picker System

The `MultiPicker` system provides comprehensive multi-selection capabilities with three specialized variants:

### Key Features

- 🎨 **Multiple Presentation Styles** - Inline, navigation, sheet, and menu styles
- 🔍 **Search & Filter** - Built-in search for large datasets
- 📁 **Section Support** - Organize items into collapsible categories
- ⚖️ **Selection Limits** - Set minimum and maximum constraints
- ⚡ **Bulk Actions** - Select All and Clear All operations
- 🎯 **Type-Safe** - Works with any Hashable type (Int, String, UUID, custom)
- 📱 **Cross-Platform** - iOS, macOS, tvOS, and watchOS support

### Basic MultiPicker

```swift
@State private var selection: Set<Int> = []

MultiPicker(
    title: "Choose Options",
    items: [
        (value: 1, label: "Option 1"),
        (value: 2, label: "Option 2"),
        (value: 3, label: "Option 3")
    ],
    selection: $selection,
    minSelections: 1,
    maxSelections: 3
)
.multiPickerStyle(.inline)
```

### SearchableMultiPicker

For large lists with search functionality:

```swift
@State private var selection: Set<String> = []
@State private var searchText = ""

SearchableMultiPicker(
    title: "Select Countries",
    items: countries.map { (value: $0.id, label: $0.name) },
    selection: $selection,
    searchText: $searchText,
    showSelectAll: true,
    showClearAll: true
)
```

### GroupedMultiPicker

For categorized/sectioned data:

```swift
@State private var selection: Set<String> = []

GroupedMultiPicker(
    title: "Select Foods",
    sections: [
        (header: "Fruits", items: [
            (value: "apple", label: "Apple"),
            (value: "banana", label: "Banana")
        ]),
        (header: "Vegetables", items: [
            (value: "carrot", label: "Carrot"),
            (value: "broccoli", label: "Broccoli")
        ])
    ],
    selection: $selection,
    collapsibleSections: true
)
```

### Available Styles

- `.inline` - Items displayed directly in the view
- `.navigationLink` - Navigate to a new screen
- `.sheet` - Present in a modal sheet
- `.menu` - Dropdown menu (ideal for macOS)

## 🧩 Components

### Current Components

| Component | Description | Status |
|-----------|-------------|--------|
| **TokenTagField** | Advanced tag input with auto-completion | ✅ Available |
| **UserTokenField** | User selection with search and avatars | ✅ Available |
| **MultiPicker** | Multi-selection picker with multiple styles | ✅ Available |
| **SearchableMultiPicker** | Multi-picker with search/filter | ✅ Available |
| **GroupedMultiPicker** | Multi-picker with sections/categories | ✅ Available |
| **FlowLayout** | Responsive layout that wraps content | ✅ Available |

### Upcoming Components

| Component | Description | Status |
|-----------|-------------|--------|
| **Rating Control** | Customizable star rating input | 🚧 Planned |
| **Progress Ring** | Animated circular progress indicator | 🚧 Planned |
| **Segmented Picker** | Enhanced segmented control | 🚧 Planned |

## 📱 Demo App

Check out the included demo app to see all components in action:

```bash
git clone https://github.com/yourusername/SwiftlyUI.git
cd SwiftlyUI-DemoApp
swift build
```

The demo app showcases:
- Multiple usage examples for each component
- Different styling and configuration options
- Interactive examples you can test
- Best practices and integration patterns

## 🛠️ Requirements

- **iOS 15.0+** / **macOS 12.0+** / **tvOS 15.0+** / **watchOS 8.0+**
- **Swift 5.7+**
- **Xcode 14.0+**

Some advanced features require newer OS versions:
- FlowLayout requires iOS 16.0+ / macOS 13.0+ for optimal performance
- Older OS versions use compatible fallback implementations

## 📖 Documentation

Comprehensive documentation is available:

- **[API Documentation](https://yourusername.github.io/SwiftlyUI/documentation/swiftlyui/)**
- **[Component Gallery](docs/components.md)**
- **[Migration Guide](docs/migration.md)**
- **[Contributing Guide](CONTRIBUTING.md)**

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Open in Xcode or your preferred Swift development environment
3. Run tests: `swift test`
4. Build the demo app: `cd SwiftlyUI-DemoApp && swift build`

## 📄 License

SwiftlyUI is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 👤 Author

**Ben Van Aken**
- GitHub: [@benvanaken](https://github.com/benvanaken)

## 🙏 Acknowledgments

- Inspired by modern design systems and component libraries
- Built with love for the SwiftUI community
- Thanks to all contributors and beta testers

---

**⭐ If you found SwiftlyUI helpful, please give it a star on GitHub! ⭐**