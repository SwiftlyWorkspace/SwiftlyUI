# MultiPicker

A versatile multi-selection picker component that allows selecting multiple items from a list with a clean, declarative API.

## Overview

`MultiPicker` provides a SwiftUI Picker-like API for multi-selection scenarios. It supports multiple presentation styles, optional sections, selection constraints, and displays selected items as tokens with an overflow indicator.

### Key Features

- 🎯 **Type-Safe** - Works with any `Hashable` type (String, Int, UUID, custom types)
- 🎨 **Multiple Styles** - Inline, navigation link, sheet, and menu presentations
- 📁 **Section Support** - Optional sections with styled headers
- ⚖️ **Selection Limits** - Set minimum and maximum selection requirements
- ⚡ **Bulk Actions** - Select All and Clear All operations
- ✅ **Confirmation Mode** - Optional Apply/Cancel workflow
- 🪙 **Token Display** - Shows selected items as chips with "+X" overflow
- 📊 **Selection Count** - Always displays count when items are selected

## Basic Usage

### Simple Multi-Selection

```swift
import SwiftUI
import SwiftlyUI

struct FruitPickerView: View {
    @State private var selection: Set<String> = []

    let fruits = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]

    var body: some View {
        Form {
            MultiPicker("Select Fruits", selection: $selection) {
                ForEach(fruits, id: \.self) { fruit in
                    Text(fruit).multiPickerTag(fruit)
                }
            }
        }
    }
}
```

### With Custom Types

```swift
struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String
}

struct ProductPickerView: View {
    @State private var selectedProducts: Set<UUID> = []

    let products: [Product] = [
        Product(id: UUID(), name: "iPhone", category: "Electronics"),
        Product(id: UUID(), name: "MacBook", category: "Electronics"),
        Product(id: UUID(), name: "AirPods", category: "Audio")
    ]

    var body: some View {
        MultiPicker("Select Products", selection: $selectedProducts) {
            ForEach(products) { product in
                HStack {
                    Text(product.name)
                    Spacer()
                    Text(product.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .multiPickerTag(product.id)
            }
        }
        .multiPickerStyle(.sheet)
    }
}
```

## Section Support

Organize items into sections using `MultiPickerSection`:

```swift
struct FoodPickerView: View {
    @State private var selection: Set<String> = []

    let fruits = ["Apple", "Banana", "Cherry"]
    let vegetables = ["Carrot", "Broccoli", "Spinach"]
    let grains = ["Rice", "Wheat", "Oats"]

    var body: some View {
        MultiPicker("Select Foods", selection: $selection) {
            MultiPickerSection("Fruits") {
                ForEach(fruits, id: \.self) { fruit in
                    Text(fruit).multiPickerTag(fruit)
                }
            }

            MultiPickerSection("Vegetables") {
                ForEach(vegetables, id: \.self) { veg in
                    Text(veg).multiPickerTag(veg)
                }
            }

            MultiPickerSection("Grains") {
                ForEach(grains, id: \.self) { grain in
                    Text(grain).multiPickerTag(grain)
                }
            }
        }
        .multiPickerStyle(.menu)
    }
}
```

### Section Headers

Sections automatically render with:
- Semibold, secondary-colored text
- Background color for visual separation
- Proper spacing and padding
- Dividers between sections

## Presentation Styles

### Inline Style

Displays items directly within the view. Best for small lists.

```swift
MultiPicker("Options", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
.multiPickerStyle(.inline)
```

**Use Cases:**
- Forms with few options (≤5 items)
- When you want immediate visibility of all options
- Settings screens with limited choices

### Navigation Link Style

Pushes to a new screen when tapped. Ideal for iOS.

```swift
MultiPicker("Options", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
.multiPickerStyle(.navigationLink)
```

**Use Cases:**
- Longer lists (10+ items)
- When screen space is limited
- iOS apps following navigation patterns

### Sheet Style

Presents items in a modal sheet with a Done button.

```swift
MultiPicker("Options", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
.multiPickerStyle(.sheet)
```

**Use Cases:**
- Focused selection tasks
- When you want modal presentation
- Temporary selections that can be dismissed

### Menu Style (Default on macOS)

Shows items in a popover menu.

```swift
MultiPicker("Options", selection: $selection) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
.multiPickerStyle(.menu)
```

