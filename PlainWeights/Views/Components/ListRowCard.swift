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
