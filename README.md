# SwiftlyUI

A collection of reusable SwiftUI components designed for modern iOS, macOS, tvOS, and watchOS applications.

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016%2B%20%7C%20macOS%2013%2B%20%7C%20tvOS%2016%2B%20%7C%20watchOS%209%2B-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Features

SwiftlyUI provides a comprehensive set of customizable components that integrate seamlessly with your SwiftUI applications:

- **🎯 Multi-Selection Pickers** - Flexible pickers with search, sections, and multiple presentation styles
- **🏷️ Token & Tag Fields** - Powerful tag input with auto-completion and user selection with avatars
- **📐 Layout Components** - Adaptive flow layouts and token displays with overflow handling
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
    @State private var selection: Set<String> = []

    var body: some View {
        Form {
            MultiPicker("Choose Options", selection: $selection) {
                Text("Option 1").multiPickerTag("opt1")
                Text("Option 2").multiPickerTag("opt2")
                Text("Option 3").multiPickerTag("opt3")
            }
            .multiPickerStyle(.menu)
        }
    }
}
```

## 🧩 Components

### Multi-Selection Pickers

Comprehensive multi-selection system with three specialized variants:

| Component | Best For | Documentation |
|-----------|----------|---------------|
| **MultiPicker** | General multi-selection with optional sections | [📖 Docs](docs/MultiPicker.md) |
| **SearchableMultiPicker** | Large lists requiring search/filter | [📖 Docs](docs/SearchableMultiPicker.md) |
| **GroupedMultiPicker** | Advanced sectioning with collapsible groups | [📖 Docs](docs/GroupedMultiPicker.md) |

**Quick Example:**
```swift
@State private var selection: Set<String> = []

MultiPicker("Select Items", selection: $selection) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
.multiPickerStyle(.sheet)
```

**Features:**
- 🎨 Multiple styles: inline, navigation, sheet, menu
- 🔍 Built-in search and filtering
- 📁 Section support with headers
- ⚖️ Selection limits (min/max)
- ⚡ Bulk actions (Select All, Clear All)
- 🎯 Type-safe with any Hashable type
- 🪙 Token display with overflow indicators

### Token & Tag Fields

Sophisticated input components for tags and user selection:

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **TokenTagField** | Advanced tag input with auto-completion and inline editing | [📖 Docs](docs/TokenTagField.md) |
| **UserTokenField** | User selection with search, avatars, and multi-mode support | [📖 Docs](docs/UserTokenField.md) |

**Quick Example:**
```swift
@State private var tags: [Tag] = []
@State private var inputText = ""

TokenTagField(
    tags: $tags,
    inputText: $inputText,
    suggestedTags: suggestions,
    onAdd: { tags.append($0) },
    onRemove: { tags.removeAll { $0.id == $1.id } },
    onUpdate: { tag in
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
        }
    }
)
```

**Features:**
- ✅ Tag creation and management
- ✏️ Inline editing (double-tap)
- 🎨 Color customization
- 💡 Smart auto-completion
- ⌨️ Full keyboard support
- 👤 Avatar support (Image, URL, initials)

### Layout Components

Flexible layout utilities for responsive UIs:

| Component | Description | Documentation |
|-----------|-------------|---------------|
| **FlowLayout** | Wraps content into rows like CSS flexbox | [📖 Docs](docs/Layout.md#flowlayout) |
| **AdaptiveTokenLayout** | Displays tokens with "+X" overflow indicator | [📖 Docs](docs/Layout.md#adaptivetokenlayout) |

**Quick Example:**
```swift
FlowLayout(spacing: 8) {
    ForEach(items) { item in
        ChipView(text: item)
    }
}
```

## 📖 Documentation

### Component Documentation

- **[MultiPicker](docs/MultiPicker.md)** - General multi-selection picker with ViewBuilder API
- **[SearchableMultiPicker](docs/SearchableMultiPicker.md)** - Multi-picker with built-in search
- **[GroupedMultiPicker](docs/GroupedMultiPicker.md)** - Advanced sectioning with collapsible groups
- **[TokenTagField](docs/TokenTagField.md)** - Tag input with auto-completion
- **[UserTokenField](docs/UserTokenField.md)** - User selection with avatars
- **[Layout Components](docs/Layout.md)** - FlowLayout and AdaptiveTokenLayout

### Additional Resources

- **[API Documentation](https://yourusername.github.io/SwiftlyUI/documentation/swiftlyui/)**
- **[Migration Guide](docs/migration.md)**
- **[Contributing Guide](CONTRIBUTING.md)**

## 🎨 Styling

All components support customization through standard SwiftUI modifiers and environment values:

```swift
MultiPicker("Options", selection: $selection) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
.multiPickerStyle(.navigationLink)  // Choose presentation style
.font(.body)                         // Customize typography
.tint(.blue)                         // Accent color
```

### Available Picker Styles

- `.inline` - Items displayed directly in the view
- `.navigationLink` - Navigate to a new screen (ideal for iOS)
- `.sheet` - Present in a modal sheet
- `.menu` - Dropdown/popover menu (default on macOS)

## 📱 Demo App

Check out the included demo app to see all components in action:

```bash
git clone https://github.com/yourusername/SwiftlyUI.git
cd SwiftlyUI-DemoApp
open SwiftlyUI-DemoApp.xcodeproj
```

The demo app showcases:
- Multiple usage examples for each component
- Different styling and configuration options
- Interactive examples you can test
- Best practices and integration patterns

## 🛠️ Requirements

- **iOS 16.0+** / **macOS 13.0+** / **tvOS 16.0+** / **watchOS 9.0+**
- **Swift 5.7+**
- **Xcode 14.0+**

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Open in Xcode or your preferred Swift development environment
3. Run tests: `swift test`
4. Build the demo app: `cd SwiftlyUI-DemoApp && open SwiftlyUI-DemoApp.xcodeproj`

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
