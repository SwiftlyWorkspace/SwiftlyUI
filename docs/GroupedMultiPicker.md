# GroupedMultiPicker

A multi-selection picker with advanced section management, including collapsible sections, per-section selection counts, and array-based data organization.

## Overview

`GroupedMultiPicker` (also available as `SectionedMultiPicker`) is specialized for working with categorized data. Unlike `MultiPicker`, it uses an array-based API with explicit section definitions and provides advanced features like collapsible sections and section-level selection tracking.

### Key Features

- 📁 **Explicit Sections** - Array-based section definition with headers and items
- 🔽 **Collapsible Sections** - Expand/collapse sections with chevron indicators
- 📊 **Section Counts** - Display selection count per section
- ⚖️ **Selection Limits** - Set minimum and maximum constraints
- ⚡ **Bulk Actions** - Select All and Clear All operations
- ✅ **Confirmation Mode** - Optional Apply/Cancel workflow
- 🪙 **Token Display** - Shows selected items as chips with overflow
- 🎨 **Styled Headers** - Distinct section header styling
- 📈 **Selection Tracking** - Visual feedback for section-level progress

## When to Use GroupedMultiPicker

**Use GroupedMultiPicker when:**
- ✅ Data is naturally organized into categories
- ✅ You need collapsible sections
- ✅ You want per-section selection counts
- ✅ Data comes from an array-based structure
- ✅ You need fine control over section presentation

**Use MultiPicker instead when:**
- ❌ Simple flat list or basic sections are sufficient
- ❌ You prefer ViewBuilder API
- ❌ Sections don't need to collapse

## Basic Usage

### Simple Grouped Picker

```swift
import SwiftUI
import SwiftlyUI

struct FoodSelectorView: View {
    @State private var selection: Set<String> = []

    let sections = [
        (header: "Fruits", items: [
            (value: "apple", label: "Apple"),
            (value: "banana", label: "Banana"),
            (value: "cherry", label: "Cherry")
        ]),
        (header: "Vegetables", items: [
            (value: "carrot", label: "Carrot"),
            (value: "broccoli", label: "Broccoli"),
            (value: "spinach", label: "Spinach")
        ])
    ]

    var body: some View {
        Form {
            GroupedMultiPicker(
                title: "Select Foods",
                sections: sections,
                selection: $selection
            )
        }
    }
}
```

### With Collapsible Sections

Enable section collapsing to let users focus on specific categories:

```swift
struct ProductCatalogView: View {
    @State private var selection: Set<String> = []

    let sections = [
        (header: "Electronics", items: [
            (value: "phone", label: "Smartphone"),
            (value: "laptop", label: "Laptop"),
            (value: "tablet", label: "Tablet"),
            (value: "watch", label: "Smartwatch")
        ]),
        (header: "Accessories", items: [
            (value: "case", label: "Phone Case"),
            (value: "charger", label: "Charger"),
            (value: "cable", label: "USB Cable"),
            (value: "adapter", label: "Power Adapter")
        ]),
        (header: "Audio", items: [
            (value: "headphones", label: "Headphones"),
            (value: "earbuds", label: "Wireless Earbuds"),
            (value: "speaker", label: "Bluetooth Speaker")
        ])
    ]

    var body: some View {
        GroupedMultiPicker(
            title: "Select Products",
            sections: sections,
            selection: $selection,
            collapsibleSections: true
        )
        .multiPickerStyle(.sheet)
    }
}
```

## Section Features

### Section Headers

Headers automatically display:
- **Section name** in semibold, secondary color
- **Selection count** (e.g., "(3)") when items are selected
- **Chevron indicator** (if collapsible)
- **Background color** for visual separation

### Collapsible Behavior

When `collapsibleSections: true`:

```swift
GroupedMultiPicker(
    title: "Choose Options",
    sections: categorizedOptions,
    selection: $selection,
    collapsibleSections: true
)
```

**Behavior:**
- Tap section header to toggle collapsed state
- Chevron points right when collapsed, down when expanded
- Items are hidden when section is collapsed
- Selection count still visible when collapsed
- State preserved during parent view updates

### Section Selection Counts

Each section header shows how many items are selected from that section:

```swift
// Header displays: "Fruits (2)" if 2 fruits are selected
// Header displays: "Vegetables" if no vegetables are selected
```

This provides at-a-glance feedback about selection distribution across categories.

## Working with Data

### Defining Sections

