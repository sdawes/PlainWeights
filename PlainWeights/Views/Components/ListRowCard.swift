//
//  ListRowCard.swift
//  PlainWeights
//
//  Segmented card background for creating unified card appearance
//  across multiple List rows while preserving native swipe actions.
//

import SwiftUI

// MARK: - List Row Card Position

enum ListRowCardPosition {
    case top
    case middle
    case bottom
    case single
}

// MARK: - List Row Card Background

struct ListRowCardBackground: View {
    @Environment(ThemeManager.self) private var themeManager
    let position: ListRowCardPosition

    var body: some View {
        themeManager.currentTheme.cardBackgroundColor
            .clipShape(RoundedCorner(radius: 12, corners: corners))
            .overlay(
                RoundedCorner(radius: 12, corners: corners)
                    .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
            )
    }

    private var corners: UIRectCorner {
        switch position {
        case .top: return [.topLeft, .topRight]
        case .bottom: return [.bottomLeft, .bottomRight]
        case .single: return .allCorners
        case .middle: return []
        }
    }
}

// MARK: - Rounded Corner Shape

/// Shape that allows rounding specific corners only
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Top Open Border Shape

/// Shape that draws top (with rounded corners), left, and right edges only - no bottom edge.
/// Used for card headers that connect seamlessly with rows below.
struct TopOpenBorder: Shape {
    var radius: CGFloat = 12
    var lineWidth: CGFloat = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at bottom-left, go up
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Left edge up to the corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))

        // Top-left rounded corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))

        // Top-right rounded corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge down to bottom
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

// MARK: - Sides Only Border Shape

/// Shape that draws only left and right edges - no top or bottom.
/// Used for middle rows in a card stack.
struct SidesOnlyBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Left edge
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Right edge
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

// MARK: - Bottom Open Border Shape

/// Shape that draws bottom (with rounded corners), left, and right edges only - no top edge.
/// Used for card footers that connect seamlessly with rows above.
struct BottomOpenBorder: Shape {
    var radius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at top-left, go down
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Left edge down to the corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))

        // Bottom-left rounded corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))

        // Bottom-right rounded corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )

        // Right edge up to top
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        return path
    }
}
