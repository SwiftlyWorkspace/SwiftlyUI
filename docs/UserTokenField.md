# UserTokenField

A customizable token-based input field for selecting users from a list with search, avatars, and multi-select support.

## Overview

`UserTokenField` provides a rich interface for selecting users with real-time search, avatar display, and automatic initials fallback. The component is generic and works with any type conforming to `UserRepresentable`, allowing you to use your existing user models seamlessly.

### Key Features

- 🔍 **Smart Search** - Real-time filtering by name and email
- 👤 **Avatar Support** - Three modes: SwiftUI Image, URL, or initials fallback
- 🎨 **Automatic Colors** - Consistent avatar colors based on user ID
- 💡 **Auto-completion** - Dropdown suggestions as you type
- 🚫 **Duplicate Prevention** - Automatically filters selected users
- 📏 **User Limits** - Set maximum number of users
- ⌨️ **Keyboard Navigation** - Full keyboard support
- 🔧 **Generic** - Works with any `UserRepresentable` type
- 📱 **Cross-Platform** - iOS, macOS, tvOS, and watchOS support

## UserRepresentable Protocol

The component works with any type conforming to `UserRepresentable`:

```swift
public protocol UserRepresentable: Identifiable, Sendable {
    var firstName: String? { get }
    var lastName: String? { get }
    var email: String { get }
    var avatarURL: URL? { get }
    var avatarImage: Image? { get }
}
```

### Protocol Extensions

The protocol provides useful computed properties:

```swift
// Full name combining firstName and lastName
var displayName: String  // "John Doe" or email if names are nil

// First letter of firstName + first letter of lastName
var initials: String  // "JD"

// Consistent color based on user ID
var avatarColor: Color  // Used for avatar background
```

## Using SwiftlyUIUser

SwiftlyUI provides a ready-to-use `SwiftlyUIUser` struct:

```swift
import SwiftUI
import SwiftlyUI

struct TeamSelectorView: View {
    @State private var selectedUsers: [SwiftlyUIUser] = []
    @State private var searchText = ""

    let teamMembers = [
        SwiftlyUIUser(firstName: "John", lastName: "Doe", email: "john@example.com"),
        SwiftlyUIUser(firstName: "Jane", lastName: "Smith", email: "jane@example.com"),
        SwiftlyUIUser(email: "bob@example.com") // Names optional
    ]

    var body: some View {
        Form {
            Section("Select Team Members") {
                UserTokenField(
                    selectedUsers: $selectedUsers,
                    searchText: $searchText,
                    availableUsers: teamMembers,
                    onAdd: { user in
                        selectedUsers.append(user)
                    },
                    onRemove: { user in
                        selectedUsers.removeAll { $0.id == user.id }
                    }
                )
            }
        }
    }
}
```

## Using Custom User Types

Conform your existing user model to `UserRepresentable`:

```swift
struct MyUser: UserRepresentable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let email: String
    var avatarURL: URL?
    var avatarImage: Image?

    // Your additional properties
    let role: String
    let department: String
}

struct UserPickerView: View {
    @State private var selected: [MyUser] = []
    @State private var searchText = ""

    let users: [MyUser] = loadUsersFromDatabase()

    var body: some View {
        UserTokenField(
            selectedUsers: $selected,
            searchText: $searchText,
            availableUsers: users,
            maxUsers: 5,
            placeholder: "Search by name or email...",
            onAdd: { user in
                selected.append(user)
                saveToDatabase(user)
            },
            onRemove: { user in
                selected.removeAll { $0.id == user.id }
                removeFromDatabase(user)
            }
        )
    }
}
```

## Avatar Handling

The component supports three avatar modes with automatic fallback:

### 1. SwiftUI Image (Highest Priority)

```swift
let user = SwiftlyUIUser(
    firstName: "John",
    lastName: "Doe",
    email: "john@example.com",
    avatarImage: Image(systemName: "person.circle.fill")
)
```

### 2. URL-based (Second Priority)

