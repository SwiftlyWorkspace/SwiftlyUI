import SwiftUI

/// A customizable token-based input field for selecting users from a list.
///
/// `UserTokenField` provides search and selection functionality for users with features like:
/// - Search by name or email with auto-complete
/// - Avatar display with automatic initials fallback
/// - Support for both Image and URL-based avatars
/// - Maximum user limits
/// - Keyboard navigation
/// - Cross-platform compatibility
///
/// The component is generic and works with any type conforming to `UserRepresentable`,
/// allowing you to use your existing user models.
///
/// ## Example with SwiftlyUIUser
/// ```swift
/// @State private var selectedUsers: [SwiftlyUIUser] = []
/// @State private var searchText = ""
///
/// let availableUsers = [
///     SwiftlyUIUser(firstName: "John", lastName: "Doe", email: "john@example.com"),
///     SwiftlyUIUser(firstName: "Jane", lastName: "Smith", email: "jane@example.com")
/// ]
///
/// UserTokenField(
///     selectedUsers: $selectedUsers,
///     searchText: $searchText,
///     availableUsers: availableUsers,
///     onAdd: { user in selectedUsers.append(user) },
///     onRemove: { user in selectedUsers.removeAll { $0.id == user.id } }
/// )
/// ```
///
/// ## Example with Custom User Type
/// ```swift
/// struct MyUser: UserRepresentable {
///     let id: UUID
///     let firstName: String
///     let lastName: String
///     let email: String
///     var avatarURL: URL?
///     var avatarImage: Image?
/// }
///
/// @State private var selectedUsers: [MyUser] = []
/// @State private var searchText = ""
///
/// UserTokenField(
///     selectedUsers: $selectedUsers,
///     searchText: $searchText,
///     availableUsers: allUsers,
///     onAdd: { user in selectedUsers.append(user) },
///     onRemove: { user in selectedUsers.removeAll { $0.id == user.id } }
/// )
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct UserTokenField<User: UserRepresentable>: View {
    // MARK: - Properties

    /// The current array of selected users.
    @Binding var selectedUsers: [User]

    /// The current search text.
    @Binding var searchText: String

    /// Array of all available users to search from.
    let availableUsers: [User]

    /// Maximum number of users allowed.
    let maxUsers: Int

    /// Placeholder text for the search field.
    let placeholder: String

    /// Callback triggered when a user is added.
    let onAdd: (User) -> Void

    /// Callback triggered when a user is removed.
    let onRemove: (User) -> Void

    @State private var showSuggestions = false
    @FocusState private var isInputFocused: Bool

    // MARK: - Initializers

    /// Creates a new user token field.
    /// - Parameters:
    ///   - selectedUsers: Binding to the current array of selected users.
    ///   - searchText: Binding to the current search text.
    ///   - availableUsers: Array of all available users to search from.
    ///   - maxUsers: Maximum number of users allowed. Defaults to 10.
    ///   - placeholder: Placeholder text for the search field. Defaults to "Search users...".
    ///   - onAdd: Callback triggered when a user is added.
    ///   - onRemove: Callback triggered when a user is removed.
    public init(
        selectedUsers: Binding<[User]>,
        searchText: Binding<String>,
        availableUsers: [User],
        maxUsers: Int = 10,
        placeholder: String = "Search users...",
        onAdd: @escaping (User) -> Void,
        onRemove: @escaping (User) -> Void
    ) {
        self._selectedUsers = selectedUsers
        self._searchText = searchText
        self.availableUsers = availableUsers
        self.maxUsers = maxUsers
        self.placeholder = placeholder
        self.onAdd = onAdd
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            userInputArea
            selectionInfo
            suggestionsView
        }
    }

    // MARK: - Private Computed Properties

    /// Filtered users based on the current search text.
    private var filteredUsers: [User] {
        guard !searchText.isEmpty else { return [] }

        let searchLower = searchText.lowercased()
        return availableUsers.filter { user in
            // Exclude already selected users
            let isNotSelected = !selectedUsers.contains(where: { $0.id == user.id })

            // Search in firstName, lastName, displayName, or email
            let matchesSearch = (user.firstName?.lowercased().contains(searchLower) ?? false) ||
                               (user.lastName?.lowercased().contains(searchLower) ?? false) ||
                               user.displayName.lowercased().contains(searchLower) ||
                               user.email.lowercased().contains(searchLower)

            return isNotSelected && matchesSearch
        }
    }

    // MARK: - Private Views

    /// The main input area containing user chips and the search field.
    @ViewBuilder
    private var userInputArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !selectedUsers.isEmpty {
                FlowLayout(spacing: 6) {
                    userChips
                }
            }

            searchField
        }
        .padding(8)
        .background(Color.textBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.separator, lineWidth: 1)
        )
    }

    /// The individual user chips.
    @ViewBuilder
    private var userChips: some View {
        ForEach(Array(selectedUsers.enumerated()), id: \.element.id) { index, user in
            UserChip(
                user: user,
                onRemove: { onRemove(user) }
            )
        }
    }

    /// The search input field.
    @ViewBuilder
    private var searchField: some View {
        if selectedUsers.count < maxUsers {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $searchText)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 120)
                    .focused($isInputFocused)
                    .onChange(of: searchText) { newValue in
                        showSuggestions = !newValue.isEmpty && !filteredUsers.isEmpty
                    }
                    .accessibilityLabel("Search for users")
            }
            .frame(height: 32)
            .padding(.horizontal, 12)
            .background(Color.controlBackground)
            .cornerRadius(20)
        }
    }

    /// Selection info and warning messages.
    @ViewBuilder
    private var selectionInfo: some View {
        HStack {
            if selectedUsers.count > 0 {
                Text("\(selectedUsers.count) of \(maxUsers) users selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if selectedUsers.count >= maxUsers {
                Text("Maximum users reached")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    /// The suggestions dropdown view.
    @ViewBuilder
    private var suggestionsView: some View {
        if showSuggestions {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(filteredUsers.prefix(5).enumerated()), id: \.element.id) { index, user in
                    Button {
                        selectUser(user)
                    } label: {
                        HStack(spacing: 12) {
                            // Avatar preview
                            miniAvatarView(for: user)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName)
                                    .foregroundStyle(.primary)
                                    .font(.subheadline)

                                Text(user.email)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < filteredUsers.prefix(5).count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color.controlBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.separator, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }

    /// Mini avatar view for suggestions dropdown
    @ViewBuilder
    private func miniAvatarView(for user: User) -> some View {
        if let avatarImage = user.avatarImage {
            avatarImage
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Circle()
                    .fill(user.avatarColor)

                Text(user.initials)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Private Methods

    /// Selects a user and adds them to the selected users array.
    /// - Parameter user: The user to select.
    private func selectUser(_ user: User) {
        guard selectedUsers.count < maxUsers else { return }

        // Check for duplicates (should not happen due to filtering, but safety check)
        guard !selectedUsers.contains(where: { $0.id == user.id }) else { return }

        onAdd(user)
        searchText = ""
        showSuggestions = false
    }
}
