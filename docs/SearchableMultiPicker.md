# SearchableMultiPicker

A multi-selection picker with built-in search functionality, ideal for large lists where users need to find specific items quickly.

## Overview

`SearchableMultiPicker` extends the base `MultiPicker` with integrated search and filter capabilities. It displays a search field at the top and automatically filters items as you type, making it perfect for datasets with dozens or hundreds of items.

### Key Features

- 🔍 **Built-in Search** - Integrated search field with real-time filtering
- 🎯 **Type-Safe** - Works with any `Hashable` type
- 🎨 **Multiple Styles** - Inline, navigation link, sheet, and menu presentations
- 🔧 **Custom Filters** - Override default search with custom logic
- ⚖️ **Selection Limits** - Set minimum and maximum requirements
- ⚡ **Bulk Actions** - Select All and Clear All on filtered results
- 🪙 **Token Display** - Shows selected items as chips with overflow indicator
- ❌ **Clear Button** - Quick clear search with X button
- 📊 **Selection Count** - Always displays count when items are selected
- 🎭 **Empty State** - Friendly message when no results found

## Basic Usage

### Simple Searchable Picker

```swift
import SwiftUI
import SwiftlyUI

struct CountryPickerView: View {
    @State private var selection: Set<String> = []
    @State private var searchText = ""

    let countries = [
        "Argentina", "Australia", "Brazil", "Canada", "China",
        "France", "Germany", "India", "Italy", "Japan",
        "Mexico", "Netherlands", "Russia", "Spain", "United Kingdom"
    ]

    var body: some View {
        Form {
            SearchableMultiPicker(
                "Select Countries",
                selection: $selection,
                searchText: $searchText
            ) {
                ForEach(countries, id: \.self) { country in
                    Text(country).multiPickerTag(country)
                }
            }
            .multiPickerStyle(.sheet)
        }
    }
}
```

### With LabeledContent

Perfect for forms with multiple pickers:

```swift
struct MealPlannerView: View {
    @State private var selectedFruits: Set<String> = []
    @State private var fruitsSearch = ""
    @State private var selectedVegetables: Set<String> = []
    @State private var vegetablesSearch = ""

    let fruits = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
    let vegetables = ["Asparagus", "Broccoli", "Carrot", "Celery"]

    var body: some View {
        Form {
            Section("Ingredients") {
                LabeledContent("Fruits") {
                    SearchableMultiPicker(
                        "Select Fruits",
                        selection: $selectedFruits,
                        searchText: $fruitsSearch
                    ) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit).multiPickerTag(fruit)
                        }
                    }
                    .multiPickerStyle(.menu)
                }

                LabeledContent("Vegetables") {
                    SearchableMultiPicker(
                        "Select Vegetables",
                        selection: $selectedVegetables,
                        searchText: $vegetablesSearch
                    ) {
                        ForEach(vegetables, id: \.self) { veg in
                            Text(veg).multiPickerTag(veg)
                        }
                    }
                    .multiPickerStyle(.menu)
                }
            }
        }
    }
}
```

## Search Features

### Default Search

By default, searches case-insensitively in item labels:

```swift
SearchableMultiPicker(
    "Select Languages",
    selection: $selection,
    searchText: $searchText,
    searchPlaceholder: "Search languages..."
) {
    ForEach(languages, id: \.self) { language in
        Text(language).multiPickerTag(language)
    }
}
```

### Custom Search Filter

Implement custom search logic:

```swift
struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String
    let tags: [String]
}

struct ProductPickerView: View {
    @State private var selection: Set<UUID> = []
    @State private var searchText = ""

    let products: [Product] = [
        Product(id: UUID(), name: "iPhone", category: "Electronics", tags: ["phone", "mobile"]),
        Product(id: UUID(), name: "MacBook", category: "Computers", tags: ["laptop", "mac"])
    ]

    var body: some View {
        SearchableMultiPicker(
            "Select Products",
            selection: $selection,
            searchText: $searchText,
            searchPlaceholder: "Search by name, category, or tags...",
            searchFilter: { item, query in
                // Custom search across multiple fields
                let product = products.first { $0.id == item.value }!
                let lowerQuery = query.lowercased()

                return product.name.lowercased().contains(lowerQuery) ||
                       product.category.lowercased().contains(lowerQuery) ||
                       product.tags.contains { $0.contains(lowerQuery) }
            }
        ) {
            ForEach(products) { product in
                VStack(alignment: .leading) {
                    Text(product.name)
                    Text(product.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .multiPickerTag(product.id)
            }
        }
    }
}
```

