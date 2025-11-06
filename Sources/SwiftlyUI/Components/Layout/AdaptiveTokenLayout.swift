import SwiftUI

/// A layout that displays items as tokens/chips, fitting as many as possible on a single line
/// and showing a "+X" indicator for remaining items that don't fit.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AdaptiveTokenLayout: View {
    let items: [String]
    let placeholder: String

    @State private var visibleCount: Int?

    public init(items: [String], placeholder: String = "Select items") {
        self.items = items
        self.placeholder = placeholder
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 6) {
                if items.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary)
                        .font(.body)
                } else {
                    // If visibleCount hasn't been calculated yet, show all items optimistically
                    // This prevents showing "+X" on initial render
                    let count = visibleCount ?? items.count

                    ForEach(Array(items.prefix(count).enumerated()), id: \.offset) { _, item in
                        TokenChipView(text: item)
                    }

                    // Only show overflow if we've calculated and there are hidden items
                    if let calculated = visibleCount, calculated < items.count {
                        Text("+\(items.count - calculated)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            .task {
                // Use task instead of onAppear for immediate calculation
                calculateVisibleCount(availableWidth: geometry.size.width)
            }
            .onChange(of: geometry.size.width) { newWidth in
                calculateVisibleCount(availableWidth: newWidth)
            }
            .onChange(of: items) { _ in
                calculateVisibleCount(availableWidth: geometry.size.width)
            }
        }
        .frame(height: 20)
    }

    private func calculateVisibleCount(availableWidth: CGFloat) {
        guard !items.isEmpty else {
            visibleCount = 0
            return
        }

        // Ignore very narrow widths that occur during initial layout
        // Wait for a reasonable width before calculating
        guard availableWidth >= 50 else {
            visibleCount = nil  // Don't set a count yet, show all items optimistically
            return
        }

        // Special case: if there's only 1 item, always show it (no overflow indicator needed)
        if items.count == 1 {
            visibleCount = 1
            return
        }

        let spacing: CGFloat = 6
        let overflowIndicatorWidth: CGFloat = 45 // Approximate width for "+XX"
        var currentWidth: CGFloat = 0
        var count = 0

        for (index, item) in items.enumerated() {
            let tokenWidth = estimateTokenWidth(for: item)
            let spacingWidth = count > 0 ? spacing : 0
            let neededWidth = currentWidth + spacingWidth + tokenWidth

            // Check if this is the last item
            let isLastItem = (index == items.count - 1)

            if isLastItem {
                // Last item - just check if it fits
                if neededWidth <= availableWidth {
                    count += 1
                }
            } else {
                // Not the last item - need room for this token + overflow indicator
                if neededWidth + spacing + overflowIndicatorWidth <= availableWidth {
                    currentWidth = neededWidth
                    count += 1
                } else {
                    // Can't fit this token and overflow indicator
                    break
                }
            }
        }

        visibleCount = max(1, count) // Always show at least 1 item if there are any
    }

    private func estimateTokenWidth(for text: String) -> CGFloat {
        // More accurate estimation for system font
        // System font is roughly 7 points per character at body size + chip padding (12 total from .padding(.horizontal, 6))
        let characterWidth: CGFloat = 7
        let chipPadding: CGFloat = 12  // 6px left + 6px right padding
        return CGFloat(text.count) * characterWidth + chipPadding
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TokenChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Basic Examples") {
    VStack(spacing: 20) {
        AdaptiveTokenLayout(items: [], placeholder: "Select fruits")
            .frame(width: 300)
            .padding()
            .background(Color.gray.opacity(0.1))

        AdaptiveTokenLayout(items: ["Apple"], placeholder: "Select fruits")
            .frame(width: 300)
            .padding()
            .background(Color.gray.opacity(0.1))

        AdaptiveTokenLayout(items: ["Apple", "Banana"], placeholder: "Select fruits")
            .frame(width: 300)
            .padding()
            .background(Color.gray.opacity(0.1))

        AdaptiveTokenLayout(items: ["Apple", "Banana", "Cherry", "Date", "Elderberry"], placeholder: "Select fruits")
            .frame(width: 300)
            .padding()
            .background(Color.gray.opacity(0.1))

        AdaptiveTokenLayout(items: ["Apple", "Banana", "Cherry", "Date", "Elderberry"], placeholder: "Select fruits")
            .frame(width: 200)
            .padding()
            .background(Color.gray.opacity(0.1))

        AdaptiveTokenLayout(items: ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape"], placeholder: "Select fruits")
            .frame(width: 150)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
    .padding()
}

#Preview("Form with LabeledContent") {
    NavigationStack {
        Form {
            Section("Single Item") {
                LabeledContent("Selection") {
                    AdaptiveTokenLayout(items: ["Apple"], placeholder: "Select...")
                }
            }
            
            Section("Two Items") {
                LabeledContent("Selection") {
                    AdaptiveTokenLayout(items: ["Apple", "Banana"], placeholder: "Select...")
                }
            }
            
            Section("Multiple Items") {
                LabeledContent("Selection") {
                    AdaptiveTokenLayout(items: ["Apple", "Banana", "Cherry"], placeholder: "Select...")
                }
            }
            
            Section("Many Items") {
                LabeledContent("Selection") {
                    AdaptiveTokenLayout(
                        items: ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape"],
                        placeholder: "Select..."
                    )
                }
            }
            
            Section("Empty Selection") {
                LabeledContent("Selection") {
                    AdaptiveTokenLayout(items: [], placeholder: "Select fruits...")
                }
            }
        }
        .navigationTitle("AdaptiveTokenLayout Test")
        .padding()
    }
}
