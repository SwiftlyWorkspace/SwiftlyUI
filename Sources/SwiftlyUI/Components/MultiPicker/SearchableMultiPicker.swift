import SwiftUI

// MARK: - Internal Types

/// A multi-picker item with value, label, and optional section.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct MultiPickerItem<Value: Hashable>: Equatable {
    let value: Value
    let label: String
    let section: String?

    static func == (lhs: MultiPickerItem<Value>, rhs: MultiPickerItem<Value>) -> Bool {
        lhs.value == rhs.value && lhs.label == rhs.label && lhs.section == rhs.section
    }
}

/// A preference key for collecting multi-picker items from the view hierarchy.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct MultiPickerItemsPreferenceKey<Value: Hashable>: PreferenceKey {
    static var defaultValue: [MultiPickerItem<Value>] { [] }

    static func reduce(value: inout [MultiPickerItem<Value>], nextValue: () -> [MultiPickerItem<Value>]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Environment Key for Section

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct MultiPickerSectionKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var multiPickerSection: String? {
        get { self[MultiPickerSectionKey.self] }
        set { self[MultiPickerSectionKey.self] = newValue }
    }
}

// MARK: - View Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Tags this view with a value for multi-picker item collection.
    /// For Text views in SearchableMultiPicker, this automatically captures the label.
    public func multiPickerTag<Value: Hashable>(_ value: Value) -> some View {
        MultiPickerTagView(value: value, content: self)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct MultiPickerTagView<Value: Hashable, Content: View>: View {
    let value: Value
    let content: Content
    @Environment(\.multiPickerSection) private var section

    var body: some View {
        content.preference(
            key: MultiPickerItemsPreferenceKey<Value>.self,
            value: [MultiPickerItem(value: value, label: "\(value)", section: section)]
        )
    }
}

// MARK: - Section Support

/// A section container for MultiPicker that groups items under a header.
///
/// Use this instead of SwiftUI's `Section` when you want to organize
/// MultiPicker items into sections with headers.
///
/// ## Example
/// ```swift
/// MultiPicker("Choose Foods", selection: $selection) {
///     MultiPickerSection("Fruits") {
///         Text("Apple").multiPickerTag("apple")
///         Text("Banana").multiPickerTag("banana")
///     }
///     MultiPickerSection("Vegetables") {
///         Text("Carrot").multiPickerTag("carrot")
///     }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MultiPickerSection<Content: View>: View {
    let header: String
    let content: Content

    public init(_ header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }

    public var body: some View {
        content.environment(\.multiPickerSection, header)
    }
}