### Search Placeholder

Customize the search field placeholder:

```swift
SearchableMultiPicker(
    "Select Cities",
    selection: $selection,
    searchText: $searchText,
    searchPlaceholder: "Search by city name..."
) {
    ForEach(cities, id: \.self) { city in
        Text(city).multiPickerTag(city)
    }
}
```

## Presentation Styles

### Inline Style

Best for medium-sized lists when you want search always visible:

```swift
SearchableMultiPicker(
    "Select Options",
    selection: $selection,
    searchText: $searchText
) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
.multiPickerStyle(.inline)
```

**Use Cases:**
- 20-50 items
- When search should be prominently displayed
- Forms with dedicated space for selection

### Navigation Link Style

Pushes to a full screen with search at the top:

```swift
SearchableMultiPicker(
    "Select Languages",
    selection: $selection,
    searchText: $searchText
) {
    ForEach(languages, id: \.self) { language in
        Text(language).multiPickerTag(language)
    }
}
.multiPickerStyle(.navigationLink)
```

**Use Cases:**
- Large lists (50+ items)
- iOS apps following navigation patterns
- When you want full-screen selection experience

### Sheet Style

Presents in a modal with Done button:

```swift
SearchableMultiPicker(
    "Select Tags",
    selection: $selection,
    searchText: $searchText
) {
    ForEach(tags, id: \.self) { tag in
        Text(tag).multiPickerTag(tag)
    }
}
.multiPickerStyle(.sheet)
```

**Use Cases:**
- Focused, modal selection tasks
- When selection is a separate workflow step
- Temporary selections that can be dismissed

### Menu Style

Compact popover presentation:

```swift
SearchableMultiPicker(
    "Select Items",
    selection: $selection,
    searchText: $searchText
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
.multiPickerStyle(.menu)
```

**Use Cases:**
- Compact UIs
- macOS applications
- Forms with limited vertical space

**Note:** Menu style shows search inside the popover, making it more compact than inline.

## Bulk Actions with Search

### Select All Filtered Results

Select All respects current search filter:

```swift
SearchableMultiPicker(
    "Select Languages",
    selection: $selection,
    searchText: $searchText,
    showSelectAll: true
) {
    ForEach(languages, id: \.self) { lang in
        Text(lang).multiPickerTag(lang)
    }
}
```

**Behavior:**
- Clicking "Select All" selects only filtered (visible) items
- Respects `maxSelections` limit
- Disabled when all filtered items are already selected

**Example:** Searching for "Java" and clicking "Select All" only selects JavaScript, Java, not Python.

### Clear All

Clears all selections regardless of current filter:

```swift
SearchableMultiPicker(
    "Select Colors",
    selection: $selection,
    searchText: $searchText,
    showClearAll: true
) {
    ForEach(colors, id: \.self) { color in
        Text(color).multiPickerTag(color)
    }
}
```

### Combined Bulk Actions

```swift
SearchableMultiPicker(
    "Select Items",
    selection: $selection,
    searchText: $searchText,
    showSelectAll: true,
    showClearAll: true
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
```

## Selection Constraints

### Minimum Selections

```swift
SearchableMultiPicker(
    "Choose at least 2 colors",
    selection: $selection,
    searchText: $searchText,
    minSelections: 2
) {
    ForEach(colors, id: \.self) { color in
        Text(color).multiPickerTag(color)
    }
}
```

**Behavior:**
- Cannot deselect items below minimum
- Validation message appears when below minimum

### Maximum Selections

```swift
SearchableMultiPicker(
    "Choose up to 5 languages",
    selection: $selection,
    searchText: $searchText,
    maxSelections: 5
) {
    ForEach(languages, id: \.self) { lang in
        Text(lang).multiPickerTag(lang)
    }
}
```

