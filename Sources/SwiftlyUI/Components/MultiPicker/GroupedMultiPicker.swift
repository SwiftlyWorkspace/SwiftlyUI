import SwiftUI

/// A multi-selection picker with grouped/sectioned data support.
///
/// `GroupedMultiPicker` organizes items into sections with headers, making it easy
/// to work with categorized data.
///
/// ## Example
/// ```swift
/// @State private var selection: Set<String> = []
///
/// GroupedMultiPicker(
///     title: "Select Items",
///     sections: [
///         ("Fruits", [
///             (value: "apple", label: "Apple"),
///             (value: "banana", label: "Banana")
///         ]),
///         ("Vegetables", [
///             (value: "carrot", label: "Carrot"),
///             (value: "broccoli", label: "Broccoli")
///         ])
///     ],
///     selection: $selection
/// )
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct GroupedMultiPicker<SelectionValue: Hashable>: View {
    // MARK: - Properties

    /// The title/label for the picker.
    let title: String

    /// Sections with headers and items.
    let sections: [(header: String, items: [(value: SelectionValue, label: String)])]

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

    /// Whether sections are collapsible.
    let collapsibleSections: Bool

    @State private var collapsedSections: Set<String> = []
    @Environment(\.multiPickerStyle) private var style

    // MARK: - Initializers

    /// Creates a grouped multi-picker.
    /// - Parameters:
    ///   - title: Title for the picker.
    ///   - sections: Array of sections with headers and items.
    ///   - selection: Binding to the set of selected values.
    ///   - minSelections: Minimum selections required (default: 0).
    ///   - maxSelections: Maximum selections allowed (default: nil/unlimited).
    ///   - showSelectAll: Whether to show select all button (default: false).
    ///   - showClearAll: Whether to show clear all button (default: false).
    ///   - requiresConfirmation: Whether to require confirmation (default: false).
    ///   - collapsibleSections: Whether sections can be collapsed (default: false).
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
    ) {
        self.title = title
        self.sections = sections
        self._selection = selection
        self.minSelections = minSelections
        self.maxSelections = maxSelections
        self.showSelectAll = showSelectAll
        self.showClearAll = showClearAll
        self.requiresConfirmation = requiresConfirmation
        self.collapsibleSections = collapsibleSections
    }

    // MARK: - Body

    public var body: some View {
        let configuration = MultiPickerStyleConfiguration(
            label: AnyView(Text(title)),
            content: AnyView(pickerContent),
            selectionCount: selection.count,
            requiresConfirmation: requiresConfirmation
        )

        style.makeBody(configuration: configuration)
    }

    // MARK: - Private Computed Properties

    /// All items flattened from sections.
    private var allItems: [(value: SelectionValue, label: String)] {
        sections.flatMap { $0.items }
    }

    /// Whether an item can be selected (considering max limit).
    private func canSelectItem(withValue value: SelectionValue) -> Bool {
        guard let max = maxSelections else { return true }
        return selection.contains(value) || selection.count < max
    }

    // MARK: - Private Views

    /// The main picker content view.
    @ViewBuilder
    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bulk action buttons
            if showSelectAll || showClearAll {
                bulkActionsBar
                Divider()
            }

            // Sections list
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { sectionIndex, section in
                        sectionView(for: section, at: sectionIndex)

                        if sectionIndex < sections.count - 1 {
                            Divider()
                                .padding(.vertical, 8)
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

    /// Section view with header and items.
    @ViewBuilder
    private func sectionView(for section: (header: String, items: [(value: SelectionValue, label: String)]), at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            sectionHeader(for: section)

            // Section items (only if not collapsed)
            if !collapsedSections.contains(section.header) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { itemIndex, item in
                    itemRow(for: item)

                    if itemIndex < section.items.count - 1 {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
        }
    }

    /// Section header view.
    @ViewBuilder
    private func sectionHeader(for section: (header: String, items: [(value: SelectionValue, label: String)])) -> some View {
        let sectionSelectionCount = section.items.filter { selection.contains($0.value) }.count

        Button {
            if collapsibleSections {
                toggleSection(section.header)
            }
        } label: {
            HStack {
                Text(section.header)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                if sectionSelectionCount > 0 {
                    Text("(\(sectionSelectionCount))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if collapsibleSections {
                    Image(systemName: collapsedSections.contains(section.header) ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.controlBackground.opacity(0.3))
    }

    /// Individual item row.
    @ViewBuilder
    private func itemRow(for item: (value: SelectionValue, label: String)) -> some View {
        let isSelected = selection.contains(item.value)
        let isDisabled = !canSelectItem(withValue: item.value) && !isSelected

        MultiPickerRow(
            isSelected: isSelected,
            isDisabled: isDisabled,
            action: { toggleSelection(for: item.value) }
        ) {
            Text(item.label)
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
                .disabled(selection.isEmpty)
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
            if let max = maxSelections, selection.count >= max {
                Label("Maximum \(max) selections reached", systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if selection.count < minSelections {
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

    /// Confirmation buttons bar (Done/Cancel).
    @ViewBuilder
    private var confirmationBar: some View {
        HStack {
            Button("Cancel") {
                // Reset to previous selection if needed
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Done") {
                // Commit selection
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValidSelection)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.controlBackground.opacity(0.5))
    }

    // MARK: - Private Computed Properties for State

    /// Whether select all is disabled.
    private var isSelectAllDisabled: Bool {
        if let max = maxSelections {
            return allItems.count > max
        }
        return selection.count == allItems.count
    }

    /// Whether the current selection is valid.
    private var isValidSelection: Bool {
        let count = selection.count
        let meetsMinimum = count >= minSelections

        if let max = maxSelections {
            return meetsMinimum && count <= max
        }

        return meetsMinimum
    }

    // MARK: - Private Methods

    /// Toggles section collapsed state.
    private func toggleSection(_ header: String) {
        if collapsedSections.contains(header) {
            collapsedSections.remove(header)
        } else {
            collapsedSections.insert(header)
        }
    }

    /// Toggles selection for a value.
    private func toggleSelection(for value: SelectionValue) {
        if selection.contains(value) {
            selection.remove(value)
        } else if canSelectItem(withValue: value) {
            selection.insert(value)
        }
    }

    /// Selects all items.
    private func selectAll() {
        if let max = maxSelections {
            let valuesToSelect = Array(allItems.map { $0.value }.prefix(max))
            selection = Set(valuesToSelect)
        } else {
            selection = Set(allItems.map { $0.value })
        }
    }

    /// Clears all selections.
    private func clearAll() {
        selection = []
    }
}

/// Typealias for alternative naming convention.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias SectionedMultiPicker = GroupedMultiPicker

// MARK: - Preview

#Preview("Grouped MultiPicker") {
    struct PreviewWrapper: View {
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
            ]),
            (header: "Grains", items: [
                (value: "rice", label: "Rice"),
                (value: "wheat", label: "Wheat"),
                (value: "oats", label: "Oats")
            ])
        ]

        var body: some View {
            NavigationStack {
                GroupedMultiPicker(
                    title: "Select Foods",
                    sections: sections,
                    selection: $selection,
                    showSelectAll: true,
                    showClearAll: true,
                    collapsibleSections: true
                )
                .navigationTitle("Demo")
            }
        }
    }

    return PreviewWrapper()
}