**Use Cases:**
- macOS applications
- Compact UIs with limited space
- Dropdown-style selections

## Selection Constraints

### Minimum Selections

Require at least N items to be selected:

```swift
MultiPicker("Choose Colors", selection: $selection, minSelections: 2) {
    ForEach(colors, id: \.self) { color in
        Text(color).multiPickerTag(color)
    }
}
.multiPickerStyle(.menu)
```

Displays validation message: "Select at least 2 items"

### Maximum Selections

Limit selection to at most N items:

```swift
MultiPicker("Choose Colors", selection: $selection, maxSelections: 3) {
    ForEach(colors, id: \.self) { color in
        Text(color).multiPickerTag(color)
    }
}
.multiPickerStyle(.menu)
```

- Disables unselected items when max is reached
- Displays warning message: "Maximum 3 selections reached"

### Combined Constraints

Require a selection range:

```swift
MultiPicker(
    "Choose 2-4 Colors",
    selection: $selection,
    minSelections: 2,
    maxSelections: 4
) {
    ForEach(colors, id: \.self) { color in
        Text(color).multiPickerTag(color)
    }
}
```

## Bulk Actions

### Select All

```swift
MultiPicker(
    "Choose Items",
    selection: $selection,
    showSelectAll: true
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
```

- Respects `maxSelections` (selects first N items if limit set)
- Disabled when all items are selected
- Disabled when item count exceeds max limit

### Clear All

```swift
MultiPicker(
    "Choose Items",
    selection: $selection,
    showClearAll: true
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
```

- Removes all selected items
- Disabled when selection is empty

### Combined

```swift
MultiPicker(
    "Choose Items",
    selection: $selection,
    showSelectAll: true,
    showClearAll: true
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
```

## Confirmation Mode

Require explicit confirmation before applying changes:

```swift
MultiPicker(
    "Select Interests",
    selection: $selection,
    minSelections: 1,
    maxSelections: 3,
    requiresConfirmation: true
) {
    ForEach(categories, id: \.self) { category in
        Text(category).multiPickerTag(category)
    }
}
```

**Behavior:**
- Changes are not applied until "Apply" is clicked
- "Cancel" button reverts to previous selection
- "Apply" button is disabled until selection meets validation rules
- Validation messages appear in real-time

**Best For:**
- Critical selections that need review
- When you want to prevent accidental changes
- Multi-step forms with explicit submission

## API Reference

### Initializer

```swift
public init(
    _ titleKey: String,
    selection: Binding<Set<SelectionValue>>,
    minSelections: Int = 0,
    maxSelections: Int? = nil,
    showSelectAll: Bool = false,
    showClearAll: Bool = false,
    requiresConfirmation: Bool = false,
    @ViewBuilder content: () -> Content
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `titleKey` | `String` | Required | Title/label for the picker |
| `selection` | `Binding<Set<SelectionValue>>` | Required | Binding to selected values |
| `minSelections` | `Int` | `0` | Minimum required selections |
| `maxSelections` | `Int?` | `nil` | Maximum allowed selections (nil = unlimited) |
| `showSelectAll` | `Bool` | `false` | Show "Select All" button |
| `showClearAll` | `Bool` | `false` | Show "Clear All" button |
| `requiresConfirmation` | `Bool` | `false` | Require Apply/Cancel confirmation |
| `content` | `@ViewBuilder` | Required | Items with `.multiPickerTag()` modifiers |

### View Modifiers

```swift
// Set presentation style
.multiPickerStyle(.inline)
.multiPickerStyle(.navigationLink)
.multiPickerStyle(.sheet)
.multiPickerStyle(.menu)

// Standard SwiftUI modifiers also work
.font(.body)
.tint(.blue)
.disabled(isProcessing)
```

## Complete Examples

### Settings Screen

```swift
struct NotificationSettingsView: View {
    @State private var enabledChannels: Set<NotificationChannel> = []