**Behavior:**
- Unselected items become disabled at maximum
- Warning message when limit reached
- Select All respects the limit

### Combined Constraints

```swift
SearchableMultiPicker(
    "Choose 2-4 options",
    selection: $selection,
    searchText: $searchText,
    minSelections: 2,
    maxSelections: 4
) {
    ForEach(options, id: \.self) { option in
        Text(option).multiPickerTag(option)
    }
}
```

## Empty State

When search returns no results, a friendly empty state appears:

```swift
SearchableMultiPicker(
    "Select Items",
    selection: $selection,
    searchText: $searchText
) {
    ForEach(items, id: \.self) { item in
        Text(item).multiPickerTag(item)
    }
}
```

**Empty State Includes:**
- Magnifying glass icon
- "No results found" message
- "Try a different search term" hint

## API Reference

### Initializer

```swift
public init(
    _ titleKey: String,
    selection: Binding<Set<SelectionValue>>,
    searchText: Binding<String>,
    minSelections: Int = 0,
    maxSelections: Int? = nil,
    showSelectAll: Bool = false,
    showClearAll: Bool = false,
    requiresConfirmation: Bool = false,
    searchPlaceholder: String = "Search...",
    searchFilter: (((value: SelectionValue, label: String), String) -> Bool)? = nil,
    @ViewBuilder content: () -> Content
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `titleKey` | `String` | Required | Title/label for the picker |
| `selection` | `Binding<Set<SelectionValue>>` | Required | Binding to selected values |
| `searchText` | `Binding<String>` | Required | Binding to search text |
| `minSelections` | `Int` | `0` | Minimum required selections |
| `maxSelections` | `Int?` | `nil` | Maximum allowed selections (nil = unlimited) |
| `showSelectAll` | `Bool` | `false` | Show "Select All" button |
| `showClearAll` | `Bool` | `false` | Show "Clear All" button |
| `requiresConfirmation` | `Bool` | `false` | Require Apply/Cancel confirmation |
| `searchPlaceholder` | `String` | `"Search..."` | Placeholder text for search field |
| `searchFilter` | `((item, query) -> Bool)?` | `nil` | Custom search filter (default: case-insensitive label match) |
| `content` | `@ViewBuilder` | Required | Items with `.multiPickerTag()` modifiers |

### View Modifiers

```swift
// Set presentation style
.multiPickerStyle(.inline)
.multiPickerStyle(.navigationLink)
.multiPickerStyle(.sheet)
.multiPickerStyle(.menu)
```

## Complete Examples

### Multi-Select Tags

```swift
struct TagSelectorView: View {
    @State private var selectedTags: Set<String> = []
    @State private var searchText = ""

    let tags = [
        "Bug", "Feature", "Documentation", "Enhancement",
        "Question", "Help Wanted", "Good First Issue",
        "Priority: High", "Priority: Medium", "Priority: Low",
        "iOS", "macOS", "watchOS", "tvOS"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Issue Labels") {
                    SearchableMultiPicker(
                        "Add Labels",
                        selection: $selectedTags,
                        searchText: $searchText,
                        maxSelections: 5,
                        showSelectAll: true,
                        showClearAll: true
                    ) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag).multiPickerTag(tag)
                        }
                    }
                    .multiPickerStyle(.sheet)
                }

                Section("Applied Labels") {
                    if selectedTags.isEmpty {
                        Text("No labels selected")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(selectedTags.sorted()), id: \.self) { tag in
                            HStack {
                                Text(tag)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)

                                Spacer()

                                Button {
                                    selectedTags.remove(tag)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Label Issue")
        }
    }
}
```

### Location Picker

```swift
struct LocationPickerView: View {
    @State private var selectedCities: Set<String> = []
    @State private var searchText = ""

