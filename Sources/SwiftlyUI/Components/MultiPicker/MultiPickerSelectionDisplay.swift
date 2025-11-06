import SwiftUI

/// A protocol that defines how selected items are displayed in a multi-picker.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public protocol MultiPickerSelectionDisplay {
    /// A view that represents the display of selected items.
    associatedtype Body: View

    /// Creates a view representing the selected items display.
    ///
    /// - Parameter configuration: The properties of the selection display.
    /// - Returns: A view showing the selected items.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The properties of a selection display.
    typealias Configuration = MultiPickerSelectionDisplayConfiguration
}

/// The properties of a multi-picker selection display.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MultiPickerSelectionDisplayConfiguration {
    /// The selected items as strings.
    public let selectedItems: [String]

    /// The total selection count.
    public let selectionCount: Int
}

// MARK: - Built-in Display Styles

/// A selection display that shows only a count badge.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct BadgeSelectionDisplay: MultiPickerSelectionDisplay {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        if configuration.selectionCount > 0 {
            Text("\(configuration.selectionCount) selected")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

/// A selection display that shows abbreviated text.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AbbreviatedSelectionDisplay: MultiPickerSelectionDisplay {
    let maxItems: Int

    public init(maxItems: Int = 2) {
        self.maxItems = maxItems
    }

    public func makeBody(configuration: Configuration) -> some View {
        if configuration.selectionCount > 0 {
            let displayItems = configuration.selectedItems.prefix(maxItems)
            let remaining = configuration.selectionCount - displayItems.count

            HStack(spacing: 4) {
                Text(displayItems.joined(separator: ", "))
                    .lineLimit(1)

                if remaining > 0 {
                    Text("+\(remaining) more")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }
}

/// A selection display that shows items as removable tags.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TagsSelectionDisplay: MultiPickerSelectionDisplay {
    let onRemove: ((String) -> Void)?

    public init(onRemove: ((String) -> Void)? = nil) {
        self.onRemove = onRemove
    }

    public func makeBody(configuration: Configuration) -> some View {
        if configuration.selectionCount > 0 {
            FlowLayout(spacing: 6) {
                ForEach(configuration.selectedItems, id: \.self) { item in
                    HStack(spacing: 6) {
                        Text(item)
                            .font(.subheadline)

                        if let onRemove = onRemove {
                            Button {
                                onRemove(item)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.controlBackground)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.separator.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
}

// MARK: - Display Environment Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct MultiPickerSelectionDisplayKey: EnvironmentKey {
    static let defaultValue: AnyMultiPickerSelectionDisplay = AnyMultiPickerSelectionDisplay(
        BadgeSelectionDisplay()
    )
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var multiPickerSelectionDisplay: AnyMultiPickerSelectionDisplay {
        get { self[MultiPickerSelectionDisplayKey.self] }
        set { self[MultiPickerSelectionDisplayKey.self] = newValue }
    }
}

// MARK: - Type-Erased Display

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AnyMultiPickerSelectionDisplay: MultiPickerSelectionDisplay {
    private let _makeBody: (Configuration) -> AnyView

    init<D: MultiPickerSelectionDisplay>(_ display: D) {
        _makeBody = { configuration in
            AnyView(display.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - View Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Sets the selection display style for multi-pickers within this view.
    ///
    /// ## Example
    /// ```swift
    /// MultiPicker(selection: $selection, label: "Options") {
    ///     Text("Option 1").tag(1)
    ///     Text("Option 2").tag(2)
    /// }
    /// .multiPickerSelectionDisplay(.abbreviated())
    /// ```
    public func multiPickerSelectionDisplay<D: MultiPickerSelectionDisplay>(_ display: D) -> some View {
        environment(\.multiPickerSelectionDisplay, AnyMultiPickerSelectionDisplay(display))
    }
}

// MARK: - Convenience Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerSelectionDisplay where Self == BadgeSelectionDisplay {
    /// A selection display that shows only a count badge.
    public static var badge: BadgeSelectionDisplay { BadgeSelectionDisplay() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerSelectionDisplay where Self == AbbreviatedSelectionDisplay {
    /// A selection display that shows abbreviated text.
    public static func abbreviated(maxItems: Int = 2) -> AbbreviatedSelectionDisplay {
        AbbreviatedSelectionDisplay(maxItems: maxItems)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerSelectionDisplay where Self == TagsSelectionDisplay {
    /// A selection display that shows items as removable tags.
    public static func tags(onRemove: ((String) -> Void)? = nil) -> TagsSelectionDisplay {
        TagsSelectionDisplay(onRemove: onRemove)
    }
}
