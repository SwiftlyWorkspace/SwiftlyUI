import SwiftUI

/// A row view for multi-picker items.
///
/// Displays a checkbox, label, and handles selection state.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
internal struct MultiPickerRow<Label: View>: View {
    // MARK: - Properties

    /// The label view for this row.
    let label: Label

    /// Whether this item is selected.
    let isSelected: Bool

    /// Whether this item is disabled.
    let isDisabled: Bool

    /// Action to perform when the row is tapped.
    let action: () -> Void

    // MARK: - Initializers

    /// Creates a new picker row.
    /// - Parameters:
    ///   - isSelected: Whether this item is selected.
    ///   - isDisabled: Whether this item is disabled.
    ///   - action: Action to perform when the row is tapped.
    ///   - label: The label view for this row.
    init(
        isSelected: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.action = action
        self.label = label()
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                MultiPickerCheckbox(isChecked: isSelected, isDisabled: isDisabled)

                label
                    .foregroundStyle(isDisabled && !isSelected ? .secondary : .primary)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
    }
}

// MARK: - Preview

#Preview("Picker Rows") {
    VStack(spacing: 0) {
        MultiPickerRow(isSelected: false, action: {}) {
            Text("Unselected Item")
        }

        Divider()

        MultiPickerRow(isSelected: true, action: {}) {
            Text("Selected Item")
        }

        Divider()

        MultiPickerRow(isSelected: false, isDisabled: true, action: {}) {
            Text("Disabled Item")
        }

        Divider()

        MultiPickerRow(isSelected: true, isDisabled: true, action: {}) {
            Text("Selected Disabled Item")
        }
    }
}
