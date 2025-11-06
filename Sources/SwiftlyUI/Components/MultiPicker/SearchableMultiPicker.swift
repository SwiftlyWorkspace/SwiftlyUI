import SwiftUI

/// A multi-selection picker with built-in search functionality.
///
/// `SearchableMultiPicker` extends the base `MultiPicker` with search and filter capabilities,
/// making it ideal for large lists where users need to find specific items.
///
/// ## Example
/// ```swift
/// @State private var selection: Set<String> = []
/// @State private var searchText = ""
///
/// SearchableMultiPicker(
///     title: "Select Countries",
///     items: countries.map { (value: $0.id, label: $0.name) },
///     selection: $selection,
///     searchText: $searchText
/// )
/// ```
///
/// ## With Custom Search
/// ```swift
/// SearchableMultiPicker(
///     title: "Select Items",
///     items: items,
///     selection: $selection,
///     searchText: $searchText,
///     searchFilter: { item, query in
///         item.name.localizedCaseInsensitiveContains(query) ||
///         item.description.localizedCaseInsensitiveContains(query)
///     }
/// )
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SearchableMultiPicker<SelectionValue: Hashable>: View {
    // MARK: - Properties

    /// The title/label for the picker.
    let title: String

    /// Array of value-label pairs for the items.
    let items: [(value: SelectionValue, label: String)]

    /// The set of currently selected values.
    @Binding var selection: Set<SelectionValue>

    /// The current search text.
    @Binding var searchText: String

    /// Minimum number of selections required.
    let minSelections: Int

    /// Maximum number of selections allowed (nil = unlimited).
    let maxSelections: Int?

    /// Whether to show select all button.
    let showSelectAll: Bool

    /// Whether to show clear all button.
    let showClearAll: Bool

    /// Whether to require confirmation (Done/Cancel buttons).
    let requiresConfirmation: Bool

    /// Placeholder text for the search field.
    let searchPlaceholder: String

    /// Custom search filter function (optional).
    let searchFilter: (((value: SelectionValue, label: String), String) -> Bool)?

    @Environment(\.multiPickerStyle) private var style

    // MARK: - Initializers

    /// Creates a searchable multi-picker.
    /// - Parameters:
    ///   - title: Title for the picker.
    ///   - items: Array of value-label pairs.
    ///   - selection: Binding to the set of selected values.
    ///   - searchText: Binding to the search text.
    ///   - minSelections: Minimum selections required (default: 0).
    ///   - maxSelections: Maximum selections allowed (default: nil/unlimited).
    ///   - showSelectAll: Whether to show select all button (default: false).
    ///   - showClearAll: Whether to show clear all button (default: false).
    ///   - requiresConfirmation: Whether to require confirmation (default: false).
    ///   - searchPlaceholder: Placeholder text for search (default: "Search...").
    ///   - searchFilter: Custom filter function (default: case-insensitive label search).
    public init(
        title: String,
        items: [(value: SelectionValue, label: String)],
        selection: Binding<Set<SelectionValue>>,
        searchText: Binding<String>,
        minSelections: Int = 0,
        maxSelections: Int? = nil,
        showSelectAll: Bool = false,
        showClearAll: Bool = false,
        requiresConfirmation: Bool = false,
        searchPlaceholder: String = "Search...",
        searchFilter: (((value: SelectionValue, label: String), String) -> Bool)? = nil
    ) {
        self.title = title
        self.items = items
        self._selection = selection
        self._searchText = searchText
        self.minSelections = minSelections
        self.maxSelections = maxSelections
        self.showSelectAll = showSelectAll
        self.showClearAll = showClearAll
        self.requiresConfirmation = requiresConfirmation
        self.searchPlaceholder = searchPlaceholder
        self.searchFilter = searchFilter
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            // Search field
            searchField

            Divider()

            // Picker content with filtered items
            MultiPicker(
                title: title,
                items: filteredItems,
                selection: $selection,
                minSelections: minSelections,
                maxSelections: maxSelections,
                showSelectAll: showSelectAll,
                showClearAll: showClearAll,
                requiresConfirmation: requiresConfirmation
            )

            // Empty state for no results
            if filteredItems.isEmpty && !searchText.isEmpty {
                emptyState
            }
        }
    }

    // MARK: - Private Computed Properties

    /// Items filtered by search text.
    private var filteredItems: [(value: SelectionValue, label: String)] {
        guard !searchText.isEmpty else { return items }

        if let customFilter = searchFilter {
            return items.filter { customFilter($0, searchText) }
        } else {
            // Default filter: case-insensitive search in label
            let query = searchText.lowercased()
            return items.filter { $0.label.lowercased().contains(query) }
        }
    }

    // MARK: - Private Views

    /// Search field view.
    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)

            TextField(searchPlaceholder, text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.controlBackground.opacity(0.5))
    }

    /// Empty state when no results found.
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No results found")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Preview

#Preview("Searchable MultiPicker") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []
        @State private var searchText = ""

        let items = [
            "Apple", "Banana", "Cherry", "Date", "Elderberry",
            "Fig", "Grape", "Honeydew", "Ice Cream Bean", "Jackfruit",
            "Kiwi", "Lemon", "Mango", "Nectarine", "Orange",
            "Papaya", "Quince", "Raspberry", "Strawberry", "Tangerine"
        ].map { (value: $0, label: $0) }

        var body: some View {
            NavigationStack {
                SearchableMultiPicker(
                    title: "Select Fruits",
                    items: items,
                    selection: $selection,
                    searchText: $searchText,
                    showSelectAll: true,
                    showClearAll: true
                )
                .navigationTitle("Demo")
            }
        }
    }

    return PreviewWrapper()
}