    let cities = [
        "Amsterdam", "Athens", "Barcelona", "Berlin", "Brussels",
        "Copenhagen", "Dublin", "Edinburgh", "Florence", "Geneva",
        "Hamburg", "Helsinki", "Istanbul", "Lisbon", "London",
        "Madrid", "Milan", "Munich", "Oslo", "Paris",
        "Prague", "Rome", "Stockholm", "Venice", "Vienna", "Zurich"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Travel Destinations") {
                    SearchableMultiPicker(
                        "Select Cities",
                        selection: $selectedCities,
                        searchText: $searchText,
                        minSelections: 1,
                        maxSelections: 5,
                        showSelectAll: true,
                        showClearAll: true
                    ) {
                        ForEach(cities, id: \.self) { city in
                            Label(city, systemImage: "mappin.circle.fill")
                                .multiPickerTag(city)
                        }
                    }
                    .multiPickerStyle(.navigationLink)
                }

                Section {
                    Text("You've selected \(selectedCities.count) of 5 possible destinations")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Plan Your Trip")
        }
    }
}
```

### Skills Selector

```swift
struct SkillsSelectorView: View {
    @State private var selectedSkills: Set<Skill.ID> = []
    @State private var searchText = ""

    let skills: [Skill] = [
        Skill(name: "Swift", level: "Expert", category: "Programming"),
        Skill(name: "SwiftUI", level: "Advanced", category: "UI"),
        Skill(name: "UIKit", level: "Intermediate", category: "UI"),
        Skill(name: "Combine", level: "Advanced", category: "Reactive"),
        Skill(name: "Core Data", level: "Intermediate", category: "Database")
    ]

    var body: some View {
        Form {
            SearchableMultiPicker(
                "Your Skills",
                selection: $selectedSkills,
                searchText: $searchText,
                showSelectAll: true,
                searchFilter: { item, query in
                    let skill = skills.first { $0.id == item.value }!
                    let lowerQuery = query.lowercased()
                    return skill.name.lowercased().contains(lowerQuery) ||
                           skill.category.lowercased().contains(lowerQuery)
                }
            ) {
                ForEach(skills) { skill in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(skill.name)
                            Text(skill.level)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(skill.category)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .multiPickerTag(skill.id)
                }
            }
            .multiPickerStyle(.inline)
        }
    }
}

struct Skill: Identifiable {
    let id = UUID()
    let name: String
    let level: String
    let category: String
}
```

## Best Practices

### When to Use SearchableMultiPicker

✅ **Use when:**
- List has 20+ items
- Users need to find specific items quickly
- Dataset is searchable by nature (names, titles, categories)
- You need bulk selection from filtered results

❌ **Don't use when:**
- List has fewer than 10 items → Use `MultiPicker` instead
- Items don't have meaningful text to search → Use `MultiPicker` with sections
- Need advanced sectioning features → Use `GroupedMultiPicker`

### Search Performance

For very large datasets (500+ items):
- Keep item views lightweight
- Use `.id(\.self)` only for simple types
- Implement custom `Identifiable` for complex types
- Consider pagination or lazy loading for 1000+ items

### Custom Search Tips

- Always use case-insensitive comparison: `.lowercased()`
- Use `localizedCaseInsensitiveContains()` for international text
- Search multiple fields for better user experience
- Consider fuzzy matching for better discoverability

### Search UX

- Provide clear search placeholder ("Search by name...")
- Clear search when changing contexts
- Don't clear search when dismissing and reopening
- Consider debouncing for expensive filter operations

### Accessibility

- Search field is automatically labeled
- Empty state is announced to screen readers
- All keyboard shortcuts work
- Selected items are announced with count

## Comparison with MultiPicker

| Feature | SearchableMultiPicker | MultiPicker |
|---------|----------------------|-------------|
| Built-in Search | ✅ Yes | ❌ No |
| Section Support | ❌ No | ✅ Yes |
| Best For | Large lists (20+) | Small lists (< 20) |
| Empty State | ✅ Yes | N/A |
| Custom Filter | ✅ Yes | N/A |

**Rule of Thumb:** Use SearchableMultiPicker for 20+ items, MultiPicker for organized/sectioned lists.

## Related Components

- **[MultiPicker](MultiPicker.md)** - For smaller lists with optional sections
- **[GroupedMultiPicker](GroupedMultiPicker.md)** - For advanced sectioning features

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## See Also

- [Apple Search Documentation](https://developer.apple.com/documentation/swiftui/adding-search-to-your-app)
- [SwiftUI List Filtering](https://developer.apple.com/documentation/swiftui/list)