```swift
let user = SwiftlyUIUser(
    firstName: "Jane",
    lastName: "Smith",
    email: "jane@example.com",
    avatarURL: URL(string: "https://example.com/avatars/jane.jpg")
)
```

**Note:** URL-based avatars use SwiftUI's `AsyncImage` for automatic loading.

### 3. Initials Fallback (Default)

When no image or URL is provided:

```swift
let user = SwiftlyUIUser(
    firstName: "Bob",
    lastName: "Johnson",
    email: "bob@example.com"
)
// Displays "BJ" on colored background
```

**Initials Generation:**
- "John Doe" → "JD"
- "Jane Smith" → "JS"
- nil, nil (email: "john@example.com") → "JO" (from email)
- Empty email → "?"

**Colors:** Automatically assigned based on user ID (consistent across app).

## Search Functionality

The component searches across multiple fields:

```swift
// Searches in:
// - firstName (case-insensitive)
// - lastName (case-insensitive)
// - displayName (full name)
// - email

// Examples:
searchText = "john" → Matches "John Doe" or "john@example.com"
searchText = "doe" → Matches "John Doe"
searchText = "@example" → Matches any email with "@example"
```

### Search Behavior

- **Real-time filtering** - Updates as you type
- **Case-insensitive** - "JOHN" matches "John"
- **Excludes selected** - Already-selected users don't appear
- **Shows up to 5 results** - Prevents overwhelming dropdown
- **Auto-dismisses** - Closes when user selected or field cleared

## Selection Management

### Adding Users

Users are added when clicked in the dropdown:

```swift
UserTokenField(
    selectedUsers: $selected,
    searchText: $searchText,
    availableUsers: allUsers,
    onAdd: { user in
        // Add to your data model
        selected.append(user)

        // Optional: Track analytics
        analytics.log("user_added", userId: user.id)

        // Optional: Save to database
        saveSelection(user)
    },
    onRemove: { /* ... */ }
)
```

### Removing Users

Users are removed when clicking the X button on their chip:

```swift
UserTokenField(
    selectedUsers: $selected,
    searchText: $searchText,
    availableUsers: allUsers,
    onAdd: { /* ... */ },
    onRemove: { user in
        // Remove from your data model
        selected.removeAll { $0.id == user.id }

        // Optional: Update database
        removeSelection(user)
    }
)
```

### User Limits

Set a maximum number of users:

```swift
UserTokenField(
    selectedUsers: $selected,
    searchText: $searchText,
    availableUsers: allUsers,
    maxUsers: 3,  // Limit to 3 users
    onAdd: { selected.append($0) },
    onRemove: { selected.removeAll { $0.id == $1.id } }
)
```

**Behavior:**
- Search field disappears when limit reached
- Warning message: "Maximum users reached"
- Cannot add more until one is removed
- Remove functionality still works

## API Reference

### UserTokenField Initializer

```swift
public init(
    selectedUsers: Binding<[User]>,
    searchText: Binding<String>,
    availableUsers: [User],
    maxUsers: Int = 10,
    placeholder: String = "Search users...",
    onAdd: @escaping (User) -> Void,
    onRemove: @escaping (User) -> Void
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selectedUsers` | `Binding<[User]>` | Required | Binding to selected users array |
| `searchText` | `Binding<String>` | Required | Binding to search text |
| `availableUsers` | `[User]` | Required | Array of all available users |
| `maxUsers` | `Int` | `10` | Maximum number of users allowed |
| `placeholder` | `String` | `"Search users..."` | Placeholder text for search field |
| `onAdd` | `(User) -> Void` | Required | Callback when user is added |
| `onRemove` | `(User) -> Void` | Required | Callback when user is removed |

### UserRepresentable Protocol

```swift
public protocol UserRepresentable: Identifiable, Sendable {
    var firstName: String? { get }
    var lastName: String? { get }
    var email: String { get }
    var avatarURL: URL? { get }
    var avatarImage: Image? { get }
}
```

### Computed Properties

```swift
var displayName: String  // Full name or email
var initials: String     // Two-character initials
var avatarColor: Color   // Consistent color based on ID
```

## Complete Examples

