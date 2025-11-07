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
            TimelineItem(
                date: Date().addingTimeInterval(-7200),
                title: "Project Milestone Reached",
                description: "Successfully delivered all requirements and met acceptance criteria",
                status: .completed
            ),
            TimelineItem(
                date: Date().addingTimeInterval(-3600),
                title: "Development Sprint",
                description: "Currently implementing core features and functionality",
                status: .inProgress
            ),
            TimelineItem(
                date: Date(),
                title: "Code Review Scheduled",
                description: "Awaiting peer review and approval before merge",
                status: .review
            )
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

#Preview("GitHub Branching Timeline") {
    // Create items with fixed IDs so parent references work correctly
    let commit1Id = UUID()
    let commit2Id = UUID()
    let featureBranch1Id = UUID()
    let commit3Id = UUID()
    let featureBranch2Id = UUID()
    let merge1Id = UUID()

    let items = [
        TimelineItem(
            id: commit1Id,
            date: Date().addingTimeInterval(-10000),
            title: "Initial commit",
            description: "Set up project structure",
            status: .completed
        ),
        TimelineItem(
            id: commit2Id,
            date: Date().addingTimeInterval(-8000),
            title: "Add authentication",
            description: "Implement user login and registration",
            status: .completed,
            parentIds: [commit1Id]
        ),
        TimelineItem(
            id: commit3Id,
            date: Date().addingTimeInterval(-7000),
            title: "Fix auth bug",
            description: "Resolve token expiration issue",
            status: .completed,
            parentIds: [commit2Id]
        ),
        TimelineItem(
            id: featureBranch1Id,
            date: Date().addingTimeInterval(-6000),
            title: "Feature: Dark mode",
            description: "Start implementing dark mode support",
            status: .inProgress,
            parentIds: [commit2Id]
        ),
        TimelineItem(
            id: featureBranch2Id,
            date: Date().addingTimeInterval(-5000),
            title: "Complete dark mode",
            description: "Finish dark mode implementation",
            status: .completed,
            parentIds: [featureBranch1Id]
        ),
        TimelineItem(
            id: merge1Id,
            date: Date().addingTimeInterval(-3000),
            title: "Merge: Dark mode",
            description: "Merge dark mode feature into main",
            status: .completed,
            parentIds: [commit3Id, featureBranch2Id]
        ),
        TimelineItem(
            id: UUID(),
            date: Date().addingTimeInterval(-1000),
            title: "Update dependencies",
            description: "Bump package versions",
            status: .review,
            parentIds: [merge1Id]
        )
    ]

    return NavigationStack {
        Timeline(items: items)
            .timelineStyle(.github)
            .navigationTitle("Git History")
    }
}