The sections parameter expects an array of tuples:

```swift
let sections: [(header: String, items: [(value: ValueType, label: String)])]
```

**Example with Swift types:**

```swift
// Simple string values
let simpleSections = [
    (header: "Colors", items: [
        (value: "red", label: "Red"),
        (value: "blue", label: "Blue")
    ])
]

// Int values
let numberSections = [
    (header: "Single Digits", items: [
        (value: 1, label: "One"),
        (value: 2, label: "Two")
    ]),
    (header: "Teens", items: [
        (value: 11, label: "Eleven"),
        (value: 12, label: "Twelve")
    ])
]

// UUID values (common for database IDs)
let idSections: [(header: String, items: [(value: UUID, label: String)])] = [
    (header: "Active Users", items: [
        (value: userId1, label: "Alice"),
        (value: userId2, label: "Bob")
    ])
]
```

### Mapping from Models

Convert your data models to the required format:

```swift
struct Category {
    let name: String
    let products: [Product]
}

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct CatalogView: View {
    @State private var selection: Set<UUID> = []

    let categories: [Category] = [
        Category(name: "Electronics", products: [
            Product(id: UUID(), name: "Phone"),
            Product(id: UUID(), name: "Laptop")
        ]),
        Category(name: "Books", products: [
            Product(id: UUID(), name: "Swift Programming"),
            Product(id: UUID(), name: "iOS Development")
        ])
    ]

    // Convert to sections format
    var sections: [(header: String, items: [(value: UUID, label: String)])] {
        categories.map { category in
            (
                header: category.name,
                items: category.products.map { product in
                    (value: product.id, label: product.name)
                }
            )
        }
    }

    var body: some View {
        GroupedMultiPicker(
            title: "Select Products",
            sections: sections,
            selection: $selection,
            collapsibleSections: true
        )
    }
}
```

## Selection Constraints

### Minimum Selections

```swift
GroupedMultiPicker(
    title: "Choose Skills",
    sections: skillSections,
    selection: $selection,
    minSelections: 3
)
```

**Behavior:**
- Cannot deselect below minimum
- Validation message: "Select at least 3 items"
- Appears at bottom of picker

### Maximum Selections

```swift
GroupedMultiPicker(
    title: "Choose Preferences",
    sections: preferenceSections,
    selection: $selection,
    maxSelections: 5
)
```

**Behavior:**
- Unselected items disabled at maximum
- Warning message: "Maximum 5 selections reached"
- Select All respects limit

### Combined Constraints

```swift
GroupedMultiPicker(
    title: "Choose 3-7 Items",
    sections: sections,
    selection: $selection,
    minSelections: 3,
    maxSelections: 7
)
```

## Bulk Actions

### Select All

```swift
GroupedMultiPicker(
    title: "Select Items",
    sections: sections,
    selection: $selection,
    showSelectAll: true
)
```

**Behavior:**
- Selects items from all sections
- Respects `maxSelections` (selects first N items if limit exists)
- Disabled when all items selected or count exceeds max limit

### Clear All

```swift
GroupedMultiPicker(
    title: "Select Items",
    sections: sections,
    selection: $selection,
    showClearAll: true
)
```

**Behavior:**
- Clears all selections across all sections
- Disabled when selection is empty

### Combined Bulk Actions

```swift
GroupedMultiPicker(
    title: "Select Items",
    sections: sections,
    selection: $selection,
    showSelectAll: true,
    showClearAll: true
)
```

Both buttons appear in a toolbar at the top of the picker.

## Confirmation Mode

Require explicit confirmation before applying changes:

```swift
GroupedMultiPicker(
    title: "Select Interests",
    sections: sections,
    selection: $selection,
    minSelections: 2,
    maxSelections: 5,
    requiresConfirmation: true
)
```

**Behavior:**
- "Apply" button commits changes
- "Cancel" button reverts to previous selection
- "Apply" disabled until selection meets validation rules
- Changes not reflected in binding until "Apply" clicked

**Best For:**
- Critical selections requiring review
- Multi-step workflows
- When accidental changes should be prevented

## API Reference

### Initializer

