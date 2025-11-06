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
/// @State private var selection: Set<Int> = []
///
/// MultiPicker(
///     title: "Choose Options",
///     items: [
///         (value: 1, label: "Option 1"),
///         (value: 2, label: "Option 2"),
///         (value: 3, label: "Option 3")
///     ],
///     selection: $selection
/// )
/// ```
///
/// ## With Selection Limits
/// ```swift
/// MultiPicker(
///     title: "Choose 2-4 Options",
///     items: options,
///     selection: $selection,
///     minSelections: 2,
///     maxSelections: 4
/// )
/// ```
///
/// ## Custom Style
/// ```swift
/// MultiPicker(
///     title: "Options",
///     items: items,
///     selection: $selection
/// )
/// .multiPickerStyle(.navigationLink)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MultiPicker<SelectionValue: Hashable>: View {
    // MARK: - Properties

    /// The title/label for the picker.
    let title: String

    /// Array of value-label pairs for the items.
    let items: [(value: SelectionValue, label: String)]

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

    /// Temporary selection in confirmation mode.
    @State private var temporarySelection: Set<SelectionValue>?

    @Environment(\.multiPickerStyle) private var style

    // MARK: - Initializers

    /// Creates a multi-picker.
    /// - Parameters:
    ///   - title: Title for the picker.
    ///   - items: Array of value-label pairs.
    ///   - selection: Binding to the set of selected values.
    ///   - minSelections: Minimum selections required (default: 0).
    ///   - maxSelections: Maximum selections allowed (default: nil/unlimited).
    ///   - showSelectAll: Whether to show select all button (default: false).
    ///   - showClearAll: Whether to show clear all button (default: false).
    ///   - requiresConfirmation: Whether to require confirmation (default: false).
    public init(
        title: String,
        items: [(value: SelectionValue, label: String)],
        selection: Binding<Set<SelectionValue>>,
        minSelections: Int = 0,
        maxSelections: Int? = nil,
        showSelectAll: Bool = false,
        showClearAll: Bool = false,
        requiresConfirmation: Bool = false
    ) {
        self.title = title
        self.items = items
        self._selection = selection
        self.minSelections = max(0, minSelections)
        self.maxSelections = maxSelections.map { max(1, $0) }
        self.showSelectAll = showSelectAll
        self.showClearAll = showClearAll
        self.requiresConfirmation = requiresConfirmation
    }

    // MARK: - Body

    public var body: some View {
        let configuration = MultiPickerStyleConfiguration(
            label: AnyView(Text(title)),
            content: AnyView(pickerContent),
            selectionCount: activeSelection.count,
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
    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Bulk action buttons
            if showSelectAll || showClearAll {
                bulkActionsBar
                Divider()
            }

            // Items list
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(items.indices), id: \.self) { index in
                        itemRow(for: items[index])

                        if index < items.count - 1 {
                            Divider()
                                .padding(.leading, 48)
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

    /// Confirmation buttons bar (Done/Cancel).
    @ViewBuilder
    private var confirmationBar: some View {
        HStack {
            Button("Cancel") {
                temporarySelection = selection
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Done") {
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
            return items.count > max
        }
        return activeSelection.count == items.count
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
        let allValues = items.map { $0.value }

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
