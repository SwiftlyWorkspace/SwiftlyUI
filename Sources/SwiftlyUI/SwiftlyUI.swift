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
/// ### Layout Components
/// - `FlowLayout`: A layout that arranges subviews in rows, wrapping to new lines as needed
///
/// ## Requirements
/// - iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
/// - Swift 5.7+
import SwiftUI

// Re-export all public types
@_exported import struct SwiftUI.Color

// Make all components available when importing SwiftlyUI
