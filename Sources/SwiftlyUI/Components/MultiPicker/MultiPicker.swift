import SwiftUI

/// A multi-selection picker component that allows selecting multiple items from a list.
///
/// `MultiPicker` provides a customizable interface for multi-selection with features including:
/// - Multiple presentation styles (inline, navigation, sheet, menu)
/// - Selection limits (minimum and maximum)
/// - Bulk actions (select all, clear all)
/// - Customizable selection display
/// - Cross-platform support
///
/// ## Basic Example
/// ```swift
/// @State private var selection: Set<String> = []
///
/// MultiPicker("Choose Options", selection: $selection) {
///     Text("Option 1").multiPickerTag("opt1")
///     Text("Option 2").multiPickerTag("opt2")
///     Text("Option 3").multiPickerTag("opt3")
/// }
/// ```
///
/// ## With Selection Limits
/// ```swift
/// MultiPicker("Choose 2-4 Options", selection: $selection, minSelections: 2, maxSelections: 4) {
///     ForEach(options, id: \.self) { option in
///         Text(option).multiPickerTag(option)
///     }
/// }
/// ```
///
/// ## Custom Style
/// ```swift
/// MultiPicker("Options", selection: $selection) {
///     ForEach(items, id: \.self) { item in
///         Text(item).multiPickerTag(item)
///     }
/// }
/// .multiPickerStyle(.navigationLink)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MultiPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Properties

    /// The title/label for the picker.
    let title: String

    /// The set of currently selected values.
    @Binding var selection: Set<SelectionValue>

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

    /// The content containing the items.
    let content: Content

    /// Temporary selection in confirmation mode.
    @State private var temporarySelection: Set<SelectionValue>?

    /// Collected items from content.
    @State private var items: [MultiPickerItem<SelectionValue>] = []

    @Environment(\.multiPickerStyle) private var style

    private var itemTuples: [(value: SelectionValue, label: String)] {
        items.map { (value: $0.value, label: $0.label) }
    }

    /// Grouped items by section
    private var groupedItems: [(section: String?, items: [MultiPickerItem<SelectionValue>])] {
        let sections = Dictionary(grouping: items) { $0.section }

        // Sort: nil section first, then alphabetically
        let sortedKeys = sections.keys.sorted { lhs, rhs in
            if lhs == nil { return true }
            if rhs == nil { return false }
            return lhs! < rhs!
        }

        return sortedKeys.map { section in
            (section: section, items: sections[section] ?? [])
        }
    }

    /// Whether the items have any sections
    private var hasSections: Bool {
        items.contains { $0.section != nil }
    }

    // MARK: - Initializers

    /// Creates a multi-picker with Picker-style API.
    /// - Parameters:
    ///   - titleKey: Title for the picker.
    ///   - selection: Binding to the set of selected values.
    ///   - minSelections: Minimum selections required (default: 0).
    ///   - maxSelections: Maximum selections allowed (default: nil/unlimited).
    ///   - showSelectAll: Whether to show select all button (default: false).
    ///   - showClearAll: Whether to show clear all button (default: false).
    ///   - requiresConfirmation: Whether to require confirmation (default: false).
    ///   - content: ViewBuilder closure containing items with `.multiPickerTag()` modifiers.
    public init(
        _ titleKey: String,
        selection: Binding<Set<SelectionValue>>,
        minSelections: Int = 0,
        maxSelections: Int? = nil,
        showSelectAll: Bool = false,
        showClearAll: Bool = false,
        requiresConfirmation: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = titleKey
        self._selection = selection
        self.minSelections = max(0, minSelections)
        self.maxSelections = maxSelections.map { max(1, $0) }
        self.showSelectAll = showSelectAll
        self.showClearAll = showClearAll
        self.requiresConfirmation = requiresConfirmation
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
        let selectedLabels = itemTuples
            .filter { activeSelection.contains($0.value) }
            .map { $0.label }
            .sorted()

        let labelView = HStack(spacing: 8) {
            AdaptiveTokenLayout(
                items: selectedLabels,
                placeholder: title
            )

            if activeSelection.count > 0 {
                Text("(\(activeSelection.count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }

        let configuration = MultiPickerStyleConfiguration(
            label: AnyView(labelView),
            content: AnyView(mainPickerContent),
            selectionCount: activeSelection.count,
            selectedItems: selectedLabels,
            requiresConfirmation: requiresConfirmation
        )

        style.makeBody(configuration: configuration)
            .onAppear {
                if requiresConfirmation {
                    temporarySelection = selection
                }
            }
    }

    // MARK: - Private Computed Properties

    /// The active selection (temporary in confirmation mode, otherwise actual).
    private var activeSelection: Set<SelectionValue> {
        requiresConfirmation ? (temporarySelection ?? selection) : selection
    }

    /// Whether an item can be selected (considering max limit).
    private func canSelectItem(withValue value: SelectionValue) -> Bool {
        guard let max = maxSelections else { return true }
        return activeSelection.contains(value) || activeSelection.count < max
    }

    // MARK: - Private Views

    /// The main picker content view.
    @ViewBuilder
    private var mainPickerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bulk action buttons
            if showSelectAll || showClearAll {
                bulkActionsBar
                Divider()
            }

            // Items list
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if hasSections {
                        // Render with sections
                        ForEach(Array(groupedItems.enumerated()), id: \.offset) { sectionIndex, group in
                            // Section header
                            if let sectionHeader = group.section {
                                Text(sectionHeader)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.secondary.opacity(0.1))
                            }

                            // Section items
                            ForEach(Array(group.items.enumerated()), id: \.offset) { itemIndex, item in
                                itemRow(for: (value: item.value, label: item.label))

                                if itemIndex < group.items.count - 1 {
                                    Divider()
                                        .padding(.leading, 48)
                                }
                            }

                            // Divider between sections
                            if sectionIndex < groupedItems.count - 1 {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    } else {
                        // Render flat list
                        ForEach(Array(itemTuples.enumerated()), id: \.offset) { index, item in
                            itemRow(for: item)

                            if index < itemTuples.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                }
            }

            // Validation messages
            if minSelections > 0 || maxSelections != nil {
                Divider()
                validationBar
            }

            // Confirmation buttons
            if requiresConfirmation {
                Divider()
                confirmationBar
            }
        }
    }

    /// Bulk actions bar (select all, clear all).
    @ViewBuilder
    private var bulkActionsBar: some View {
        HStack(spacing: 16) {
            if showSelectAll {
                Button("Select All") {
                    selectAll()
                }
                .disabled(isSelectAllDisabled)
            }

            if showClearAll {
                Button("Clear All") {
                    clearAll()
                }
                .disabled(activeSelection.isEmpty)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.controlBackground.opacity(0.5))
    }

    /// Validation messages bar.
    @ViewBuilder
    private var validationBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let max = maxSelections, activeSelection.count >= max {
                Label("Maximum \(max) selections reached", systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if activeSelection.count < minSelections {
                Label("Select at least \(minSelections) items", systemImage: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.controlBackground.opacity(0.3))
    }

    /// Confirmation buttons bar (Apply/Cancel).
    @ViewBuilder
    private var confirmationBar: some View {
        HStack {
            Button("Cancel") {
                temporarySelection = selection
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Apply") {
                commitSelection()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValidSelection)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.controlBackground.opacity(0.5))
    }

    /// Individual item row.
    @ViewBuilder
    private func itemRow(for item: (value: SelectionValue, label: String)) -> some View {
        let isSelected = activeSelection.contains(item.value)
        let isDisabled = !canSelectItem(withValue: item.value) && !isSelected

        MultiPickerRow(
            isSelected: isSelected,
            isDisabled: isDisabled,
            action: { toggleSelection(for: item.value) }
        ) {
            Text(item.label)
        }
    }

    // MARK: - Private Computed Properties for State

    /// Whether select all is disabled.
    private var isSelectAllDisabled: Bool {
        if let max = maxSelections {
            return itemTuples.count > max
        }
        return activeSelection.count == itemTuples.count
    }

    /// Whether the current selection is valid.
    private var isValidSelection: Bool {
        let count = activeSelection.count
        let meetsMinimum = count >= minSelections

        if let max = maxSelections {
            return meetsMinimum && count <= max
        }

        return meetsMinimum
    }

    // MARK: - Private Methods

    /// Toggles selection for a value.
    private func toggleSelection(for value: SelectionValue) {
        if requiresConfirmation {
            if temporarySelection?.contains(value) == true {
                temporarySelection?.remove(value)
            } else if canSelectItem(withValue: value) {
                temporarySelection?.insert(value)
            }
        } else {
            if selection.contains(value) {
                selection.remove(value)
            } else if canSelectItem(withValue: value) {
                selection.insert(value)
            }
        }
    }

    /// Selects all items.
    private func selectAll() {
        let allValues = itemTuples.map { $0.value }

        if let max = maxSelections {
            let valuesToSelect = Array(allValues.prefix(max))
            if requiresConfirmation {
                temporarySelection = Set(valuesToSelect)
            } else {
                selection = Set(valuesToSelect)
            }
        } else {
            if requiresConfirmation {
                temporarySelection = Set(allValues)
            } else {
                selection = Set(allValues)
            }
        }
    }

    /// Clears all selections.
    private func clearAll() {
        if requiresConfirmation {
            temporarySelection = []
        } else {
            selection = []
        }
    }

    /// Commits the temporary selection to the actual selection.
    private func commitSelection() {
        if let temp = temporarySelection {
            selection = temp
        }
    }
}

// MARK: - Previews

#Preview("Basic MultiPicker") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []

        let fruits = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Default Style") {
                        MultiPicker("Select Fruits", selection: $selection) {
                            ForEach(fruits, id: \.self) { fruit in
                                Text(fruit).multiPickerTag(fruit)
                            }
                        }
                    }

                    Section("Selected Items") {
                        if selection.isEmpty {
                            Text("None selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selection.sorted()), id: \.self) { item in
                                Text(item)
                            }
                        }
                    }
                }
                .navigationTitle("Basic MultiPicker")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("MultiPicker Styles") {
    struct PreviewWrapper: View {
        @State private var inlineSelection: Set<String> = []
        @State private var navigationSelection: Set<String> = []
        @State private var sheetSelection: Set<String> = []
        @State private var menuSelection: Set<String> = []

        let options = ["Option 1", "Option 2", "Option 3", "Option 4"]

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 30) {
                        // Inline Style
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Inline Style")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Displays items directly within the form. Best for small lists.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            MultiPicker("Inline Picker", selection: $inlineSelection) {
                                ForEach(options, id: \.self) { option in
                                    Text(option).multiPickerTag(option)
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

                            Text("Pushes to a new screen when tapped. Good for longer lists.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            MultiPicker("Navigation Picker", selection: $navigationSelection) {
                                ForEach(options, id: \.self) { option in
                                    Text(option).multiPickerTag(option)
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

                            Text("Presents items in a modal sheet. Great for focused selection.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            MultiPicker("Sheet Picker", selection: $sheetSelection) {
                                ForEach(options, id: \.self) { option in
                                    Text(option).multiPickerTag(option)
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

                            Text("Shows items in a popover menu. Default on macOS, compact on iOS.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            MultiPicker("Menu Picker", selection: $menuSelection) {
                                ForEach(options, id: \.self) { option in
                                    Text(option).multiPickerTag(option)
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
                .navigationTitle("MultiPicker Styles")
            }
            .padding()
            .frame(minHeight: 800)
        }
    }

    return PreviewWrapper()
}

#Preview("Selection Limits") {
    struct PreviewWrapper: View {
        @State private var minSelection: Set<String> = []
        @State private var maxSelection: Set<String> = []
        @State private var rangeSelection: Set<String> = []

        let colors = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange"]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Minimum 2 Selections") {
                        MultiPicker("Choose Colors", selection: $minSelection, minSelections: 2) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).multiPickerTag(color)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Maximum 3 Selections") {
                        MultiPicker("Choose Colors", selection: $maxSelection, maxSelections: 3) {
                            ForEach(colors, id: \.self) { color in
                                Text(color).multiPickerTag(color)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("2-4 Selections Required") {
                        MultiPicker("Choose Colors", selection: $rangeSelection, minSelections: 2, maxSelections: 4) {
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

#Preview("Bulk Actions") {
    struct PreviewWrapper: View {
        @State private var selection: Set<Int> = []

        let items = Array(1...20)

        var body: some View {
            NavigationStack {
                Form {
                    Section("With Select All & Clear All") {
                        MultiPicker("Choose Items", selection: $selection, showSelectAll: true, showClearAll: true) {
                            ForEach(items, id: \.self) { item in
                                Text("Item \(item)").multiPickerTag(item)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Selected Count") {
                        Text("\(selection.count) of \(items.count) selected")
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Bulk Actions")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Confirmation Mode") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []

        let categories = ["Technology", "Sports", "Music", "Art", "Food", "Travel"]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Requires Confirmation") {
                        MultiPicker("Select Interests", selection: $selection, minSelections: 1, maxSelections: 3, showSelectAll: true, showClearAll: true, requiresConfirmation: true) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).multiPickerTag(category)
                            }
                        }
                        .multiPickerStyle(.menu)
                    }

                    Section("Committed Selection") {
                        if selection.isEmpty {
                            Text("None selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selection.sorted()), id: \.self) { item in
                                Text(item)
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

#Preview("Form with LabeledContent") {
    struct PreviewWrapper: View {
        @State private var singleSelection: Set<String> = ["Apple"]
        @State private var multiSelection: Set<String> = ["Red", "Blue"]

        let fruits = ["Apple", "Banana", "Cherry"]
        let colors = ["Red", "Blue", "Green", "Yellow"]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Single Selection") {
                        LabeledContent("Fruit") {
                            MultiPicker("Select Fruit", selection: $singleSelection) {
                                ForEach(fruits, id: \.self) { fruit in
                                    Text(fruit).multiPickerTag(fruit)
                                }
                            }
                            .multiPickerStyle(.menu)
                        }
                    }

                    Section("Multiple Selections") {
                        LabeledContent("Colors") {
                            MultiPicker("Select Colors", selection: $multiSelection) {
                                ForEach(colors, id: \.self) { color in
                                    Text(color).multiPickerTag(color)
                                }
                            }
                            .multiPickerStyle(.menu)
                        }
                    }
                }
                .navigationTitle("LabeledContent")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("With Sections") {
    struct PreviewWrapper: View {
        @State private var selection: Set<String> = []

        let fruits = ["Apple", "Banana", "Cherry"]
        let vegetables = ["Carrot", "Broccoli", "Spinach"]
        let grains = ["Rice", "Wheat", "Oats"]

        var body: some View {
            NavigationStack {
                Form {
                    Section("Sectioned MultiPicker") {
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

                    Section("Selected Items") {
                        if selection.isEmpty {
                            Text("None selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selection.sorted()), id: \.self) { item in
                                Text(item)
                            }
                        }
                    }
                }
                .navigationTitle("Sectioned Picker")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
