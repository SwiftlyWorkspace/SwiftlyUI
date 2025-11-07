/// SwiftlyUI - A collection of reusable SwiftUI components
///
/// SwiftlyUI provides a comprehensive set of customizable SwiftUI components
/// designed for modern iOS, macOS, tvOS, and watchOS applications.
///
/// ## Components
///
/// ### Token Tag Field
/// A powerful tag input component with auto-completion, inline editing,
/// and customizable styling.
///
/// ```swift
/// @State private var tags: [Tag] = []
/// @State private var inputText = ""
///
/// TokenTagField(
///     tags: $tags,
///     inputText: $inputText,
///     suggestedTags: suggestedTags,
///     onAdd: { tag in tags.append(tag) },
///     onRemove: { tag in tags.removeAll { $0.id == tag.id } },
///     onUpdate: { updatedTag in
///         if let index = tags.firstIndex(where: { $0.id == updatedTag.id }) {
///             tags[index] = updatedTag
///         }
///     }
/// )
/// ```
///
/// ### User Token Field
/// A search-based user selection component with avatar display and auto-completion.
///
/// ```swift
/// @State private var selectedUsers: [SwiftlyUIUser] = []
/// @State private var searchText = ""
///
/// UserTokenField(
///     selectedUsers: $selectedUsers,
///     searchText: $searchText,
///     availableUsers: allUsers,
///     onAdd: { user in selectedUsers.append(user) },
///     onRemove: { user in selectedUsers.removeAll { $0.id == user.id } }
/// )
/// ```
///
/// Works with any type conforming to `UserRepresentable`:
/// ```swift
/// extension MyUser: UserRepresentable {
///     // Conform to protocol requirements
/// }
/// ```
///
/// ### Multi-Picker System
/// A comprehensive multi-selection picker system with multiple presentation styles
/// and powerful features for selecting multiple items from lists.
///
/// #### Basic MultiPicker
/// ```swift
/// @State private var selection: Set<Int> = []
///
/// MultiPicker("Choose Options", selection: $selection) {
///     Text("Option 1").multiPickerTag(1)
///     Text("Option 2").multiPickerTag(2)
///     Text("Option 3").multiPickerTag(3)
/// }
/// .multiPickerStyle(.inline)
/// ```
///
/// #### SearchableMultiPicker
/// For large lists with search/filter functionality:
/// ```swift
/// @State private var selection: Set<String> = []
/// @State private var searchText = ""
///
/// SearchableMultiPicker("Select Countries", selection: $selection, searchText: $searchText) {
///     ForEach(countries) { country in
///         Text(country.name).multiPickerTag(country.id)
///     }
/// }
/// ```
///
/// #### GroupedMultiPicker (Sectioned)
/// For categorized/sectioned data:
/// ```swift
/// @State private var selection: Set<String> = []
///
/// GroupedMultiPicker(
///     title: "Select Foods",
///     sections: [
///         (header: "Fruits", items: [(value: "apple", label: "Apple")]),
///         (header: "Vegetables", items: [(value: "carrot", label: "Carrot")])
///     ],
///     selection: $selection
/// )
/// ```
///
/// **Available Styles**: `.inline`, `.navigationLink`, `.sheet`, `.menu`
/// **Features**: Selection limits, bulk actions, search, sections, customizable display
///
/// ### Timeline
/// A chronological timeline component for displaying events with customizable styles and indicators.
///
/// ```swift
/// @State private var events: [TimelineItem] = [
///     TimelineItem(date: date1, title: "Task Started", status: .inProgress),
///     TimelineItem(date: date2, title: "Task Completed", status: .completed)
/// ]
///
/// Timeline(items: events)
///     .timelineStyle(.vertical)
/// ```
///
/// **Available Styles**: `.vertical`, `.horizontal`, `.compact`, `.github`
/// **Features**:
/// - Automatic date sorting
/// - Customizable indicators (shape, size, color, icons)
/// - Customizable connectors (solid, dashed, dotted)
/// - Expand/collapse long descriptions
/// - Selection support
/// - Status-based coloring (pending, inProgress, completed, cancelled, blocked, review)
///
/// **Customization Examples**:
/// ```swift
/// Timeline(items: events)
///     .timelineIndicator(shape: .roundedSquare(), size: 16, color: .blue)
///     .timelineConnector(width: 3, style: .dashed)
///     .timelineLayout(spacing: 20, indicatorPosition: .trailing)
/// ```
///
/// Works with any type conforming to `TimelineItemRepresentable`:
/// ```swift
/// extension MyEvent: TimelineItemRepresentable {
///     var timelineDate: Date { eventDate }
///     var timelineTitle: String? { eventName }
///     var timelineDescription: String? { eventDetails }
///     var timelineStatus: TimelineStatus? { status }
/// }
/// ```
///
/// **Branching Support** (GitHub Style):
/// Timeline automatically detects and visualizes branch relationships when parent IDs are provided:
/// ```swift
/// // Create commits with parent relationships
/// let commit1 = TimelineItem(date: date1, title: "Initial commit")
/// let commit2 = TimelineItem(date: date2, title: "Main work", parentIds: [commit1.id])
/// let feature = TimelineItem(date: date3, title: "Feature work", parentIds: [commit1.id])
/// let merge = TimelineItem(date: date4, title: "Merge feature", parentIds: [commit2.id, feature.id])
///
/// // GitHub style automatically shows branches and merges
/// Timeline(items: [commit1, commit2, feature, merge])
///     .timelineStyle(.github)
/// ```
///
/// **Branch Customization**:
/// ```swift
/// Timeline(items: commits)
///     .timelineStyle(.github)
///     .timelineBranchLaneWidth(250)        // Adjust lane spacing
///     .timelineBranchConnectorCurve(30)     // Smoother curves
///     .timelineBranchIndicators(true)       // Show branch/merge dots
/// ```
///
/// **Convenience Methods**:
/// ```swift
/// let parent = TimelineItem(date: date1, title: "Parent")
/// let child = TimelineItem(date: date2, title: "Child").withParent(parent.id)
/// let merge = TimelineItem(date: date3, title: "Merge").withParents([parent.id, child.id])
/// ```
///
/// ### Layout Components
/// - `FlowLayout`: A layout that arranges subviews in rows, wrapping to new lines as needed
///
/// ## Requirements
/// - iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+ (MultiPicker, Timeline components)
/// - iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ (Other components)
/// - Swift 5.7+
import SwiftUI

// Re-export all public types
@_exported import struct SwiftUI.Color

// Make all components available when importing SwiftlyUI
