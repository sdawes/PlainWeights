//
//  ChevronDisclosureButton.swift
//  PlainWeights
//
//  Reusable styled chevron indicator used for expand/collapse toggles
//  and "load more" buttons. Shows a filled circle with a chevron icon.
//  Light mode: blue circle, white chevron. Dark mode: white circle, dark chevron.
//  Chevron starts pointing down (collapsed) and rotates to point up (expanded).
//

import SwiftUI

struct ChevronDisclosureButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let isExpanded: Bool

    private var isDark: Bool {
        themeManager.effectiveTheme == .dark
    }

    /// Circle fill: uses the chart weight color (orange in light, blue/purple in dark)
    private var circleFill: Color {
        themeManager.effectiveTheme.chartColor1
    }

    /// Chevron color: white in light mode, dark in dark mode
    private var chevronColor: Color {
        isDark ? .black : .white
    }

    var body: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 7, weight: .bold))
            .foregroundStyle(chevronColor)
            .frame(width: 16, height: 16)
            .background(circleFill)
            .clipShape(.circle)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}
