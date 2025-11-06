# Layout Components

Flexible layout utilities for creating responsive, adaptive user interfaces.

## Overview

SwiftlyUI provides two specialized layout components that work together to create dynamic, responsive UIs:

- **FlowLayout** - Wraps content into rows like CSS flexbox
- **AdaptiveTokenLayout** - Displays tokens with automatic overflow handling

These components are used internally by other SwiftlyUI components and are also available for general use in your applications.

---

# FlowLayout

A layout that arranges subviews in a flowing manner, wrapping to new rows as needed.

## Overview

`FlowLayout` is perfect for displaying collections of items that should wrap to new lines when they exceed the available width. Think of it like CSS flexbox with `flex-wrap: wrap`.

### Key Features

- 🌊 **Automatic Wrapping** - Items flow to new rows when width exceeded
- 📏 **Customizable Spacing** - Control horizontal and vertical spacing
- 🎯 **Efficient Layout** - Uses SwiftUI's Layout protocol (iOS 16+)
- 🔄 **Dynamic** - Automatically adjusts as container size changes
- 📱 **Responsive** - Perfect for tags, chips, badges, and buttons

## Basic Usage

### Simple Example

```swift
import SwiftUI
import SwiftlyUI

struct TagListView: View {
    let tags = ["Swift", "SwiftUI", "iOS", "macOS", "Xcode"]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
```

### With Custom Views

```swift
struct ChipView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(16)
    }
}

struct FlowLayoutExample: View {
    let items = [
        ("Swift", Color.orange),
        ("Python", Color.blue),
        ("JavaScript", Color.yellow),
        ("Rust", Color.red),
        ("Go", Color.cyan)
    ]

    var body: some View {
        FlowLayout(spacing: 12) {
            ForEach(items, id: \.0) { item in
                ChipView(text: item.0, color: item.1)
            }
        }
        .padding()
    }
}
```

## Layout Behavior

### Row Wrapping

Items are laid out left-to-right until the row is full, then wrap to the next row:

```swift
FlowLayout(spacing: 8) {
    // These will wrap based on available width
    ForEach(1...10, id: \.self) { number in
        Text("Item \(number)")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}
```

**Behavior:**
- Calculates each item's size
- Fits as many items as possible per row
- Wraps to new row when item would exceed width
- All rows have consistent vertical spacing

### Spacing

Control spacing between items:

```swift
// Tight spacing (4pt)
FlowLayout(spacing: 4) {
    /* ... */
}

// Default spacing (8pt)
FlowLayout(spacing: 8) {
    /* ... */
}

// Loose spacing (16pt)
FlowLayout(spacing: 16) {
    /* ... */
}
```

**Note:** The same spacing value is used for both horizontal (between items in a row) and vertical (between rows).

## Complete Examples

### Filter Tags

```swift
struct FilterTagsView: View {
    @State private var selectedFilters: Set<String> = []

    let availableFilters = [
        "New", "Popular", "Trending", "Featured",
        "On Sale", "Premium", "Free Shipping", "Bestseller"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Filters")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(availableFilters, id: \.self) { filter in
                    Button {
                        toggleFilter(filter)
                    } label: {
                        HStack(spacing: 4) {
                            Text(filter)
                            if selectedFilters.contains(filter) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedFilters.contains(filter) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundStyle(selectedFilters.contains(filter) ? .white : .primary)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }

    func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
}
```

### Category Pills

```swift
struct CategoryPillsView: View {
    @State private var selectedCategory: String? = nil

    let categories = [
        "All", "Technology", "Design", "Business",
        "Marketing", "Development", "Data Science"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)

            FlowLayout(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    CategoryPill(
                        title: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
        .padding()
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
```

## API Reference

### Initializer