    var body: some View {
        Form {
            Section("Notification Channels") {
                MultiPicker(
                    "Select Channels",
                    selection: $enabledChannels,
                    minSelections: 1
                ) {
                    ForEach(NotificationChannel.allCases) { channel in
                        HStack {
                            Image(systemName: channel.icon)
                            Text(channel.name)
                        }
                        .multiPickerTag(channel)
                    }
                }
                .multiPickerStyle(.inline)
            }

            Section {
                Text("You'll receive notifications through \(enabledChannels.count) channel(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
    }
}

enum NotificationChannel: String, CaseIterable, Identifiable, Hashable {
    case email, push, sms, slack

    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .email: return "envelope.fill"
        case .push: return "bell.fill"
        case .sms: return "message.fill"
        case .slack: return "bubble.left.fill"
        }
    }
}
```

### Data Filter

```swift
struct DataFilterView: View {
    @State private var selectedCategories: Set<String> = []
    @State private var selectedStatuses: Set<String> = []

    let categories = ["Technology", "Business", "Health", "Education"]
    let statuses = ["Active", "Pending", "Completed", "Archived"]

    var body: some View {
        Form {
            Section("Filters") {
                MultiPicker("Categories", selection: $selectedCategories) {
                    MultiPickerSection("Categories") {
                        ForEach(categories, id: \.self) { category in
                            Text(category).multiPickerTag(category)
                        }
                    }

                    MultiPickerSection("Status") {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).multiPickerTag(status)
                        }
                    }
                }
                .multiPickerStyle(.sheet)
            }

            Section {
                Button("Apply Filters") {
                    applyFilters()
                }
                .disabled(selectedCategories.isEmpty && selectedStatuses.isEmpty)
            }
        }
    }

    func applyFilters() {
        // Apply filtering logic
    }
}
```

### Survey Question

```swift
struct SurveyQuestionView: View {
    @State private var selectedOptions: Set<String> = []

    let question = "What features interest you most?"
    let options = [
        "Cloud Sync", "Offline Mode", "Collaboration",
        "Analytics", "API Access", "Custom Themes"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.headline)

            MultiPicker(
                "Select all that apply",
                selection: $selectedOptions,
                minSelections: 1,
                maxSelections: 3,
                showSelectAll: false,
                showClearAll: true,
                requiresConfirmation: true
            ) {
                ForEach(options, id: \.self) { option in
                    Text(option).multiPickerTag(option)
                }
            }
            .multiPickerStyle(.inline)

            Button("Submit Response") {
                submitSurvey()
            }
            .disabled(selectedOptions.count < 1 || selectedOptions.count > 3)
        }
        .padding()
    }

    func submitSurvey() {
        // Submit survey response
    }
}
```

## Best Practices

### Choosing a Style

- **Inline** - Use for 3-7 items when space allows
- **NavigationLink** - Use for 8+ items on iOS
- **Sheet** - Use for focused tasks or modal contexts
- **Menu** - Use on macOS or when space is very limited

### Selection Limits

- Always validate `minSelections` matches your business logic
- Set `maxSelections` when there's a technical or UX constraint
- Show clear validation messages by setting appropriate limits
- Consider `requiresConfirmation: true` for important selections

### Performance

- For lists with 100+ items, consider using `SearchableMultiPicker` instead
- Use `id: \.self` only for simple types (String, Int)
- For custom types, always implement `Identifiable` properly

### Accessibility

- Use clear, descriptive titles
- Provide meaningful labels for each item
- Validation messages are automatically announced to screen readers
- All styles support keyboard navigation

### Sections

- Use sections when you have natural groupings
- Keep section names concise (1-2 words)
- For advanced sectioning features (collapsible, counts), use `GroupedMultiPicker`
- Limit to 5-7 sections for best UX

## Migration from Array-Based API

If you're migrating from the old array-based API:

**Before:**
```swift
MultiPicker(
    title: "Options",
    items: [(value: 1, label: "One"), (value: 2, label: "Two")],
    selection: $selection
)
```

**After:**
```swift
MultiPicker("Options", selection: $selection) {
    Text("One").multiPickerTag(1)
    Text("Two").multiPickerTag(2)
}
```

## Related Components

- **[SearchableMultiPicker](SearchableMultiPicker.md)** - For large lists requiring search
- **[GroupedMultiPicker](GroupedMultiPicker.md)** - For advanced sectioning (collapsible, counts)

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## See Also

- [MultiPickerStyle Protocol](https://developer.apple.com/documentation/)
- [SwiftUI Picker](https://developer.apple.com/documentation/swiftui/picker)
