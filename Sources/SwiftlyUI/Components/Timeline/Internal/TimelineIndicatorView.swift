import SwiftUI

/// A view that displays a timeline indicator with customizable shape, size, and color.
///
/// This internal view is used by timeline styles to render the visual indicator
/// for each timeline item. The indicator's appearance is determined by the item's
/// status and environment configuration.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineIndicatorView: View {
    // MARK: - Properties

    let status: TimelineStatus?
    let isSelected: Bool

    @Environment(\.timelineIndicatorShape) private var shape
    @Environment(\.timelineIndicatorSize) private var size
    @Environment(\.timelineIndicatorColor) private var customColor
    @Environment(\.timelineIndicatorIcon) private var customIcon

    // MARK: - Computed Properties

    private var indicatorColor: Color {
        customColor ?? status?.color ?? .gray
    }

    private var iconName: String? {
        customIcon ?? status?.defaultIcon
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background shape
            Group {
                switch shape {
                case .circle:
                    Circle()
                        .fill(indicatorColor)
                case .roundedSquare(let cornerRadius):
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(indicatorColor)
                case .square:
                    Rectangle()
                        .fill(indicatorColor)
                case .diamond:
                    DiamondShape()
                        .fill(indicatorColor)
                case .custom:
                    Circle()
                        .fill(indicatorColor)
                }
            }
            .frame(width: size, height: size)

            // Icon overlay if available
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(.white)
            }

            // Selection ring
            if isSelected {
                Group {
                    switch shape {
                    case .circle:
                        Circle()
                            .stroke(indicatorColor, lineWidth: 2)
                    case .roundedSquare(let cornerRadius):
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(indicatorColor, lineWidth: 2)
                    case .square:
                        Rectangle()
                            .stroke(indicatorColor, lineWidth: 2)
                    case .diamond:
                        DiamondShape()
                            .stroke(indicatorColor, lineWidth: 2)
                    case .custom:
                        Circle()
                            .stroke(indicatorColor, lineWidth: 2)
                    }
                }
                .frame(width: size + 4, height: size + 4)
            }
        }
    }
}

// MARK: - Diamond Shape

/// A diamond shape for timeline indicators.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let midX = rect.midX
        let midY = rect.midY
        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2

        path.move(to: CGPoint(x: midX, y: midY - halfHeight)) // Top
        path.addLine(to: CGPoint(x: midX + halfWidth, y: midY)) // Right
        path.addLine(to: CGPoint(x: midX, y: midY + halfHeight)) // Bottom
        path.addLine(to: CGPoint(x: midX - halfWidth, y: midY)) // Left
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview

#Preview("Indicator Shapes") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            TimelineIndicatorView(status: .completed, isSelected: false)
                .environment(\.timelineIndicatorShape, .circle)

            TimelineIndicatorView(status: .inProgress, isSelected: false)
                .environment(\.timelineIndicatorShape, .roundedSquare())

            TimelineIndicatorView(status: .pending, isSelected: false)
                .environment(\.timelineIndicatorShape, .square)

            TimelineIndicatorView(status: .blocked, isSelected: false)
                .environment(\.timelineIndicatorShape, .diamond)
        }

        Divider()

        HStack(spacing: 20) {
            TimelineIndicatorView(status: .completed, isSelected: true)
                .environment(\.timelineIndicatorShape, .circle)

            TimelineIndicatorView(status: .inProgress, isSelected: true)
                .environment(\.timelineIndicatorSize, 16)

            TimelineIndicatorView(status: .cancelled, isSelected: false)
                .environment(\.timelineIndicatorColor, .purple)

            TimelineIndicatorView(status: .review, isSelected: false)
                .environment(\.timelineIndicatorIcon, "star.fill")
        }
    }
    .padding()
}
