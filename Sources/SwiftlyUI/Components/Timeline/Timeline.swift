import SwiftUI

/// A timeline component that displays chronological events in a customizable layout.
///
/// `Timeline` provides a flexible way to display time-ordered data with various presentation
/// styles and customization options. It supports both data-driven and ViewBuilder APIs,
/// making it suitable for a wide range of use cases.
///
/// ## Basic Example (Data-Driven)
/// ```swift
/// @State private var events: [TimelineItem] = [
///     TimelineItem(date: date1, title: "Task Started", status: .inProgress),
///     TimelineItem(date: date2, title: "Task Completed", status: .completed)
/// ]
///
/// Timeline(items: events)
/// ```
///
/// ## With Custom Content
/// ```swift
/// Timeline(items: tasks) { task in
///     VStack(alignment: .leading) {
///         Text(task.name)
///             .font(.headline)
///         Text(task.description)
///             .font(.subheadline)
///     }
/// }
/// ```
///
/// ## ViewBuilder API
/// ```swift
/// Timeline {
///     TimelineRow(date: date1, status: .completed) {
///         Text("Task Completed")
///     }
///     TimelineRow(date: date2, status: .inProgress) {
///         Text("In Progress")
///     }
/// }
/// ```
///
/// ## Styling
/// ```swift
/// Timeline(items: events)
///     .timelineStyle(.vertical)   // or .horizontal, .compact, .github
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct Timeline<Item: TimelineItemRepresentable, Content: View>: View {
    // MARK: - Properties

    /// The items to display in the timeline.
    let items: [Item]

    /// Optional custom content view for each item.
    let content: ((Item) -> Content)?

    /// Whether selection is enabled.
    @Binding private var selectionBinding: Set<Item.ID>?

    /// Custom tap action for items.
    let onItemTap: ((Item) -> Void)?

    /// The timeline style from the environment.
    @Environment(\.timelineStyle) private var style

    // MARK: - Computed Properties

    /// Sorted items by date.
    private var sortedItems: [Item] {
        items.sorted { $0.timelineDate < $1.timelineDate }
    }

    /// Type-erased wrappers for the items.
    private var wrappedItems: [AnyTimelineItemWrapper] {
        sortedItems.map { AnyTimelineItemWrapper($0) }
    }

    /// The current selection set (type-erased).
    private var selection: Set<AnyHashable> {
        Set(selectionBinding?.map { AnyHashable($0) } ?? [])
    }

    // MARK: - Initializers

    /// Creates a timeline with an array of items and default content.
    ///
    /// The timeline will display each item using its protocol properties
    /// (title, description, date, status) with the default layout.
    ///
    /// - Parameters:
    ///   - items: The timeline items to display.
    ///   - selection: Optional binding to track selected items.
    public init(
        items: [Item],
        selection: Binding<Set<Item.ID>>? = nil
    ) where Content == DefaultTimelineItemContent<Item> {
        self.items = items
        self.content = nil
        self._selectionBinding = Binding(
            get: { selection?.wrappedValue },
            set: { newValue in selection?.wrappedValue = newValue ?? [] }
        )
        self.onItemTap = nil
    }

    /// Creates a timeline with an array of items and custom content.
    ///
    /// Use this initializer when you want to provide a custom view
    /// for each timeline item.
    ///
    /// - Parameters:
    ///   - items: The timeline items to display.
    ///   - selection: Optional binding to track selected items.
    ///   - content: A view builder that creates the content for each item.
    public init(
        items: [Item],
        selection: Binding<Set<Item.ID>>? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.content = content
        self._selectionBinding = Binding(
            get: { selection?.wrappedValue },
            set: { newValue in selection?.wrappedValue = newValue ?? [] }
        )
        self.onItemTap = nil
    }

    /// Creates a timeline with custom tap actions.
    ///
    /// - Parameters:
    ///   - items: The timeline items to display.
    ///   - onItemTap: A closure called when an item is tapped.
    ///   - content: A view builder that creates the content for each item.
    public init(
        items: [Item],
        onItemTap: @escaping (Item) -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.content = content
        self._selectionBinding = .constant(nil)
        self.onItemTap = onItemTap
    }

    // MARK: - Body

    public var body: some View {
        let configuration = TimelineStyleConfiguration(
            items: wrappedItems,
            content: AnyView(contentView),
            allowsSelection: selectionBinding != nil || onItemTap != nil,
            selection: selection,
            onItemTap: { wrapper in
                handleItemTap(wrapper)
            }
        )

        style.makeBody(configuration: configuration)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        if let content = content {
            ForEach(sortedItems) { item in
                content(item)
            }
        } else {
            ForEach(sortedItems) { item in
                DefaultTimelineItemContent(item: item)
            }
        }
    }

    // MARK: - Private Methods

    private func handleItemTap(_ wrapper: AnyTimelineItemWrapper) {
        // Find the original item
        if let item = sortedItems.first(where: { AnyHashable($0.id) == wrapper.id }) {
            // Handle tap action if provided
            if let onItemTap = onItemTap {
                onItemTap(item)
            }

            // Handle selection if enabled
            if selectionBinding != nil {
                var currentSelection = selectionBinding ?? []
                if currentSelection.contains(item.id) {
                    currentSelection.remove(item.id)
                } else {
                    currentSelection.insert(item.id)
                }
                selectionBinding = currentSelection
            }
        }
    }
}

