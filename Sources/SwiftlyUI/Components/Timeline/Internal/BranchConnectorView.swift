import SwiftUI

// MARK: - Branch Connector Type

/// The type of connection between timeline items in a branching timeline.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
enum BranchConnectorType {
    /// Straight vertical line within the same lane.
    case straight(from: CGPoint, to: CGPoint)

    /// Curved line moving right (branch creation).
    case curveRight(from: CGPoint, to: CGPoint)

    /// Curved line moving left (branch merge).
    case curveLeft(from: CGPoint, to: CGPoint)

    /// Multiple curves converging to one point (multi-parent merge).
    case multiMerge(from: [CGPoint], to: CGPoint)
}

// MARK: - Branch Connector View

/// Renders connector lines between timeline items with support for branching.
///
/// This view draws lines connecting parent and child items, using bezier curves
/// for branch creation and merge operations to create a GitHub-style appearance.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct BranchConnectorView: View {
    // MARK: - Properties

    let connectorType: BranchConnectorType

    @Environment(\.timelineConnectorWidth) private var lineWidth
    @Environment(\.timelineConnectorColor) private var lineColor
    @Environment(\.timelineBranchConnectorCurve) private var curveRadius

    // MARK: - Body

    var body: some View {
        switch connectorType {
        case .straight(let from, let to):
            straightLine(from: from, to: to)

        case .curveRight(let from, let to):
            curvedLine(from: from, to: to, direction: .right)

        case .curveLeft(let from, let to):
            curvedLine(from: from, to: to, direction: .left)

        case .multiMerge(let fromPoints, let to):
            multiMergeLine(from: fromPoints, to: to)
        }
    }

    // MARK: - Private Views

    /// Renders a straight vertical line.
    private func straightLine(from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(lineColor, lineWidth: lineWidth)
    }

    /// Renders a curved line using bezier curves.
    private func curvedLine(from: CGPoint, to: CGPoint, direction: CurveDirection) -> some View {
        Path { path in
            path.move(to: from)

            // Calculate control points for smooth bezier curve
            let horizontalDistance = abs(to.x - from.x)
            let verticalDistance = to.y - from.y

            // Determine curve parameters based on distance
            let actualCurveRadius = min(curveRadius, horizontalDistance / 2, verticalDistance / 3)

            if direction == .right {
                // Branch creation: curve from left to right
                let control1 = CGPoint(
                    x: from.x,
                    y: from.y + actualCurveRadius
                )
                let control2 = CGPoint(
                    x: to.x,
                    y: to.y - actualCurveRadius
                )
                path.addCurve(to: to, control1: control1, control2: control2)
            } else {
                // Branch merge: curve from right to left
                let control1 = CGPoint(
                    x: from.x,
                    y: from.y + actualCurveRadius
                )
                let control2 = CGPoint(
                    x: to.x,
                    y: to.y - actualCurveRadius
                )
                path.addCurve(to: to, control1: control1, control2: control2)
            }
        }
        .stroke(lineColor, lineWidth: lineWidth)
    }

    /// Renders multiple curved lines converging to a single point.
    private func multiMergeLine(from fromPoints: [CGPoint], to: CGPoint) -> some View {
        ForEach(Array(fromPoints.enumerated()), id: \.offset) { _, point in
            curvedLine(
                from: point,
                to: to,
                direction: point.x < to.x ? .right : .left
            )
        }
    }

    // MARK: - Helper Types

    private enum CurveDirection {
        case left
        case right
    }
}

// MARK: - Environment Key for Curve Radius

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineBranchConnectorCurveKey: EnvironmentKey {
    static let defaultValue: CGFloat = 20
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var timelineBranchConnectorCurve: CGFloat {
        get { self[TimelineBranchConnectorCurveKey.self] }
        set { self[TimelineBranchConnectorCurveKey.self] = newValue }
    }
}

// MARK: - Preview

#Preview("Branch Connectors") {
    ZStack {
        // Background grid for reference
        Path { path in
            for x in stride(from: 0, to: 300, by: 50) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: 300))
            }
            for y in stride(from: 0, to: 300, by: 50) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: 300, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)

        VStack(alignment: .leading, spacing: 30) {
            // Straight line
            BranchConnectorView(connectorType: .straight(
                from: CGPoint(x: 50, y: 0),
                to: CGPoint(x: 50, y: 50)
            ))
            .frame(width: 100, height: 50)

            // Curve right (branch creation)
            BranchConnectorView(connectorType: .curveRight(
                from: CGPoint(x: 50, y: 0),
                to: CGPoint(x: 150, y: 100)
            ))
            .frame(width: 200, height: 100)

            // Curve left (branch merge)
            BranchConnectorView(connectorType: .curveLeft(
                from: CGPoint(x: 150, y: 0),
                to: CGPoint(x: 50, y: 100)
            ))
            .frame(width: 200, height: 100)

            // Multi-merge
            BranchConnectorView(connectorType: .multiMerge(
                from: [
                    CGPoint(x: 50, y: 0),
                    CGPoint(x: 150, y: 0)
                ],
                to: CGPoint(x: 100, y: 100)
            ))
            .frame(width: 200, height: 100)
        }
        .padding()
    }
    .frame(width: 300, height: 500)
}