#Preview("Complex Branching Timeline (50 items, 5 levels)") {
    // Create a complex Git-style history with 50 items across 5 branch levels
    func createComplexHistory() -> [TimelineItem] {
        let baseTime = Date().addingTimeInterval(-100000)
        var items: [TimelineItem] = []
        var commitIds: [Int: UUID] = [:]  // Store commit IDs by index

        // Helper to create commit
        func commit(_ index: Int, _ title: String, _ description: String, _ status: TimelineStatus, parents: [Int]) -> TimelineItem {
            let id = UUID()
            commitIds[index] = id
            let parentIds = parents.compactMap { commitIds[$0] }
            return TimelineItem(
                id: id,
                date: baseTime.addingTimeInterval(Double(index) * 2000),
                title: title,
                description: description,
                status: status,
                parentIds: parentIds.isEmpty ? nil : parentIds
            )
        }

        // Main branch and multiple feature branches
        items.append(commit(0, "Initial commit", "Project setup and structure", .completed, parents: []))
        items.append(commit(1, "Add core framework", "Implement base architecture", .completed, parents: [0]))
        items.append(commit(2, "Setup CI/CD", "Configure GitHub Actions", .completed, parents: [1]))

        // Feature branch 1: Authentication (lane 1)
        items.append(commit(3, "Start auth feature", "Begin authentication implementation", .completed, parents: [2]))

        // Continue main
        items.append(commit(4, "Update dependencies", "Bump library versions", .completed, parents: [2]))

        // Continue auth branch
        items.append(commit(5, "Add login endpoint", "Implement user login API", .completed, parents: [3]))
        items.append(commit(6, "Add registration", "User signup functionality", .completed, parents: [5]))

        // Feature branch 2: UI Components (lane 2)
        items.append(commit(7, "Start UI library", "Begin component library", .inProgress, parents: [4]))

        // Continue auth
        items.append(commit(8, "Add password reset", "Forgot password feature", .completed, parents: [6]))

        // Continue main
        items.append(commit(9, "Fix build warnings", "Clean up compiler warnings", .completed, parents: [4]))

        // Continue UI branch
        items.append(commit(10, "Add button components", "Reusable button styles", .completed, parents: [7]))

        // Merge auth to main
        items.append(commit(11, "Merge: Authentication", "Merge auth feature into main", .completed, parents: [9, 8]))

        // Feature branch 3: Database (lane 1, reusing lane)
        items.append(commit(12, "Start database layer", "Setup database models", .completed, parents: [11]))

        // Continue UI branch
        items.append(commit(13, "Add form components", "Input fields and validation", .completed, parents: [10]))

        // Sub-feature from UI: Theming (lane 3)
        items.append(commit(14, "Start theming system", "Dark/light mode support", .inProgress, parents: [13]))

        // Continue database
        items.append(commit(15, "Add migrations", "Database schema versioning", .completed, parents: [12]))
        items.append(commit(16, "Add seed data", "Initial test data", .completed, parents: [15]))

        // Continue main
        items.append(commit(17, "Update README", "Improve documentation", .completed, parents: [11]))

        // Continue UI branch
        items.append(commit(18, "Add modal components", "Dialog and sheet views", .completed, parents: [13]))

        // Continue theming
        items.append(commit(19, "Implement color tokens", "Design system colors", .completed, parents: [14]))
        items.append(commit(20, "Add theme switcher", "Toggle dark/light mode", .completed, parents: [19]))

        // Merge database to main
        items.append(commit(21, "Merge: Database layer", "Integrate database with main", .completed, parents: [17, 16]))

        // Feature branch 4: API Integration (lane 1)
        items.append(commit(22, "Start API client", "REST API client library", .completed, parents: [21]))

        // Continue UI
        items.append(commit(23, "Add navigation", "Routing and nav components", .completed, parents: [18]))

        // Continue theming
        items.append(commit(24, "Add animations", "Theme transition effects", .completed, parents: [20]))

        // Continue API
        items.append(commit(25, "Add error handling", "API error middleware", .completed, parents: [22]))
        items.append(commit(26, "Add retry logic", "Automatic retry on failure", .completed, parents: [25]))

        // Continue main
        items.append(commit(27, "Security audit", "Fix security vulnerabilities", .review, parents: [21]))

        // Merge theming to UI branch
        items.append(commit(28, "Merge: Theming", "Integrate theming into UI lib", .completed, parents: [23, 24]))

        // Feature branch 5: Testing (lane 2)
        items.append(commit(29, "Start test suite", "Setup testing framework", .inProgress, parents: [27]))

        // Continue API
        items.append(commit(30, "Add caching", "Response cache layer", .completed, parents: [26]))

        // Continue UI
        items.append(commit(31, "Add accessibility", "ARIA labels and keyboard nav", .completed, parents: [28]))

        // Sub-feature from API: WebSocket (lane 3)
        items.append(commit(32, "Start WebSocket", "Real-time communication", .inProgress, parents: [30]))

        // Continue testing
        items.append(commit(33, "Add unit tests", "Core functionality tests", .completed, parents: [29]))
        items.append(commit(34, "Add integration tests", "API integration tests", .completed, parents: [33]))

        // Continue main
        items.append(commit(35, "Performance tuning", "Optimize critical paths", .completed, parents: [27]))

        // Merge API to main
        items.append(commit(36, "Merge: API client", "Integrate API client", .completed, parents: [35, 30]))

        // Continue WebSocket
        items.append(commit(37, "Add reconnection", "Auto-reconnect on disconnect", .completed, parents: [32]))
        items.append(commit(38, "Add heartbeat", "Keep-alive mechanism", .completed, parents: [37]))

        // Continue UI
        items.append(commit(39, "Add loading states", "Skeleton screens", .completed, parents: [31]))

        // Continue testing
        items.append(commit(40, "Add E2E tests", "End-to-end test suite", .completed, parents: [34]))

        // Deep feature from WebSocket: Presence (lane 4)
        items.append(commit(41, "Start presence", "User presence tracking", .inProgress, parents: [38]))

        // Merge UI to main
        items.append(commit(42, "Merge: UI Components", "Integrate UI library", .completed, parents: [36, 39]))

        // Continue testing
        items.append(commit(43, "Add performance tests", "Benchmark critical paths", .completed, parents: [40]))

        // Continue presence
        items.append(commit(44, "Add status broadcast", "Share user status", .completed, parents: [41]))

        // Merge WebSocket to main
        items.append(commit(45, "Merge: WebSocket", "Integrate real-time features", .completed, parents: [42, 38]))

        // Merge testing to main
        items.append(commit(46, "Merge: Testing", "Add comprehensive test suite", .completed, parents: [45, 43]))

        // Continue presence (still on branch)
        items.append(commit(47, "Add typing indicators", "Show when users are typing", .inProgress, parents: [44]))

        // Final main commits
        items.append(commit(48, "Prepare release", "Version bump and changelog", .review, parents: [46]))

        // Merge presence to main
        items.append(commit(49, "Merge: Presence system", "Add user presence features", .completed, parents: [48, 47]))

        return items
    }

    let items = createComplexHistory()

    return NavigationStack {
        Timeline(items: items)
            .timelineStyle(.github)
            .navigationTitle("Complex Git History (50 items)")
    }
}