### Project Collaborators

```swift
struct ProjectCollaboratorsView: View {
    @State private var collaborators: [SwiftlyUIUser] = []
    @State private var searchText = ""
    @State private var showAlert = false

    let projectId: UUID
    let allUsers: [SwiftlyUIUser] = fetchAllUsers()

    var body: some View {
        Form {
            Section("Collaborators") {
                UserTokenField(
                    selectedUsers: $collaborators,
                    searchText: $searchText,
                    availableUsers: allUsers,
                    maxUsers: 5,
                    placeholder: "Add collaborator...",
                    onAdd: { user in
                        collaborators.append(user)
                        addCollaborator(projectId: projectId, user: user)
                        showAlert = true
                    },
                    onRemove: { user in
                        collaborators.removeAll { $0.id == user.id }
                        removeCollaborator(projectId: projectId, user: user)
                    }
                )
            }

            Section("Current Collaborators") {
                if collaborators.isEmpty {
                    Text("No collaborators yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(collaborators) { user in
                        HStack {
                            Text(user.displayName)
                            Spacer()
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .alert("Collaborator Added", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
```

### Email Recipients

```swift
struct ComposeEmailView: View {
    @State private var toRecipients: [SwiftlyUIUser] = []
    @State private var ccRecipients: [SwiftlyUIUser] = []
    @State private var toSearchText = ""
    @State private var ccSearchText = ""
    @State private var subject = ""
    @State private var body = ""

    let contacts: [SwiftlyUIUser] = loadContacts()

    var body: some View {
        NavigationStack {
            Form {
                Section("To") {
                    UserTokenField(
                        selectedUsers: $toRecipients,
                        searchText: $toSearchText,
                        availableUsers: contacts,
                        placeholder: "Add recipients...",
                        onAdd: { toRecipients.append($0) },
                        onRemove: { toRecipients.removeAll { $0.id == $1.id } }
                    )
                }

                Section("CC") {
                    UserTokenField(
                        selectedUsers: $ccRecipients,
                        searchText: $ccSearchText,
                        availableUsers: contacts,
                        placeholder: "Add CC...",
                        onAdd: { ccRecipients.append($0) },
                        onRemove: { ccRecipients.removeAll { $0.id == $1.id } }
                    )
                }

                Section("Message") {
                    TextField("Subject", text: $subject)
                    TextEditor(text: $body)
                        .frame(height: 200)
                }

                Section {
                    Button("Send") {
                        sendEmail()
                    }
                    .disabled(toRecipients.isEmpty || subject.isEmpty)
                }
            }
            .navigationTitle("New Email")
        }
    }

    func sendEmail() {
        // Send email logic
    }
}
```

### Task Assignment

```swift
struct TaskAssignmentView: View {
    @State private var assignees: [TeamMember] = []
    @State private var searchText = ""

    let task: Task
    let teamMembers: [TeamMember] = fetchTeamMembers()

    var body: some View {
        Form {
            Section("Assign Task") {
                UserTokenField(
                    selectedUsers: $assignees,
                    searchText: $searchText,
                    availableUsers: teamMembers,
                    maxUsers: 3,
                    placeholder: "Search team members...",
                    onAdd: { member in
                        assignees.append(member)
                        notifyUser(member, about: task)
                    },
                    onRemove: { member in
                        assignees.removeAll { $0.id == member.id }
                        unassignTask(task, from: member)
                    }
                )
            }

            Section("Task Details") {
                LabeledContent("Status", value: task.status)
                LabeledContent("Due Date", value: task.dueDate, format: .dateTime)
                LabeledContent("Assignees", value: "\(assignees.count)")
            }
        }
        .navigationTitle("Assign Task")
    }
}

struct TeamMember: UserRepresentable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let email: String
    let avatarURL: URL?
    let avatarImage: Image?
    let role: String
    let department: String
}
```

## Best Practices

### Data Management

✅ **Do:**
- Store selected users in your model layer
- Persist selections to database in callbacks
- Validate user permissions before adding
- Provide all relevant users in availableUsers
- Use maxUsers to prevent overwhelming selections