```swift
public init(
    title: String,
    sections: [(header: String, items: [(value: SelectionValue, label: String)])],
    selection: Binding<Set<SelectionValue>>,
    minSelections: Int = 0,
    maxSelections: Int? = nil,
    showSelectAll: Bool = false,
    showClearAll: Bool = false,
    requiresConfirmation: Bool = false,
    collapsibleSections: Bool = false
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | Required | Title/label for the picker |
| `sections` | `[(header, items)]` | Required | Sections with headers and items |
| `selection` | `Binding<Set<SelectionValue>>` | Required | Binding to selected values |
| `minSelections` | `Int` | `0` | Minimum required selections |
| `maxSelections` | `Int?` | `nil` | Maximum allowed selections (nil = unlimited) |
| `showSelectAll` | `Bool` | `false` | Show "Select All" button |
| `showClearAll` | `Bool` | `false` | Show "Clear All" button |
| `requiresConfirmation` | `Bool` | `false` | Require Apply/Cancel confirmation |
| `collapsibleSections` | `Bool` | `false` | Enable section collapse/expand |

### Type Alias

```swift
public typealias SectionedMultiPicker = GroupedMultiPicker
```

Both names refer to the same component.

### View Modifiers

```swift
// Set presentation style
.multiPickerStyle(.inline)
.multiPickerStyle(.navigationLink)
.multiPickerStyle(.sheet)
.multiPickerStyle(.menu)
```

## Complete Examples

### Settings Screen

```swift
struct NotificationSettingsView: View {
    @State private var enabledChannels: Set<String> = ["email", "push"]

    let sections = [
        (header: "Primary Channels", items: [
            (value: "email", label: "Email Notifications"),
            (value: "push", label: "Push Notifications"),
            (value: "sms", label: "SMS Messages")
        ]),
        (header: "Social", items: [
            (value: "slack", label: "Slack"),
            (value: "teams", label: "Microsoft Teams"),
            (value: "discord", label: "Discord")
        ]),
        (header: "Other", items: [
            (value: "webhook", label: "Webhook"),
            (value: "api", label: "API Callback")
        ])
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Notification Channels") {
                    GroupedMultiPicker(
                        title: "Active Channels",
                        sections: sections,
                        selection: $enabledChannels,
                        minSelections: 1,
                        showClearAll: true,
                        collapsibleSections: true
                    )
                    .multiPickerStyle(.inline)
                }

                Section("Summary") {
                    Text("Notifications will be sent through \(enabledChannels.count) channel(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Notifications")
        }
    }
}
```

### Multi-Category Filter

```swift
struct ProductFilterView: View {
    @State private var selectedCategories: Set<String> = []
    @State private var selectedBrands: Set<String> = []

    // Combine into one selection with prefixed values
    @State private var selection: Set<String> = []

    let filterSections = [
        (header: "Categories", items: [
            (value: "cat_electronics", label: "Electronics"),
            (value: "cat_clothing", label: "Clothing"),
            (value: "cat_home", label: "Home & Garden"),
            (value: "cat_sports", label: "Sports & Outdoors")
        ]),
        (header: "Price Range", items: [
            (value: "price_0_50", label: "Under $50"),
            (value: "price_50_100", label: "$50 - $100"),
            (value: "price_100_200", label: "$100 - $200"),
            (value: "price_200_plus", label: "Over $200")
        ]),
        (header: "Brand", items: [
            (value: "brand_apple", label: "Apple"),
            (value: "brand_samsung", label: "Samsung"),
            (value: "brand_sony", label: "Sony"),
            (value: "brand_nike", label: "Nike")
        ]),
        (header: "Condition", items: [
            (value: "cond_new", label: "New"),
            (value: "cond_refurb", label: "Refurbished"),
            (value: "cond_used", label: "Used")
        ])
    ]

    var body: some View {
        NavigationStack {
            VStack {
                GroupedMultiPicker(
                    title: "Filter Products",
                    sections: filterSections,
                    selection: $selection,
                    showSelectAll: true,
                    showClearAll: true,
                    collapsibleSections: true,
                    requiresConfirmation: true
                )
                .multiPickerStyle(.inline)

                Spacer()

                Button("Apply Filters") {
                    applyFilters()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selection.isEmpty)
                .padding()
            }
            .navigationTitle("Filter Options")
        }
    }

    func applyFilters() {
        // Parse selections and apply filters
        let categories = selection.filter { $0.hasPrefix("cat_") }
        let prices = selection.filter { $0.hasPrefix("price_") }
        let brands = selection.filter { $0.hasPrefix("brand_") }
        let conditions = selection.filter { $0.hasPrefix("cond_") }

        // Apply filtering logic
    }
}
```

### Permission Manager

```swift
struct PermissionManagerView: View {
    @State private var grantedPermissions: Set<Permission.ID> = []

