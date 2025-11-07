import SwiftUI

/// A view that displays a connector line between timeline items.
///
/// This internal view renders the visual connection between timeline indicators,
/// supporting solid, dashed, and dotted line styles.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct TimelineConnectorView: View {
    // MARK: - Properties

    let isVertical: Bool
    let length: CGFloat?

    @Environment(\.timelineConnectorWidth) private var width
    @Environment(\.timelineConnectorColor) private var color
    @Environment(\.timelineConnectorStyle) private var style

    // MARK: - Initializers

    init(isVertical: Bool = true, length: CGFloat? = nil) {
        self.isVertical = isVertical
        self.length = length
    }

    // MARK: - Body

    var body: some View {
        if isVertical {
            verticalConnector
        } else {
            horizontalConnector
        }
    }

    // MARK: - Private Views

    private var verticalConnector: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: length)
            .applyConnectorStyle(style, lineWidth: width, isVertical: true)
    }

    private var horizontalConnector: some View {
        Rectangle()
            .fill(color)
            .frame(width: length, height: width)
            .applyConnectorStyle(style, lineWidth: width, isVertical: false)
    }
}

// MARK: - Connector Style Modifier

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private extension View {
    @ViewBuilder
    func applyConnectorStyle(_ style: TimelineConnectorStyle, lineWidth: CGFloat, isVertical: Bool) -> some View {
        switch style {
        case .solid:
            self

        case .dashed:
            if isVertical {
                self.overlay(
                    GeometryReader { geometry in
                        Path { path in
                            let dashLength: CGFloat = 4
                            let gapLength: CGFloat = 4
                            var currentY: CGFloat = 0

                            while currentY < geometry.size.height {
                                path.move(to: CGPoint(x: lineWidth / 2, y: currentY))
                                path.addLine(to: CGPoint(x: lineWidth / 2, y: min(currentY + dashLength, geometry.size.height)))
                                currentY += dashLength + gapLength
                            }
                        }
                        .stroke(Color.clear, lineWidth: lineWidth)
                    }
                )
                .mask(
                    GeometryReader { geometry in
                        Path { path in
                            let dashLength: CGFloat = 4
                            let gapLength: CGFloat = 4
                            var currentY: CGFloat = 0

                            while currentY < geometry.size.height {
                                path.addRect(CGRect(x: 0, y: currentY, width: lineWidth, height: dashLength))
                                currentY += dashLength + gapLength
                            }
                        }
                    }
                )
            } else {
                self.overlay(
                    GeometryReader { geometry in
                        Path { path in
                            let dashLength: CGFloat = 4
                            let gapLength: CGFloat = 4
                            var currentX: CGFloat = 0

                            while currentX < geometry.size.width {
                                path.move(to: CGPoint(x: currentX, y: lineWidth / 2))
                                path.addLine(to: CGPoint(x: min(currentX + dashLength, geometry.size.width), y: lineWidth / 2))
                                currentX += dashLength + gapLength
                            }
                        }
                        .stroke(Color.clear, lineWidth: lineWidth)
                    }
                )
                .mask(
                    GeometryReader { geometry in
                        Path { path in
                            let dashLength: CGFloat = 4
                            let gapLength: CGFloat = 4
                            var currentX: CGFloat = 0

                            while currentX < geometry.size.width {
                                path.addRect(CGRect(x: currentX, y: 0, width: dashLength, height: lineWidth))
                                currentX += dashLength + gapLength
                            }
                        }
                    }
                )
            }

        case .dotted:
            if isVertical {
                self.mask(
                    GeometryReader { geometry in
                        VStack(spacing: 4) {
                            ForEach(0..<Int(geometry.size.height / 6), id: \.self) { _ in
                                Circle()
                                    .frame(width: lineWidth, height: lineWidth)
                            }
                        }
                    }
                )
            } else {
                self.mask(
                    GeometryReader { geometry in
                        HStack(spacing: 4) {
                            ForEach(0..<Int(geometry.size.width / 6), id: \.self) { _ in
                                Circle()
                                    .frame(width: lineWidth, height: lineWidth)
                            }
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Connector Styles") {
    VStack(spacing: 40) {
        // Vertical Connectors
        HStack(spacing: 30) {
            VStack {
                Text("Solid")
                    .font(.caption)
                TimelineConnectorView(isVertical: true, length: 100)
                    .environment(\.timelineConnectorStyle, .solid)
            }

            VStack {
                Text("Dashed")
                    .font(.caption)
                TimelineConnectorView(isVertical: true, length: 100)
                    .environment(\.timelineConnectorStyle, .dashed)
            }

            VStack {
                Text("Dotted")
                    .font(.caption)
                TimelineConnectorView(isVertical: true, length: 100)
                    .environment(\.timelineConnectorStyle, .dotted)
            }
        }

        Divider()

        // Horizontal Connectors
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Solid")
                    .font(.caption)
                TimelineConnectorView(isVertical: false, length: 200)
                    .environment(\.timelineConnectorStyle, .solid)
            }

            VStack(alignment: .leading) {
                Text("Dashed")
                    .font(.caption)
                TimelineConnectorView(isVertical: false, length: 200)
                    .environment(\.timelineConnectorStyle, .dashed)
            }

            VStack(alignment: .leading) {
                Text("Dotted")
                    .font(.caption)
                TimelineConnectorView(isVertical: false, length: 200)
                    .environment(\.timelineConnectorStyle, .dotted)
            }
        }

        Divider()

        // Different widths
        HStack(spacing: 30) {
            TimelineConnectorView(isVertical: true, length: 80)
                .environment(\.timelineConnectorWidth, 1)

            TimelineConnectorView(isVertical: true, length: 80)
                .environment(\.timelineConnectorWidth, 2)

            TimelineConnectorView(isVertical: true, length: 80)
                .environment(\.timelineConnectorWidth, 4)
        }
    }
    .padding()
}
