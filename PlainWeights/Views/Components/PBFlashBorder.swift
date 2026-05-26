//
//  PBFlashBorder.swift
//  PlainWeights
//
//  Animated yellow/orange gradient stroke used to highlight a new PB
//  on the today's-sets card. Only animates while the flash is visible.
//

import SwiftUI

/// Renders a stroked `Shape` filled with the PB-flash gradient, animating the
/// gradient direction continuously while `opacity > 0`. Outside the flash
/// window the view collapses to `EmptyView`, so it costs nothing at rest.
struct PBFlashBorder<S: Shape>: View {
    @Environment(ThemeManager.self) private var themeManager
    let shape: S
    let opacity: Double
    var lineWidth: CGFloat = 2

    var body: some View {
        if opacity > 0 {
            TimelineView(.animation) { context in
                let phase = context.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 4.0) / 4.0
                let offset = sin(phase * 2 * .pi) * 0.5
                shape
                    .stroke(
                        LinearGradient(
                            colors: themeManager.effectiveTheme.pbGradientColors,
                            startPoint: UnitPoint(x: 0.0 - offset, y: 0.0),
                            endPoint: UnitPoint(x: 1.0 - offset, y: 1.0)
                        ),
                        lineWidth: lineWidth
                    )
                    .opacity(opacity)
            }
            .allowsHitTesting(false)
        }
    }
}