// MARK: - SearchableMultiPicker

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
public struct SearchableMultiPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Properties

    /// The title/label for the picker.
    let title: String

    /// Optional label text for LabeledContent integration.
    let label: String?

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

    /// The content containing the items.
    let content: Content

    @State private var items: [MultiPickerItem<SelectionValue>] = []
    @Environment(\.multiPickerStyle) private var style

    private var itemTuples: [(value: SelectionValue, label: String)] {
        items.map { (value: $0.value, label: $0.label) }
    }

    // MARK: - Initializers

    /// Creates a searchable multi-picker with Picker-style API.
    /// - Parameters:
    ///   - titleKey: Title for the picker (also used as label if no content provided).
    ///   - selection: Binding to the set of selected values.
    ///   - searchText: Binding to the search text.
    ///   - minSelections: Minimum selections required (default: 0).
    ///   - maxSelections: Maximum selections allowed (default: nil/unlimited).
    ///   - showSelectAll: Whether to show select all button (default: false).
    ///   - showClearAll: Whether to show clear all button (default: false).
    ///   - requiresConfirmation: Whether to require confirmation (default: false).
    ///   - searchPlaceholder: Placeholder text for search (default: "Search...").
    ///   - searchFilter: Custom filter function (default: case-insensitive label search).
    ///   - content: ViewBuilder closure containing items with `.tag()` modifiers.
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
    ) {
        self.title = titleKey
        self.label = titleKey
        self._selection = selection
        self._searchText = searchText
        self.minSelections = minSelections
        self.maxSelections = maxSelections
        self.showSelectAll = showSelectAll
        self.showClearAll = showClearAll
        self.requiresConfirmation = requiresConfirmation
        self.searchPlaceholder = searchPlaceholder
        self.searchFilter = searchFilter
        self.content = content()
    }

    // MARK: - Body

    @ViewBuilder
    public var body: some View {
        pickerContent
            .background(
                content
                    .frame(width: 0, height: 0)
                    .hidden()
                    .onPreferenceChange(MultiPickerItemsPreferenceKey<SelectionValue>.self) { collectedItems in
                        items = collectedItems
                    }
            )
    }

    @ViewBuilder
    private var pickerContent: some View {
        // SearchableMultiPicker wraps the entire content (search + picker)
        // in a style configuration. This works for inline/sheet/navigationLink.
        // Note: Menu style is not recommended for SearchableMultiPicker since
        // Menu can't display search fields. Use regular MultiPicker with menu style instead.

        let content = VStack(spacing: 0) {
            // Search field
            searchField

            Divider()

            // Filtered items
            ScrollView {
                VStack(spacing: 0) {
                    // Bulk actions
                    if showSelectAll || showClearAll {
                        bulkActionsBar
                        Divider()
                    }

                    // Items
                    ForEach(Array(filteredItems.enumerated()), id: \.element.value) { _, item in
                        MultiPickerRow(
                            isSelected: selection.contains(item.value),
                            isDisabled: isItemDisabled(item.value),
                            action: { toggleSelection(item.value) }
                        ) {
                            Text(item.label)
                        }
                    }
                }
            }

            // Empty state
            if filteredItems.isEmpty && !searchText.isEmpty {
                emptyState
            }
        }

        // Create label with AdaptiveTokenLayout for selected items
        // Use generic placeholder when wrapping in LabeledContent to avoid duplication
        let selectedLabels = itemTuples.filter { selection.contains($0.value) }.map { $0.label }.sorted()

        let labelView = HStack(spacing: 8) {
            AdaptiveTokenLayout(
                items: selectedLabels,
                placeholder: label != nil ? "Select..." : title
            )

            if selection.count > 0 {
                Text("(\(selection.count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }

        let configuration = MultiPickerStyleConfiguration(
            label: AnyView(labelView),
            content: AnyView(content),
            selectionCount: selection.count,
            selectedItems: selectedLabels,
            requiresConfirmation: requiresConfirmation
        )

        let pickerView = style.makeBody(configuration: configuration)

        // If label is provided, wrap in LabeledContent
        if let labelText = label {
            LabeledContent(labelText) {
                pickerView
            }
        } else {
            pickerView
        }
    }

    // MARK: - Private Views

    /// Bulk actions bar.
    @ViewBuilder
    private var bulkActionsBar: some View {
        HStack(spacing: 16) {
            if showSelectAll {
                Button("Select All") {
                    let availableValues = filteredItems.prefix(
                        maxSelections.map { $0 - selection.count } ?? filteredItems.count
                    ).map(\.value)
                    selection.formUnion(availableValues)
                }
                .disabled(!canSelectAll)
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(canSelectAll ? .blue : .secondary)
            }

            if showClearAll {
                Button("Clear All") {
                    selection.removeAll()
                }
                .disabled(selection.isEmpty)
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(!selection.isEmpty ? .blue : .secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helper Methods

    private func isItemDisabled(_ value: SelectionValue) -> Bool {
        if selection.contains(value) { return false }
        if let max = maxSelections, selection.count >= max { return true }
        return false
    }

    private func toggleSelection(_ value: SelectionValue) {
        if selection.contains(value) {
            if selection.count > minSelections {
                selection.remove(value)
            }
        } else {
            if let max = maxSelections, selection.count >= max {
                return
            }
            selection.insert(value)
        }
    }

    private var canSelectAll: Bool {
        let itemsToSelect = filteredItems.filter { !selection.contains($0.value) }
        if itemsToSelect.isEmpty { return false }
        if let max = maxSelections {
            return selection.count < max
        }
        return true
    }

    // MARK: - Private Computed Properties

    /// Items filtered by search text.
    private var filteredItems: [(value: SelectionValue, label: String)] {
        guard !searchText.isEmpty else { return itemTuples }

        if let customFilter = searchFilter {
            return itemTuples.filter { customFilter($0, searchText) }
        } else {
            // Default filter: case-insensitive search in label
            let query = searchText.lowercased()
            return itemTuples.filter { $0.label.lowercased().contains(query) }
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

// MARK: - Previews

#Preview("Basic Comparison") {
    struct PreviewWrapper: View {
        @State private var singleSelection: String = "Apple"
        @State private var multiSelection: Set<String> = []
        @State private var searchText = ""

        let fruits = [
            "Apple", "Apricot", "Avocado", "Banana", "Blueberry", "Blackberry",
            "Cherry", "Coconut", "Cranberry", "Date", "Dragonfruit", "Elderberry",
            "Fig", "Grape", "Grapefruit", "Guava", "Honeydew", "Huckleberry",
            "Jackfruit", "Kiwi", "Kumquat", "Lemon", "Lime", "Lychee",
            "Mango", "Melon", "Mulberry", "Nectarine", "Orange", "Papaya"
        ]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Standard SwiftUI Picker") {
                        Picker("Single Selection", selection: $singleSelection) {
                            ForEach(fruits, id: \.self) { fruit in
                                Text(fruit).tag(fruit)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)


                    Section("Searchable MultiPicker") {
                        SearchableMultiPicker(
                            "Multiple Selection",
                            selection: $multiSelection,
                            searchText: $searchText
                        ) {
                            ForEach(fruits, id: \.self) { fruit in
                                Text(fruit).multiPickerTag(fruit)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }
                    Section("Selected Fruits") {
                        if multiSelection.isEmpty {
                            Text("None selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(multiSelection.sorted()), id: \.self) { fruit in
                                Text(fruit)
                            }
                        }
                    }
                }
                .navigationTitle("Picker Comparison")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Different Styles") {
    struct PreviewWrapper: View {
        @State private var inlineSelection: Set<String> = []
        @State private var inlineSearchText = ""
        @State private var navigationSelection: Set<String> = []
        @State private var navigationSearchText = ""
        @State private var sheetSelection: Set<String> = []
        @State private var sheetSearchText = ""
        @State private var menuSelection: Set<String> = []
        @State private var menuSearchText = ""

        let countries = [
            "Argentina", "Australia", "Brazil", "Canada", "China", "Egypt",
            "France", "Germany", "India", "Italy", "Japan", "Mexico",
            "Netherlands", "Norway", "Portugal", "Russia", "Spain", "Sweden",
            "Switzerland", "United Kingdom", "United States"
        ]

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 30) {
                        // Inline Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Inline Style")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Displays items directly with inline search. Best for small to medium lists.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            SearchableMultiPicker(
                                "Select Countries",
                                selection: $inlineSelection,
                                searchText: $inlineSearchText
                            ) {
                                ForEach(countries, id: \.self) { country in
                                    Text(country).multiPickerTag(country)
                                }
                            }
                            .multiPickerStyle(.inline)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Divider()

                        // Navigation Link Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Navigation Link Style")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Pushes to a new screen with search at the top. Good for longer lists.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            SearchableMultiPicker(
                                "Select Countries",
                                selection: $navigationSelection,
                                searchText: $navigationSearchText
                            ) {
                                ForEach(countries, id: \.self) { country in
                                    Text(country).multiPickerTag(country)
                                }
                            }
                            .multiPickerStyle(.navigationLink)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Divider()

                        // Sheet Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sheet Style")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Presents items in a modal sheet with search. Great for focused selection.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            SearchableMultiPicker(
                                "Select Countries",
                                selection: $sheetSelection,
                                searchText: $sheetSearchText
                            ) {
                                ForEach(countries, id: \.self) { country in
                                    Text(country).multiPickerTag(country)
                                }
                            }
                            .multiPickerStyle(.sheet)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Divider()

                        // Menu Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Menu Style")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Shows items in a popover menu with search. Compact and efficient.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            SearchableMultiPicker(
                                "Select Countries",
                                selection: $menuSelection,
                                searchText: $menuSearchText
                            ) {
                                ForEach(countries, id: \.self) { country in
                                    Text(country).multiPickerTag(country)
                                }
                            }
                            .multiPickerStyle(.menu)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Picker Styles")
            }
            .padding()
            .frame(minHeight: 800)
        }
    }

    return PreviewWrapper()
}

#Preview("With Bulk Actions") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []
        @State private var searchText = ""

        let programming = [
            "C", "C++", "C#", "Go", "Java", "JavaScript", "Kotlin",
            "Objective-C", "PHP", "Python", "Ruby", "Rust", "Scala",
            "Swift", "TypeScript", "WebAssembly"
        ]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Programming Languages") {
                        SearchableMultiPicker(
                            "Select Languages",
                            selection: $selection,
                            searchText: $searchText,
                            showSelectAll: true,
                            showClearAll: true
                        ) {
                            ForEach(programming, id: \.self) { lang in
                                Text(lang).multiPickerTag(lang)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Selection Summary") {
                        HStack {
                            Text("Selected:")
                            Spacer()
                            Text("\(selection.count) of \(programming.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle("Bulk Actions")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Selection Limits") {
    struct PreviewWrapper: View {
        @State private var minSelection: Set<String> = []
        @State private var minSearchText = ""
        @State private var maxSelection: Set<String> = []
        @State private var maxSearchText = ""
        @State private var rangeSelection: Set<String> = []
        @State private var rangeSearchText = ""

        let colors = [
            "Amber", "Blue", "Brown", "Cyan", "Green", "Indigo",
            "Magenta", "Orange", "Pink", "Purple", "Red", "Teal",
            "Violet", "Yellow"
        ]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Minimum 2 Required") {
                        SearchableMultiPicker(
                            "Choose Colors",
                            selection: $minSelection,
                            searchText: $minSearchText,
                            minSelections: 2
                        ) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).multiPickerTag(color)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Maximum 4 Allowed") {
                        SearchableMultiPicker(
                            "Choose Colors",
                            selection: $maxSelection,
                            searchText: $maxSearchText,
                            maxSelections: 4
                        ) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).multiPickerTag(color)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("3-5 Required") {
                        SearchableMultiPicker(
                            "Choose Colors",
                            selection: $rangeSelection,
                            searchText: $rangeSearchText,
                            minSelections: 3,
                            maxSelections: 5,
                            showSelectAll: true,
                            showClearAll: true
                        ) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).multiPickerTag(color)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }
                }
                .navigationTitle("Selection Limits")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("With Confirmation") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []
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
                    Section("Select Destinations") {
                        SearchableMultiPicker(
                            "European Cities",
                            selection: $selection,
                            searchText: $searchText,
                            minSelections: 1,
                            maxSelections: 5,
                            showSelectAll: true,
                            showClearAll: true,
                            requiresConfirmation: true
                        ) {
                            ForEach(cities, id: \.self) { city in
                                Text(city).multiPickerTag(city)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Confirmed Destinations") {
                        if selection.isEmpty {
                            Text("No destinations selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selection.sorted()), id: \.self) { city in
                                Label(city, systemImage: "location.fill")
                            }
                        }
                    }
                }
                .navigationTitle("Confirmation Mode")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("LabeledContent Integration") {
    struct PreviewWrapper: View {
        @State private var fruits: Set<String> = ["Apple"]
        @State private var fruitsSearch = ""
        @State private var vegetables: Set<String> = ["Carrot", "Broccoli"]
        @State private var vegetablesSearch = ""
        @State private var proteins: Set<String> = []
        @State private var proteinsSearch = ""

        let fruitOptions = [
            "Apple", "Banana", "Cherry", "Date", "Elderberry",
            "Fig", "Grape", "Kiwi", "Lemon", "Mango"
        ]

        let vegetableOptions = [
            "Asparagus", "Broccoli", "Carrot", "Celery", "Cucumber",
            "Eggplant", "Kale", "Lettuce", "Spinach", "Tomato"
        ]

        let proteinOptions = [
            "Beef", "Chicken", "Eggs", "Fish", "Lentils",
            "Pork", "Salmon", "Tofu", "Turkey", "Tuna"
        ]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Meal Planning") {
                        LabeledContent("Fruits") {
                            SearchableMultiPicker(
                                "Select Fruits",
                                selection: $fruits,
                                searchText: $fruitsSearch
                            ) {
                                ForEach(fruitOptions, id: \.self) { fruit in
                                    Text(fruit).multiPickerTag(fruit)
                                }
                            }
                            .multiPickerStyle(.menu)
                        }

                        LabeledContent("Vegetables") {
                            SearchableMultiPicker(
                                "Select Vegetables",
                                selection: $vegetables,
                                searchText: $vegetablesSearch,
                                minSelections: 1
                            ) {
                                ForEach(vegetableOptions, id: \.self) { veg in
                                    Text(veg).multiPickerTag(veg)
                                }
                            }
                            .multiPickerStyle(.menu)
                        }

                        LabeledContent("Proteins") {
                            SearchableMultiPicker(
                                "Select Proteins",
                                selection: $proteins,
                                searchText: $proteinsSearch,
                                maxSelections: 3
                            ) {
                                ForEach(proteinOptions, id: \.self) { protein in
                                    Text(protein).multiPickerTag(protein)
                                }
                            }
                            .multiPickerStyle(.menu)
                        }
                    }

                    Section("Total Selections") {
                        HStack {
                            Text("Items selected:")
                            Spacer()
                            Text("\(fruits.count + vegetables.count + proteins.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle("Meal Planner")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Custom Search Filter") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []
        @State private var searchText = ""

        // Items with both name and category for custom search
        let items = [
            "Swift - Programming Language",
            "Python - Programming Language",
            "JavaScript - Programming Language",
            "Xcode - Development Tool",
            "VS Code - Development Tool",
            "Git - Version Control",
            "Docker - Container Platform",
            "Kubernetes - Orchestration",
            "React - Frontend Framework",
            "SwiftUI - UI Framework"
        ]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Developer Tools & Languages") {
                        SearchableMultiPicker(
                            "Select Technologies",
                            selection: $selection,
                            searchText: $searchText,
                            searchPlaceholder: "Search by name or category...",
                            searchFilter: { item, query in
                                // Custom filter that searches both parts
                                item.label.localizedCaseInsensitiveContains(query)
                            }
                        ) {
                            ForEach(items, id: \.self) { item in
                                Text(item).multiPickerTag(item)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Your Stack") {
                        if selection.isEmpty {
                            Text("No technologies selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selection.sorted()), id: \.self) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    let parts = item.split(separator: " - ")
                                    if parts.count == 2 {
                                        Text(String(parts[0]))
                                            .font(.headline)
                                        Text(String(parts[1]))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text(item)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Custom Search")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
