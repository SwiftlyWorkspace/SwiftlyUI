import SwiftUI

/// A view that displays an individual tag with editing and removal capabilities.
///
/// `TagChip` provides a compact representation of a tag with the following features:
/// - Tap to edit the tag name inline
/// - Color picker menu to change the tag color
/// - Remove button to delete the tag
/// - Hover effects and visual feedback
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct TagChip: View {
    /// The tag to display.
    let tag: Tag

    /// Callback triggered when the tag should be removed.
    let onRemove: () -> Void

    /// Callback triggered when the tag is updated.
    let onUpdate: (Tag) -> Void

    @State private var isHovering = false
    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isEditFocused: Bool

    /// Creates a new tag chip.
    /// - Parameters:
    ///   - tag: The tag to display.
    ///   - onRemove: Callback triggered when the tag should be removed.
    ///   - onUpdate: Callback triggered when the tag is updated.
    public init(
        tag: Tag,
        onRemove: @escaping () -> Void,
        onUpdate: @escaping (Tag) -> Void
    ) {
        self.tag = tag
        self.onRemove = onRemove
        self.onUpdate = onUpdate
    }

    public var body: some View {
        HStack(spacing: 6) {
            if isEditing {
                editingContent
            } else {
                displayContent
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tag.color.opacity(0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(tag.color.opacity(0.3), lineWidth: 1)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }

    /// Content displayed when the tag is in edit mode.
    @ViewBuilder
    private var editingContent: some View {
        TextField("", text: $editText)
            .textFieldStyle(.plain)
            .font(.subheadline)
            .frame(minWidth: 60)
            .focused($isEditFocused)
            .onSubmit {
                saveEdit()
            }

        Button(action: saveEdit) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(isHovering ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }

    /// Content displayed when the tag is in display mode.
    @ViewBuilder
    private var displayContent: some View {
        Text(tag.name)
            .font(.subheadline)
            .lineLimit(1)

        colorPickerMenu

        Button(action: startEdit) {
            Image(systemName: "pencil")
                .font(.caption)
                .foregroundStyle(isHovering ? .primary : .secondary)
        }
        .buttonStyle(.plain)

        Button(action: onRemove) {
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(isHovering ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }

    /// Color picker menu for changing the tag color.
    @ViewBuilder
    private var colorPickerMenu: some View {
        Menu {
            ForEach(Tag.availableColors.indices, id: \.self) { index in
                let color = Tag.availableColors[index]
                Button(action: { changeColor(to: color) }) {
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        Text(Tag.colorName(for: color))
                        if color == tag.color {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Circle()
                .fill(tag.color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    /// Starts editing the tag name.
    private func startEdit() {
        editText = tag.name
        isEditing = true
        isEditFocused = true
    }

    /// Saves the current edit and exits edit mode.
    private func saveEdit() {
        let trimmedText = editText.trimmingCharacters(in: .whitespaces)
        if !trimmedText.isEmpty && trimmedText != tag.name {
            let updatedTag = Tag(id: tag.id, name: trimmedText, color: tag.color)
            onUpdate(updatedTag)
        }
        isEditing = false
    }

    /// Cancels the current edit and exits edit mode.
    private func cancelEdit() {
        isEditing = false
        editText = ""
    }

    /// Changes the tag color to the specified color.
    /// - Parameter newColor: The new color for the tag.
    private func changeColor(to newColor: Color) {
        let updatedTag = Tag(id: tag.id, name: tag.name, color: newColor)
        onUpdate(updatedTag)
    }
}