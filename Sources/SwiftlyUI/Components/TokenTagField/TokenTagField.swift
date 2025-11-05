import SwiftUI

/// A customizable token-based input field for managing tags.
///
/// `TokenTagField` provides a rich interface for creating, editing, and managing tags with features like:
/// - Auto-complete suggestions
/// - Inline tag editing
/// - Color customization
/// - Keyboard navigation
/// - Maximum tag limits
/// - Cross-platform compatibility
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TokenTagField: View {
    /// The current array of tags.
    @Binding var tags: [Tag]

    /// The current input text.
    @Binding var inputText: String

    /// Array of suggested tags for auto-completion.
    let suggestedTags: [Tag]

    /// Maximum number of tags allowed.
    let maxTags: Int

    /// Callback triggered when a new tag is added.
    let onAdd: (Tag) -> Void

    /// Callback triggered when a tag is removed.
    let onRemove: (Tag) -> Void

    /// Callback triggered when a tag is updated.
    let onUpdate: (Tag) -> Void

    /// Placeholder text for the input field.
    let placeholder: String

    @State private var showSuggestions = false
    @FocusState private var isInputFocused: Bool

    /// Creates a new token tag field.
    /// - Parameters:
    ///   - tags: Binding to the current array of tags.
    ///   - inputText: Binding to the current input text.
    ///   - suggestedTags: Array of suggested tags for auto-completion.
    ///   - maxTags: Maximum number of tags allowed. Defaults to 10.
    ///   - placeholder: Placeholder text for the input field. Defaults to "Add tag...".
    ///   - onAdd: Callback triggered when a new tag is added.
    ///   - onRemove: Callback triggered when a tag is removed.
    ///   - onUpdate: Callback triggered when a tag is updated.
    public init(
        tags: Binding<[Tag]>,
        inputText: Binding<String>,
        suggestedTags: [Tag] = [],
        maxTags: Int = 10,
        placeholder: String = "Add tag...",
        onAdd: @escaping (Tag) -> Void,
        onRemove: @escaping (Tag) -> Void,
        onUpdate: @escaping (Tag) -> Void
    ) {
        self._tags = tags
        self._inputText = inputText
        self.suggestedTags = suggestedTags
        self.maxTags = maxTags
        self.placeholder = placeholder
        self.onAdd = onAdd
        self.onRemove = onRemove
        self.onUpdate = onUpdate
    }

    /// Filtered suggestions based on the current input text.
    private var filteredSuggestions: [Tag] {
        guard !inputText.isEmpty else { return [] }

        return suggestedTags.filter { suggestion in
            !tags.contains(where: { $0.name.lowercased() == suggestion.name.lowercased() }) &&
            suggestion.name.localizedCaseInsensitiveContains(inputText)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            tagInputArea
            maxTagsWarning
            suggestionsView
        }
    }

    /// The main input area containing tags and the text field.
    @ViewBuilder
    private var tagInputArea: some View {
        FlowLayout(spacing: 6) {
            tagChips
            inputField
        }
        .padding(8)
        .background(Color.textBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.separator, lineWidth: 1)
        )
    }

    /// The individual tag chips.
    @ViewBuilder
    private var tagChips: some View {
        ForEach(tags) { tag in
            TagChip(
                tag: tag,
                onRemove: { onRemove(tag) },
                onUpdate: handleTagUpdate
            )
        }
    }

    /// The text input field for adding new tags.
    @ViewBuilder
    private var inputField: some View {
        if tags.count < maxTags {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $inputText)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 80)
                    .focused($isInputFocused)
                    .onSubmit {
                        addTag(inputText)
                    }
                    .onChange(of: inputText) { newValue in
                        showSuggestions = !newValue.isEmpty && !filteredSuggestions.isEmpty
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.controlBackground)
            .cornerRadius(8)
        }
    }

    /// Warning message when maximum tags are reached.
    @ViewBuilder
    private var maxTagsWarning: some View {
        if tags.count >= maxTags {
            Text("Maximum \(maxTags) tags reached")
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    /// The suggestions dropdown view.
    @ViewBuilder
    private var suggestionsView: some View {
        if showSuggestions {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(filteredSuggestions.prefix(5).enumerated()), id: \.element.id) { index, suggestion in
                    Button {
                        addTag(suggestion.name)
                        showSuggestions = false
                    } label: {
                        HStack {
                            Text(suggestion.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("suggested")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(suggestion.color.opacity(0.2))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < filteredSuggestions.prefix(5).count - 1 {
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

    /// Adds a new tag with the specified name.
    /// - Parameter tagName: The name of the tag to add.
    private func addTag(_ tagName: String) {
        guard !tagName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard tags.count < maxTags else { return }

        let trimmedName = tagName.trimmingCharacters(in: .whitespaces)

        // Check for duplicates
        guard !tags.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else { return }

        // Check if it exists in suggestions to preserve color
        let newTag: Tag
        if let existingTag = suggestedTags.first(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            newTag = Tag(name: existingTag.name, color: existingTag.color)
        } else {
            newTag = Tag.withRandomColor(name: trimmedName)
        }

        onAdd(newTag)
        inputText = ""
    }

    /// Handles tag updates with duplicate checking.
    /// - Parameter updatedTag: The updated tag.
    private func handleTagUpdate(_ updatedTag: Tag) {
        // Check for duplicates before updating
        let isDuplicate = tags.contains { existingTag in
            existingTag.id != updatedTag.id &&
            existingTag.name.lowercased() == updatedTag.name.lowercased()
        }

        if !isDuplicate {
            onUpdate(updatedTag)
        }
    }
}

// MARK: - Array Extension for Chunking

private extension Array {
    /// Splits the array into chunks of the specified size.
    /// - Parameter size: The maximum size of each chunk.
    /// - Returns: An array of arrays, each containing at most `size` elements.
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}