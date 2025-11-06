# TokenTagField

A sophisticated token-based input field for managing tags with auto-completion, inline editing, and color customization.

## Overview

`TokenTagField` provides a rich interface for creating, editing, and managing tags. Users can add tags by typing and pressing Enter, double-tap to edit existing tags, and remove tags with a click. The component includes smart auto-completion, keyboard navigation, and prevents duplicate entries.

### Key Features

- ✅ **Tag Creation** - Add tags by typing and pressing Enter
- ✏️ **Inline Editing** - Double-tap any tag to edit its name
- 🎨 **Color Customization** - Choose from 10 predefined colors or custom colors
- 💡 **Smart Auto-completion** - Filtered suggestions based on input
- ⌨️ **Keyboard Navigation** - Full keyboard support including backspace delete
- 🚫 **Duplicate Prevention** - Automatically prevents duplicate tag names
- 📏 **Tag Limits** - Set maximum number of tags
- 🔄 **Real-time Callbacks** - Respond to add, remove, and update events
- 🎯 **Suggestion Matching** - Preserves suggested tag colors when matched
- 📱 **Cross-Platform** - iOS, macOS, tvOS, and watchOS support

## Basic Usage

### Simple Tag Input

```swift
import SwiftUI
import SwiftlyUI

struct TagInputView: View {
    @State private var tags: [Tag] = []
    @State private var inputText = ""

    var body: some View {
        VStack {
            TokenTagField(
                tags: $tags,
                inputText: $inputText,
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

### With Suggestions

```swift
struct SkillTagsView: View {
    @State private var skills: [Tag] = []
    @State private var inputText = ""

    let suggestedSkills: [Tag] = [
        Tag(name: "Swift", color: .orange),
        Tag(name: "SwiftUI", color: .blue),
        Tag(name: "iOS", color: .green),
        Tag(name: "UIKit", color: .purple),
        Tag(name: "Combine", color: .red)
    ]

    var body: some View {
        Form {
            Section("Your Skills") {
                TokenTagField(
                    tags: $skills,
                    inputText: $inputText,
                    suggestedTags: suggestedSkills,
                    maxTags: 10,
                    placeholder: "Add a skill...",
                    onAdd: { skills.append($0) },
                    onRemove: { skills.removeAll { $0.id == $1.id } },
                    onUpdate: { tag in
                        if let index = skills.firstIndex(where: { $0.id == tag.id }) {
                            skills[index] = tag
                        }
                    }
                )
            }
        }
    }
}
```

## Tag Model

### Creating Tags

```swift
// Simple tag with auto-generated UUID and specified color
let tag = Tag(name: "Swift", color: .blue)

// Tag with specific UUID (useful for persistence)
let tag = Tag(id: myUUID, name: "iOS", color: .green)

// Tag with random color
let tag = Tag.withRandomColor(name: "Programming")
```

### Available Colors

The `Tag` type provides 10 predefined colors:

```swift
Tag.availableColors // [.blue, .green, .red, .purple, .orange, .pink, .yellow, .indigo, .teal, .cyan]

// Get a random color
let color = Tag.randomColor()

// Get color name
Tag.colorName(for: .blue) // Returns "Blue"
```

### Tag Properties

```swift
public struct Tag: Identifiable, Hashable, Sendable {
    public let id: UUID          // Unique identifier
    public var name: String      // Display name
    public var color: Color      // Visual color
}
```

## Features in Detail

### Auto-completion

The component shows up to 5 filtered suggestions based on your input:

```swift
TokenTagField(
    tags: $tags,
    inputText: $inputText,
    suggestedTags: allAvailableTags,  // Your full suggestion list
    onAdd: { tags.append($0) },
    onRemove: { tags.removeAll { $0.id == $1.id } },
    onUpdate: { /* ... */ }
)
```

**Behavior:**
- Suggestions appear as you type
- Case-insensitive matching
- Excludes already-added tags
- Shows up to 5 matches
- Click or tap to select
- Preserves suggested tag's color when selected

**Suggestion Display:**
- Tag name on the left
- "suggested" badge on the right with tag's color
- Hover/tap effects for selection
- Automatic dismiss on selection

### Inline Editing

Double-tap any tag to edit it:

**Editing Behavior:**
- Double-tap tag to enter edit mode
- Text field appears with current name
- Press Enter to save changes
- Press Escape to cancel (macOS/keyboard users)
- Click/tap outside to save
- Prevents duplicate names during editing
- Preserves tag color during edit

### Duplicate Prevention

The component automatically prevents duplicates:

```swift
// Case-insensitive matching
// "swift", "Swift", "SWIFT" are all considered duplicates

// During addition
addTag("swift") // Adds successfully
addTag("Swift") // Silently ignored (duplicate)

