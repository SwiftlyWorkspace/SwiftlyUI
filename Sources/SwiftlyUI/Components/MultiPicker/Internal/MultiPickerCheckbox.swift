import SwiftUI

/// A checkbox control for multi-picker items.
///
/// Displays a checkbox that can be in checked or unchecked state,
/// with optional disabled state for when selection limits are reached.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
internal struct MultiPickerCheckbox: View {
    // MARK: - Properties

    /// Whether the checkbox is checked.
    let isChecked: Bool

    /// Whether the checkbox is disabled.
    let isDisabled: Bool

    // MARK: - Initializers

    /// Creates a new checkbox.
    /// - Parameters:
    ///   - isChecked: Whether the checkbox is checked.
    ///   - isDisabled: Whether the checkbox is disabled. Defaults to false.
    init(isChecked: Bool, isDisabled: Bool = false) {
        self.isChecked = isChecked
        self.isDisabled = isDisabled
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(borderColor, lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(backgroundColor)
                )
                .frame(width: 20, height: 20)

            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(checkmarkColor)
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Private Computed Properties

    private var borderColor: Color {
        if isChecked {
            return .accentColor
        } else if isDisabled {
            return Color.separator
        } else {
            return Color.separator.opacity(0.5)
        }
    }

    private var backgroundColor: Color {
        isChecked ? Color.accentColor : Color.clear
    }

    private var checkmarkColor: Color {
        .white
    }
}

// MARK: - Preview

#Preview("Checkbox States") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            MultiPickerCheckbox(isChecked: false)
            Text("Unchecked")
        }

        HStack(spacing: 20) {
            MultiPickerCheckbox(isChecked: true)
            Text("Checked")
        }

        HStack(spacing: 20) {
            MultiPickerCheckbox(isChecked: false, isDisabled: true)
            Text("Unchecked Disabled")
        }

        HStack(spacing: 20) {
            MultiPickerCheckbox(isChecked: true, isDisabled: true)
            Text("Checked Disabled")
        }
    }
    .padding()
}