```swift
public init(spacing: CGFloat = 8)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `spacing` | `CGFloat` | `8` | Spacing between items (horizontal and vertical) |

### Usage

```swift
FlowLayout(spacing: 12) {
    // Your views here
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## Best Practices

### Item Sizing

✅ **Do:**
- Use fixed or intrinsic sizing for items
- Keep item sizes consistent when possible
- Test with various container widths

❌ **Don't:**
- Use `.frame(maxWidth: .infinity)` on items
- Mix drastically different item sizes
- Forget to account for padding and spacing

### Performance

- FlowLayout is efficient for up to ~100 items
- For larger lists, consider `LazyVGrid` or `LazyHGrid`
- Avoid heavy computation in item views

---

# AdaptiveTokenLayout

A layout that displays items as tokens/chips, fitting as many as possible on a single line and showing a "+X" indicator for remaining items.

## Overview

`AdaptiveTokenLayout` is specifically designed for showing selected items in a compact, single-line format. It automatically calculates how many items fit and shows an overflow indicator for the rest.

### Key Features

- 🪙 **Token Display** - Shows items as colored chips/tokens
- 📊 **Overflow Indicator** - "+X" badge for items that don't fit
- 📏 **Width-Aware** - Dynamically adjusts to available space
- 🔄 **Automatic Calculation** - Real-time adjustment as width changes
- 🎨 **Styled Chips** - Consistent visual design
- 📍 **Placeholder Support** - Shows message when empty

## Basic Usage

### Simple Example

```swift
import SwiftUI
import SwiftlyUI

struct SelectedItemsView: View {
    let selectedItems = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]

    var body: some View {
        AdaptiveTokenLayout(
            items: selectedItems,
            placeholder: "No items selected"
        )
        .frame(width: 300)
    }
}
```

### With Dynamic Selection

```swift
struct DynamicSelectionView: View {
    @State private var selected: [String] = []

    let options = ["Swift", "Python", "JavaScript", "Rust", "Go", "Ruby"]

    var body: some View {
        VStack(spacing: 16) {
            // Token display
            AdaptiveTokenLayout(
                items: selected,
                placeholder: "Select languages"
            )

            // Selection buttons
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        if selected.contains(option) {
                            selected.removeAll { $0 == option }
                        } else {
                            selected.append(option)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
```

## Token Display

### Visual Style

Tokens are displayed with:
- **Blue background** (15% opacity)
- **Blue text**
- **Capsule shape**
- **6px horizontal padding**
- **Consistent spacing** (6px between tokens)

### Overflow Indicator

When items don't fit:
```
[Apple] [Banana] +3
```

The "+X" indicator shows:
- **Gray background** (15% opacity)
- **Secondary text color**
- **Number of hidden items**
- **Capsule shape** matching tokens

## Layout Behavior

### Width Calculation

The component:
1. Measures available width
2. Estimates each token's width
3. Fits as many tokens as possible
4. Shows "+X" for remaining items

### Responsive Adjustment

Automatically recalculates when:
- Container width changes
- Items array changes
- Parent view is resized

### Edge Cases

```swift
// Empty - shows placeholder
AdaptiveTokenLayout(items: [], placeholder: "Select items")
// Output: "Select items" (secondary text)

// Single item - always shows (no overflow)
AdaptiveTokenLayout(items: ["Apple"], placeholder: "Select")
// Output: [Apple]

// Many items in narrow space
AdaptiveTokenLayout(items: ["A", "B", "C", "D"], placeholder: "")
    .frame(width: 100)
// Output: [A] +3 (or similar depending on width)
```

## Complete Examples

### Form Field

```swift
struct PreferencesFormView: View {
    @State private var selectedPreferences: [String] = ["Email", "Push"]

    var body: some View {
        Form {
            Section("Notification Preferences") {
                LabeledContent("Enabled Channels") {
                    AdaptiveTokenLayout(
                        items: selectedPreferences,
                        placeholder: "None selected"
                    )
                }

                // Edit button or navigation
            }
        }
    }
}
```

### Filter Summary

```swift
struct FilterSummaryView: View {
    @State private var activeFilters: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active Filters:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if !activeFilters.isEmpty {
                    Button("Clear All") {
                        activeFilters = []
                    }
                    .font(.caption)
                }
            }

            AdaptiveTokenLayout(
                items: activeFilters,
                placeholder: "No filters applied"
            )
            .frame(height: 20)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### Selection Preview

```swift
struct SelectionPreviewView: View {
    @Binding var selection: Set<String>

    var sortedSelection: [String] {
        Array(selection).sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Selected:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(selection.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            AdaptiveTokenLayout(
                items: sortedSelection,
                placeholder: "Nothing selected"
            )
        }
    }
}
```

## API Reference

### Initializer

```swift
public init(
    items: [String],
    placeholder: String = "Select items"
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `items` | `[String]` | Required | Array of items to display as tokens |
| `placeholder` | `String` | `"Select items"` | Text shown when items array is empty |

### Built-in Height

The component has a fixed height of **20 points** to ensure consistent sizing:

```swift
AdaptiveTokenLayout(items: items, placeholder: "Select")
    .frame(height: 20)  // Already applied internally
```

## Best Practices

### Usage Context

✅ **Use AdaptiveTokenLayout when:**
- Showing selected items in forms
- Displaying active filters
- Preview of multi-selection
- Space is limited (single line)

❌ **Use FlowLayout instead when:**
- Items should wrap to multiple lines
- You need full list visibility
- Space is not a constraint

### Item Naming

```swift
// ✅ Good: Short, scannable names
let items = ["iOS", "macOS", "tvOS", "watchOS"]

// ❌ Bad: Long names that won't fit
let items = ["iOS Development Platform", "macOS Application Framework"]
```

### Placeholder Text

```swift
// ✅ Good: Clear, contextual
AdaptiveTokenLayout(items: [], placeholder: "No languages selected")

// ❌ Bad: Generic, unhelpful
AdaptiveTokenLayout(items: [], placeholder: "Empty")
```

## Integration with Other Components

Both FlowLayout and AdaptiveTokenLayout are used internally by other SwiftlyUI components:

### TokenTagField

Uses **FlowLayout** to wrap tag chips:
```swift
FlowLayout(spacing: 6) {
    ForEach(tags) { tag in
        TagChip(tag: tag)
    }
}
```

### UserTokenField

Uses **FlowLayout** for user chips:
```swift
FlowLayout(spacing: 6) {
    ForEach(users) { user in
        UserChip(user: user)
    }
}
```

### MultiPicker

Uses **AdaptiveTokenLayout** for selection display:
```swift
AdaptiveTokenLayout(
    items: selectedLabels,
    placeholder: title
)
```

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## Related Components

- **[TokenTagField](TokenTagField.md)** - Uses FlowLayout for tags
- **[UserTokenField](UserTokenField.md)** - Uses FlowLayout for user chips
- **[MultiPicker](MultiPicker.md)** - Uses AdaptiveTokenLayout for selections

## See Also

- [SwiftUI Layout Protocol](https://developer.apple.com/documentation/swiftui/layout)
- [SwiftUI GeometryReader](https://developer.apple.com/documentation/swiftui/geometryreader)