// During editing
// Cannot rename a tag to a name that already exists
```

### Tag Limits

Set a maximum number of tags:

```swift
TokenTagField(
    tags: $tags,
    inputText: $inputText,
    maxTags: 5,  // Limit to 5 tags
    onAdd: { tags.append($0) },
    onRemove: { tags.removeAll { $0.id == $1.id } },
    onUpdate: { /* ... */ }
)
```

**Behavior:**
- Input field disappears when limit reached
- Warning message appears: "Maximum N tags reached"
- Cannot add more tags until one is removed
- Edit and remove still work

### Callbacks

Three callbacks provide full control over tag lifecycle:

```swift
TokenTagField(
    tags: $tags,
    inputText: $inputText,
    onAdd: { newTag in
        // Called when user adds a new tag
        tags.append(newTag)
        analyticsTracker.log("tag_added", tag: newTag.name)
    },
    onRemove: { tagToRemove in
        // Called when user clicks remove button on tag
        tags.removeAll { $0.id == tagToRemove.id }
        analyticsTracker.log("tag_removed", tag: tagToRemove.name)
    },
    onUpdate: { updatedTag in
        // Called when user finishes editing a tag
        if let index = tags.firstIndex(where: { $0.id == updatedTag.id }) {
            let oldName = tags[index].name
            tags[index] = updatedTag
            analyticsTracker.log("tag_updated", from: oldName, to: updatedTag.name)
        }
    }
)
```

## API Reference

### Initializer

```swift
public init(
    tags: Binding<[Tag]>,
    inputText: Binding<String>,
    suggestedTags: [Tag] = [],
    maxTags: Int = 10,
    placeholder: String = "Add tag...",
    onAdd: @escaping (Tag) -> Void,
    onRemove: @escaping (Tag) -> Void,
    onUpdate: @escaping (Tag) -> Void
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tags` | `Binding<[Tag]>` | Required | Binding to current tag array |
| `inputText` | `Binding<String>` | Required | Binding to input field text |
| `suggestedTags` | `[Tag]` | `[]` | Array of suggested tags for auto-completion |
| `maxTags` | `Int` | `10` | Maximum number of tags allowed |
| `placeholder` | `String` | `"Add tag..."` | Placeholder text for input field |
| `onAdd` | `(Tag) -> Void` | Required | Callback when tag is added |
| `onRemove` | `(Tag) -> Void` | Required | Callback when tag is removed |
| `onUpdate` | `(Tag) -> Void` | Required | Callback when tag is updated |

### Tag Static Methods

```swift
// Create tag with random color
Tag.withRandomColor(name: "Swift") -> Tag

// Get random color from available colors
Tag.randomColor() -> Color

// Get human-readable color name
Tag.colorName(for: .blue) -> String

// Array of available colors
Tag.availableColors -> [Color]
```

## Complete Examples

### Blog Post Tags

```swift
struct BlogPostEditorView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [Tag] = []
    @State private var tagInput = ""

    let popularTags = [
        Tag(name: "Swift", color: .orange),
        Tag(name: "iOS", color: .blue),
        Tag(name: "Tutorial", color: .green),
        Tag(name: "SwiftUI", color: .purple),
        Tag(name: "Best Practices", color: .indigo)
    ]

    var body: some View {
        Form {
            Section("Post Details") {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
            }

            Section("Tags") {
                TokenTagField(
                    tags: $tags,
                    inputText: $tagInput,
                    suggestedTags: popularTags,
                    maxTags: 5,
                    placeholder: "Add tags...",
                    onAdd: { tags.append($0) },
                    onRemove: { tags.removeAll { $0.id == $1.id } },
                    onUpdate: { tag in
                        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
                            tags[index] = tag
                        }
                    }
                )

                Text("\(tags.count) of 5 tags added")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Publish Post") {
                    publishPost()
                }
                .disabled(title.isEmpty || content.isEmpty || tags.isEmpty)
            }
        }
        .navigationTitle("New Post")
    }

    func publishPost() {
        // Publish logic
    }
}
```

### Contact Labels

```swift
struct ContactLabelsView: View {
    @State private var labels: [Tag] = []
    @State private var labelInput = ""

    // Predefined label suggestions
    let commonLabels = [
        Tag(name: "Work", color: .blue),
        Tag(name: "Personal", color: .green),
        Tag(name: "Family", color: .red),
        Tag(name: "Friend", color: .purple),
        Tag(name: "VIP", color: .yellow),
        Tag(name: "Colleague", color: .cyan)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact Labels") {
                    TokenTagField(
                        tags: $labels,
                        inputText: $labelInput,
                        suggestedTags: commonLabels,
                        maxTags: 8,
                        placeholder: "Add label...",
                        onAdd: { newLabel in
                            labels.append(newLabel)
                            saveLabels()
                        },
                        onRemove: { labelToRemove in
                            labels.removeAll { $0.id == labelToRemove.id }
                            saveLabels()
                        },
                        onUpdate: { updatedLabel in
                            if let index = labels.firstIndex(where: { $0.id == updatedLabel.id }) {
                                labels[index] = updatedLabel
                                saveLabels()
                            }
                        }
                    )
                }

