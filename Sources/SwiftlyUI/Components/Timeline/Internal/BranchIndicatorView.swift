import SwiftUI

/// Displays a visual indicator at branch creation or merge points.
///
/// This view shows a small dot or icon where branches diverge or converge,
/// helping users understand the branch structure of the timeline.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BranchIndicatorView: View {
    // MARK: - Properties

    let branchPoint: BranchPoint

    @Environment(\.timelineBranchIndicatorEnabled) private var isEnabled
    @Environment(\.timelineConnectorColor) private var color

    // MARK: - Body

    var body: some View {
        if isEnabled {
            indicator
        }
    }

    // MARK: - Private Views

    private var indicator: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: indicatorSize, height: indicatorSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )
    }

    // MARK: - Helper Properties

    private var indicatorSize: CGFloat {
        switch branchPoint.type {
        case .create:
            return 6
        case .merge:
            return 6
        }
    }

    private var indicatorColor: Color {
        switch branchPoint.type {
        case .create:
            return Color.blue.opacity(0.8)
        case .merge:
            return Color.purple.opacity(0.8)
        }
    }
}

// MARK: - Environment Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineBranchIndicatorEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var timelineBranchIndicatorEnabled: Bool {
        get { self[TimelineBranchIndicatorEnabledKey.self] }
        set { self[TimelineBranchIndicatorEnabledKey.self] = newValue }
    }
}

// MARK: - Preview

#Preview("Branch Indicators") {
    VStack(spacing: 30) {
        // Branch creation indicator
        HStack {
            Text("Branch Creation:")
                .font(.caption)
            BranchIndicatorView(branchPoint: BranchPoint(
                itemId: AnyHashable(UUID()),
                type: .create,
                fromLane: 0,
                toLane: 1
            ))
        }

        // Merge indicator
        HStack {
            Text("Branch Merge:")
                .font(.caption)
            BranchIndicatorView(branchPoint: BranchPoint(
                itemId: AnyHashable(UUID()),
                type: .merge,
                fromLane: 1,
                toLane: 0
            ))
        }

        // Disabled indicator
        HStack {
            Text("Disabled:")
                .font(.caption)
            BranchIndicatorView(branchPoint: BranchPoint(
                itemId: AnyHashable(UUID()),
                type: .create,
                fromLane: 0,
                toLane: 1
            ))
            .environment(\.timelineBranchIndicatorEnabled, false)
        }
    }
    .padding()
}