❌ **Don't:**
- Manipulate selectedUsers outside callbacks
- Set maxUsers too low (< 2) or too high (> 20)
- Include inactive/deleted users in availableUsers
- Forget error handling in callbacks

### User Experience

```swift
// ✅ Good: Clear placeholder and reasonable limit
UserTokenField(
    selectedUsers: $members,
    searchText: $search,
    availableUsers: activeTeamMembers,
    maxUsers: 5,
    placeholder: "Search by name or email...",
    onAdd: { /* ... */ },
    onRemove: { /* ... */ }
)

// ❌ Bad: Vague placeholder and unreasonable limit
UserTokenField(
    selectedUsers: $members,
    searchText: $search,
    availableUsers: allUsers,  // Including inactive
    maxUsers: 100,  // Too many
    placeholder: "Search...",  // Not specific
    onAdd: { /* ... */ },
    onRemove: { /* ... */ }
)
```

### Performance

- Keep availableUsers under 500 users
- For large datasets, consider server-side search
- Use lightweight avatar images
- Avoid heavy computation in callbacks
- Consider lazy loading for 1000+ users

### Avatars

```swift
// ✅ Good: Provide avatars when available
SwiftlyUIUser(
    firstName: "John",
    lastName: "Doe",
    email: "john@example.com",
    avatarURL: userAvatarURL  // Loads asynchronously
)

// ✅ Also good: Initials fallback works well
SwiftlyUIUser(
    firstName: "Jane",
    lastName: "Smith",
    email: "jane@example.com"
    // No avatar - will show "JS" with consistent color
)
```

### Accessibility

- Search field is automatically labeled
- User chips announce user names to screen readers
- Keyboard navigation fully supported
- Avatar colors have sufficient contrast
- Remove buttons are properly labeled

## Common Patterns

### With Roles

```swift
struct RoleBasedSelectorView: View {
    @State private var admins: [SwiftlyUIUser] = []
    @State private var editors: [SwiftlyUIUser] = []
    @State private var adminSearch = ""
    @State private var editorSearch = ""

    let allUsers: [SwiftlyUIUser] = fetchUsers()

    var body: some View {
        Form {
            Section("Administrators") {
                UserTokenField(
                    selectedUsers: $admins,
                    searchText: $adminSearch,
                    availableUsers: allUsers,
                    maxUsers: 3,
                    onAdd: { admins.append($0) },
                    onRemove: { admins.removeAll { $0.id == $1.id } }
                )
            }

            Section("Editors") {
                UserTokenField(
                    selectedUsers: $editors,
                    searchText: $editorSearch,
                    availableUsers: allUsers,
                    maxUsers: 10,
                    onAdd: { editors.append($0) },
                    onRemove: { editors.removeAll { $0.id == $1.id } }
                )
            }
        }
    }
}
```

### With Validation

```swift
struct ValidatedUserSelectorView: View {
    @State private var selected: [SwiftlyUIUser] = []
    @State private var searchText = ""
    @State private var errorMessage: String?

    let allUsers: [SwiftlyUIUser]

    var body: some View {
        VStack {
            UserTokenField(
                selectedUsers: $selected,
                searchText: $searchText,
                availableUsers: allUsers,
                onAdd: { user in
                    if canAddUser(user) {
                        selected.append(user)
                        errorMessage = nil
                    } else {
                        errorMessage = "Cannot add user: insufficient permissions"
                    }
                },
                onRemove: { user in
                    selected.removeAll { $0.id == user.id }
                    errorMessage = nil
                }
            )

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    func canAddUser(_ user: SwiftlyUIUser) -> Bool {
        // Validation logic
        return true
    }
}
```

## Related Components

- **[TokenTagField](TokenTagField.md)** - For tag/label input (not user-specific)
- **[FlowLayout](Layout.md#flowlayout)** - The layout engine used by UserTokenField

## Platform Availability

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
```

## See Also

- [SwiftUI AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage)
- [Identifiable Protocol](https://developer.apple.com/documentation/swift/identifiable)
