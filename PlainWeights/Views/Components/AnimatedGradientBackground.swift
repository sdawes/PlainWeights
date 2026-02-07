//
//  AnimatedGradientBackground.swift
//  PlainWeights
//
//  Theme-aware background
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        themeManager.effectiveTheme.backgroundColor
            .ignoresSafeArea()
    }
}
