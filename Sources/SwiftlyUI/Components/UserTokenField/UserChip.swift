import SwiftUI

/// A view that displays an individual user chip with avatar and removal capability.
///
/// `UserChip` provides a compact representation of a user with the following features:
/// - Avatar display with automatic fallback to initials
/// - Support for both Image and URL-based avatars
/// - Remove button to deselect the user
/// - Hover effects and visual feedback
///
/// ## Avatar Priority
/// 1. If `user.avatarImage` exists → use it
/// 2. Else if `user.avatarURL` exists → load and display it
/// 3. Else → show initials in a colored circle
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct UserChip<User: UserRepresentable>: View {
    // MARK: - Properties

    /// The user to display.
    let user: User

    /// Callback triggered when the user should be removed.
    let onRemove: () -> Void

    @State private var isHovering = false
    @State private var loadedImage: Image?

    // MARK: - Initializers

    /// Creates a new user chip.
    /// - Parameters:
    ///   - user: The user to display.
    ///   - onRemove: Callback triggered when the user should be removed.
    public init(
        user: User,
        onRemove: @escaping () -> Void
    ) {
        self.user = user
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            avatarView
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            Text(user.displayName)
                .font(.subheadline)
                .lineLimit(1)

            #if os(iOS) || os(watchOS) || os(tvOS)
            removeButton
            #else
            if isHovering {
                removeButton
            }
            #endif
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.controlBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.separator.opacity(0.3), lineWidth: 1)
        )
        #if os(macOS)
        .onHover { hovering in
            isHovering = hovering
        }
        #endif
        .task {
            await loadAvatarIfNeeded()
        }
    }

    // MARK: - Private Views

    /// Avatar view with priority: avatarImage > avatarURL > initials
    @ViewBuilder
    private var avatarView: some View {
        if let avatarImage = user.avatarImage {
            avatarImage
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Avatar for \(user.displayName)")
        } else if let loadedImage = loadedImage {
            loadedImage
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Avatar for \(user.displayName)")
        } else {
            initialsAvatar
        }
    }

    /// Fallback avatar showing user initials
    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(user.avatarColor)

            Text(user.initials)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("\(user.displayName) avatar with initials \(user.initials)")
    }

    /// Remove button
    private var removeButton: some View {
        Button(action: onRemove) {
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(user.displayName)")
    }

    // MARK: - Private Methods

    /// Loads the avatar image from URL if available
    private func loadAvatarIfNeeded() async {
        guard user.avatarImage == nil,
              let url = user.avatarURL else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            #if canImport(UIKit)
            if let uiImage = UIKit.UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif canImport(AppKit)
            if let nsImage = AppKit.NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
        } catch {
            // Silently fail and fall back to initials
            // In a production app, you might want to log this error
        }
    }
}
