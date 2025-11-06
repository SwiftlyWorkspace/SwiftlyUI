import SwiftUI

/// A protocol that defines the appearance and behavior of a multi-picker.
///
/// Create custom picker styles by conforming to this protocol and implementing
/// the required `makeBody(configuration:)` method.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public protocol MultiPickerStyle {
    /// A view that represents the body of a multi-picker.
    associatedtype Body: View

    /// Creates a view representing the body of a multi-picker.
    ///
    /// - Parameter configuration: The properties of the multi-picker instance being created.
    /// - Returns: A view that has the appearance and behavior of a multi-picker.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The properties of a multi-picker instance.
    typealias Configuration = MultiPickerStyleConfiguration
}

/// The properties of a multi-picker instance.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MultiPickerStyleConfiguration {
    /// The label describing the purpose of the picker.
    public let label: AnyView

    /// The content view of the picker.
    public let content: AnyView

    /// The current selection count.
    public let selectionCount: Int

    /// The selected item labels.
    public let selectedItems: [String]

    /// Whether the picker is in a confirmed mode.
    public let requiresConfirmation: Bool
}

// MARK: - Built-in Styles

/// A multi-picker style that displays items in an inline list.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct InlineMultiPickerStyle: MultiPickerStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)

            configuration.content
        }
    }
}

/// A multi-picker style that navigates to a new screen.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct NavigationLinkMultiPickerStyle: MultiPickerStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        NavigationLink {
            VStack(alignment: .leading, spacing: 0) {
                configuration.content
            }
            .navigationTitle("")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        } label: {
            HStack {
                configuration.label

                Spacer()

                if configuration.selectionCount > 0 {
                    let displayConfig = MultiPickerSelectionDisplayConfiguration(
                        selectedItems: configuration.selectedItems,
                        selectionCount: configuration.selectionCount
                    )
                    AbbreviatedSelectionDisplay(maxItems: 2)
                        .makeBody(configuration: displayConfig)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// A multi-picker style that presents items in a sheet.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SheetMultiPickerStyle: MultiPickerStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        SheetMultiPickerStyleView(configuration: configuration)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SheetMultiPickerStyleView: View {
    let configuration: MultiPickerStyleConfiguration
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                configuration.label

                Spacer()

                if configuration.selectionCount > 0 {
                    let displayConfig = MultiPickerSelectionDisplayConfiguration(
                        selectedItems: configuration.selectedItems,
                        selectionCount: configuration.selectionCount
                    )
                    AbbreviatedSelectionDisplay(maxItems: 2)
                        .makeBody(configuration: displayConfig)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                configuration.content
                    .navigationTitle("")
                    #if !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresented = false
                            }
                        }
                    }
            }
        }
    }
}

/// A multi-picker style that presents items in a menu.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MenuMultiPickerStyle: MultiPickerStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        MenuMultiPickerStyleView(configuration: configuration)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct MenuMultiPickerStyleView: View {
    let configuration: MultiPickerStyleConfiguration
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 8) {
                configuration.label

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(6)
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            VStack(spacing: 0) {
                configuration.content
                    .frame(minWidth: 350, idealWidth: 400, maxWidth: 500, minHeight: 200, idealHeight: 350, maxHeight: 450)

                if configuration.requiresConfirmation {
                    Divider()

                    HStack {
                        Spacer()
                        Button("Done") {
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(12)
                    }
                    #if os(macOS)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    #else
                    .background(Color(uiColor: .systemBackground).opacity(0.5))
                    #endif
                }
            }
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .systemBackground))
            #endif
        }
    }
}

// MARK: - Style Environment Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct MultiPickerStyleKey: EnvironmentKey {
    #if os(macOS)
    static let defaultValue: AnyMultiPickerStyle = AnyMultiPickerStyle(MenuMultiPickerStyle())
    #else
    static let defaultValue: AnyMultiPickerStyle = AnyMultiPickerStyle(InlineMultiPickerStyle())
    #endif
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var multiPickerStyle: AnyMultiPickerStyle {
        get { self[MultiPickerStyleKey.self] }
        set { self[MultiPickerStyleKey.self] = newValue }
    }
}

// MARK: - Type-Erased Style

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AnyMultiPickerStyle: MultiPickerStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: MultiPickerStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - View Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Sets the style for multi-pickers within this view.
    ///
    /// ## Example
    /// ```swift
    /// MultiPicker(selection: $selection, label: "Options") {
    ///     Text("Option 1").tag(1)
    ///     Text("Option 2").tag(2)
    /// }
    /// .multiPickerStyle(.inline)
    /// ```
    public func multiPickerStyle<S: MultiPickerStyle>(_ style: S) -> some View {
        environment(\.multiPickerStyle, AnyMultiPickerStyle(style))
    }
}

// MARK: - Convenience Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerStyle where Self == InlineMultiPickerStyle {
    /// A multi-picker style that displays items in an inline list.
    public static var inline: InlineMultiPickerStyle { InlineMultiPickerStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerStyle where Self == NavigationLinkMultiPickerStyle {
    /// A multi-picker style that navigates to a new screen.
    public static var navigationLink: NavigationLinkMultiPickerStyle { NavigationLinkMultiPickerStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerStyle where Self == SheetMultiPickerStyle {
    /// A multi-picker style that presents items in a sheet.
    public static var sheet: SheetMultiPickerStyle { SheetMultiPickerStyle() }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension MultiPickerStyle where Self == MenuMultiPickerStyle {
    /// A multi-picker style that presents items in a menu.
    public static var menu: MenuMultiPickerStyle { MenuMultiPickerStyle() }
}
