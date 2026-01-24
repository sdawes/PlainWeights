//
//  AppTheme.swift
//  PlainWeights
//
//  Theme definitions for the app
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"

    var displayName: String {
        rawValue
    }

    // MARK: - Text Colors

    var primaryText: Color {
        switch self {
        case .light:
            return .black
        case .dark:
            return Color.white.opacity(0.90)
        }
    }

    var secondaryText: Color {
        switch self {
        case .light:
            return Color(red: 0.4, green: 0.4, blue: 0.4)
        case .dark:
            return Color.white.opacity(0.7)
        }
    }

    var tertiaryText: Color {
        switch self {
        case .light:
            return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .dark:
            return Color.white.opacity(0.5)
        }
    }

    // MARK: - Background Colors

    var background1: Color {
        switch self {
        case .light:
            return Color(red: 250/255, green: 250/255, blue: 250/255)  // #FAFAFA
        case .dark:
            return Color(red: 0.05, green: 0.07, blue: 0.09)  // Dark navy
        }
    }

    var background2: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return Color(red: 0.125, green: 0.145, blue: 0.188)  // Card navy (#202530)
        }
    }

    // MARK: - Border Colors

    var border: Color {
        switch self {
        case .light:
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        case .dark:
            return Color(red: 0.216, green: 0.235, blue: 0.294)  // #373C4B
        }
    }

    // MARK: - Accent Colors

    var accent: Color {
        switch self {
        case .light:
            return Color(red: 19/255, green: 133/255, blue: 236/255)  // #1385EC
        case .dark:
            return Color(red: 103/255, green: 222/255, blue: 251/255)  // Bright cyan (#67DEFB)
        }
    }

    // MARK: - Color Scheme

    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    // MARK: - Legacy Compatibility (to be removed after migration)

    var backgroundColor: Color { background1 }
    var cardBackgroundColor: Color { background2 }
    var textColor: Color { primaryText }
    var secondaryTextColor: Color { secondaryText }
    var tertiaryTextColor: Color { tertiaryText }
    var borderColor: Color { border }
}