    let permissionSections: [(header: String, items: [(value: UUID, label: String)])]

    init() {
        let readPermissions = [
            Permission(name: "Read Users", category: "Users"),
            Permission(name: "Read Posts", category: "Content"),
            Permission(name: "Read Comments", category: "Content")
        ]

        let writePermissions = [
            Permission(name: "Create Users", category: "Users"),
            Permission(name: "Edit Posts", category: "Content"),
            Permission(name: "Delete Comments", category: "Content")
        ]

        let adminPermissions = [
            Permission(name: "Manage Roles", category: "Admin"),
            Permission(name: "View Analytics", category: "Admin"),
            Permission(name: "System Settings", category: "Admin")
        ]

        self.permissionSections = [
            (
                header: "Read Permissions",
                items: readPermissions.map { (value: $0.id, label: $0.name) }
            ),
            (
                header: "Write Permissions",
                items: writePermissions.map { (value: $0.id, label: $0.name) }
            ),
            (
                header: "Admin Permissions",
                items: adminPermissions.map { (value: $0.id, label: $0.name) }
            )
        ]
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Role Permissions") {
                    GroupedMultiPicker(
                        title: "Select Permissions",
                        sections: permissionSections,
                        selection: $grantedPermissions,
                        minSelections: 1,
                        showSelectAll: true,
                        showClearAll: true,
                        collapsibleSections: true,
                        requiresConfirmation: true
                    )
                    .multiPickerStyle(.inline)
                }

                Section("Summary") {
                    HStack {
                        Text("Total Permissions:")
                        Spacer()
                        Text("\(grantedPermissions.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Role")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePermissions()
                    }
                }
            }
        }
    }

    func savePermissions() {
        // Save permission changes
    }
}

struct Permission: Identifiable {
    let id = UUID()
    let name: String
    let category: String
}
```

## Best Practices

### Section Organization

- **Keep sections focused** - Each section should represent a clear category
- **Limit section count** - 3-7 sections is ideal, 10+ becomes overwhelming
- **Balance items per section** - Avoid one section with 50 items, others with 2
- **Meaningful headers** - Use concise, descriptive section names

### Collapsible Sections

✅ **Use collapsible sections when:**
- You have 4+ sections
- Some sections have many items (10+)
- Users typically focus on specific categories
- Not all sections are relevant to every user

❌ **Don't use collapsible sections when:**
- Only 2-3 sections total
- All sections have few items (< 5)
- Users need to see all options at once

### Performance

- Keep item rendering lightweight
- Use `UUID` or `Int` for values with large datasets
- Avoid heavy computation in item labels
- Consider lazy loading for 200+ total items

### Data Organization

```swift
// ✅ Good: Separate model layer
struct DataService {
    func getCategorizedProducts() -> [Category] {
        // Fetch and return structured data
    }
}

// Transform for picker
var sections: [(header: String, items: [(value: UUID, label: String)])] {
    DataService().getCategorizedProducts().map { category in
        (header: category.name, items: category.products.map { ($0.id, $0.name) })
    }
}

// ❌ Bad: Hardcoded in view
let sections = [/* massive inline array */]
```

## Comparison with Other Pickers

| Feature | GroupedMultiPicker | MultiPicker | SearchableMultiPicker |
|---------|-------------------|-------------|----------------------|
| Section Support | ✅ Advanced | ✅ Basic | ❌ No |
| Collapsible Sections | ✅ Yes | ❌ No | ❌ No |
| Section Counts | ✅ Yes | ❌ No | ❌ No |
| API Style | Array-based | ViewBuilder | ViewBuilder |
| Search | ❌ No | ❌ No | ✅ Yes |
| Best For | Categorized data | General use | Large lists (20+) |

### When to Use Each

- **GroupedMultiPicker** → Categorized data, need collapsing/counts
- **MultiPicker** → Simple lists or basic sections
- **SearchableMultiPicker** → Large lists needing search

## Related Components

- **[MultiPicker](MultiPicker.md)** - General multi-selection with basic sections
- **[SearchableMultiPicker](SearchableMultiPicker.md)** - For large lists with search

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## See Also

- [SwiftUI Sections](https://developer.apple.com/documentation/swiftui/section)
- [SwiftUI DisclosureGroup](https://developer.apple.com/documentation/swiftui/disclosuregroup)