                Section("Applied Labels") {
                    if labels.isEmpty {
                        Text("No labels applied")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(labels) { label in
                            HStack {
                                Circle()
                                    .fill(label.color)
                                    .frame(width: 10, height: 10)
                                Text(label.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Contact Labels")
        }
    }

    func saveLabels() {
        // Persist labels
    }
}
```

### Product Categories

```swift
struct ProductCategoriesView: View {
    @State private var categories: [Tag] = []
    @State private var categoryInput = ""

    let departmentCategories = [
        Tag(name: "Electronics", color: .blue),
        Tag(name: "Clothing", color: .purple),
        Tag(name: "Home & Garden", color: .green),
        Tag(name: "Sports", color: .orange),
        Tag(name: "Books", color: .red),
        Tag(name: "Toys", color: .pink)
    ]

    var body: some View {
        Form {
            Section("Product Categories") {
                TokenTagField(
                    tags: $categories,
                    inputText: $categoryInput,
                    suggestedTags: departmentCategories,
                    maxTags: 3,
                    placeholder: "Add category...",
                    onAdd: { categories.append($0) },
                    onRemove: { categories.removeAll { $0.id == $1.id } },
                    onUpdate: { tag in
                        if let index = categories.firstIndex(where: { $0.id == tag.id }) {
                            categories[index] = tag
                        }
                    }
                )
            }

            Section {
                Text("Select 1-3 categories for your product")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

## Best Practices

### Tag Management

✅ **Do:**
- Store tags in your model layer
- Persist tags to UserDefaults or database
- Use callbacks for analytics/tracking
- Provide relevant suggestions
- Set reasonable max limits (5-10)

❌ **Don't:**
- Manipulate tag array outside of callbacks
- Set maxTags too low (< 3) or too high (> 20)
- Forget to handle persistence in callbacks
- Provide too many suggestions (keep under 50)

### Suggestions

```swift
// ✅ Good: Relevant, limited suggestions
let suggestedSkills = [
    Tag(name: "Swift", color: .orange),
    Tag(name: "JavaScript", color: .yellow),
    Tag(name: "Python", color: .blue)
    // 10-20 total suggestions
]

// ❌ Bad: Too many irrelevant suggestions
let suggestedSkills = allPossibleSkills  // 1000+ tags
```

### Persistence

```swift
// ✅ Good: Save in callbacks
onAdd: { newTag in
    tags.append(newTag)
    saveTags(tags)  // Persist immediately
}

// ❌ Bad: Manual save required
onAdd: { newTag in
    tags.append(newTag)
    // Forgot to save - data lost on app close
}
```

### Performance

- Keep suggestion list under 100 items
- Use `Tag` with UUID for efficient updates
- Avoid heavy computation in callbacks
- Consider debouncing persistence for frequent changes

### Accessibility

- Tags are automatically labeled with their names
- Input field has proper placeholder
- Keyboard navigation fully supported
- Screen readers announce tag additions/removals
- Double-tap gesture works with VoiceOver

## Common Patterns

### With Persistence

```swift
struct PersistedTagsView: View {
    @AppStorage("userTags") private var storedTags: Data = Data()
    @State private var tags: [Tag] = []
    @State private var inputText = ""

    var body: some View {
        TokenTagField(
            tags: $tags,
            inputText: $inputText,
            onAdd: { newTag in
                tags.append(newTag)
                persistTags()
            },
            onRemove: { tag in
                tags.removeAll { $0.id == tag.id }
                persistTags()
            },
            onUpdate: { tag in
                if let index = tags.firstIndex(where: { $0.id == tag.id }) {
                    tags[index] = tag
                    persistTags()
                }
            }
        )
        .onAppear {
            loadTags()
        }
    }

    func persistTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            storedTags = encoded
        }
    }

    func loadTags() {
        if let decoded = try? JSONDecoder().decode([Tag].self, from: storedTags) {
            tags = decoded
        }
    }
}
```

### With Validation

```swift
struct ValidatedTagsView: View {
    @State private var tags: [Tag] = []
    @State private var inputText = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TokenTagField(
                tags: $tags,
                inputText: $inputText,
                maxTags: 5,
                onAdd: { newTag in
                    if validateTag(newTag) {
                        tags.append(newTag)
                        errorMessage = nil
                    } else {
                        errorMessage = "Invalid tag name"
                    }
                },
                onRemove: { tags.removeAll { $0.id == $1.id } },
                onUpdate: { tag in
                    if validateTag(tag), let index = tags.firstIndex(where: { $0.id == tag.id }) {
                        tags[index] = tag
                        errorMessage = nil
                    } else {
                        errorMessage = "Invalid tag name"
                    }
                }
            )

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    func validateTag(_ tag: Tag) -> Bool {
        // Only alphanumeric and spaces
        let validCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        return tag.name.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }
}
```

## Related Components

- **[UserTokenField](UserTokenField.md)** - For selecting users with avatars
- **[FlowLayout](Layout.md#flowlayout)** - The layout engine used by TokenTagField

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## See Also

- [SwiftUI TextField](https://developer.apple.com/documentation/swiftui/textfield)
- [SwiftUI Focus State](https://developer.apple.com/documentation/swiftui/focusstate)