// MARK: - Default Timeline Item Content

/// Default content view for timeline items using protocol properties.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct DefaultTimelineItemContent<Item: TimelineItemRepresentable>: View {
    let item: Item

    @State private var isExpanded = false

    // Check if description is long (more than 100 characters)
    private var isLongDescription: Bool {
        (item.timelineDescription?.count ?? 0) > 100
    }

    // Truncated description for collapsed state
    private var truncatedDescription: String? {
        guard let description = item.timelineDescription, isLongDescription else {
            return item.timelineDescription
        }
        return String(description.prefix(100)) + "..."
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            if let title = item.timelineTitle {
                Text(title)
                    .font(.headline)
            }

            // Description
            if let description = item.timelineDescription {
                if isLongDescription {
                    Text(isExpanded ? description : (truncatedDescription ?? description))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Text(isExpanded ? "Show Less" : "Show More")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                } else {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Date and Status
            HStack {
                Text(item.timelineDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                if let status = item.timelineStatus {
                    Spacer()
                    Text(status.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status.color.opacity(0.2))
                        .foregroundStyle(status.color)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Basic Timeline") {
    struct PreviewWrapper: View {
        @State private var items: [TimelineItem] = [
            TimelineItem(
                date: Date().addingTimeInterval(-3600),
                title: "Task Started",
                description: "Begin work on the project",
                status: .completed
            ),
            TimelineItem(
                date: Date().addingTimeInterval(-1800),
                title: "In Progress",
                description: "Currently working on implementation",
                status: .inProgress
            ),
            TimelineItem(
                date: Date(),
                title: "Next Step",
                description: "Pending review and approval",
                status: .pending
            )
        ]

        var body: some View {
            NavigationStack {
                Timeline(items: items)
                    .navigationTitle("Timeline")
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Timeline Styles") {
    struct PreviewWrapper: View {
        let items: [TimelineItem] = [
            TimelineItem(date: Date().addingTimeInterval(-7200), title: "Completed", status: .completed),
            TimelineItem(date: Date().addingTimeInterval(-3600), title: "In Progress", status: .inProgress),
            TimelineItem(date: Date(), title: "Pending", status: .pending)
        ]

        var body: some View {
            TabView {
                Timeline(items: items)
                    .timelineStyle(.vertical)
                    .tabItem { Label("Vertical", systemImage: "list.bullet") }

                Timeline(items: items)
                    .timelineStyle(.horizontal)
                    .tabItem { Label("Horizontal", systemImage: "rectangle.grid.1x2") }

                Timeline(items: items)
                    .timelineStyle(.compact)
                    .tabItem { Label("Compact", systemImage: "square.grid.2x2") }

                Timeline(items: items)
                    .timelineStyle(.github)
                    .tabItem { Label("GitHub", systemImage: "arrow.triangle.branch") }
            }
        }
    }

    return PreviewWrapper()
}
