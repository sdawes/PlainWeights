//
//  AppTheme.swift
//  PlainWeights
//
//  Theme definitions for the app
//  Light: white background, black everything
//  Dark: black background, white everything
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"

    var displayName: String {
        rawValue
    }

    // MARK: - Primary Color (used for text, symbols, progress)

    var primary: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        }
    }

    // MARK: - Text Colors

    var primaryText: Color {
        primary
    }

    var secondaryText: Color {
        primary.opacity(0.6)
    }

    var tertiaryText: Color {
        primary.opacity(0.4)
    }

    // MARK: - Background Color (single background)

    var background: Color {
        switch self {
        case .light: return .white
        case .dark: return .black
        }
    }

    var background1: Color { background }
    var background2: Color { background }

    // MARK: - Border Color

    var border: Color {
        primary.opacity(0.2)
    }

    // MARK: - Muted Colors (for tags, badges, subtle UI)

    var muted: Color {
        switch self {
        case .light: return Color(red: 0.93, green: 0.93, blue: 0.94) // #ececf0
        case .dark: return Color(red: 0.16, green: 0.16, blue: 0.16)  // #2a2a2a
        }
    }

    var mutedForeground: Color {
        switch self {
        case .light: return Color(red: 0.44, green: 0.44, blue: 0.51) // #717182
        case .dark: return Color(red: 0.63, green: 0.63, blue: 0.63)  // #a0a0a0
        }
    }

    // MARK: - Accent Color

    var accent: Color {
        primary
    }

    // MARK: - Progress Colors (all use primary)

    var progressUp: Color { primary }
    var progressDown: Color { primary }
    var progressSame: Color { primary }

    // MARK: - Color Scheme

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }

    // MARK: - Legacy Compatibility

    var backgroundColor: Color { background }
    var cardBackgroundColor: Color { background }
    var textColor: Color { primaryText }
    var secondaryTextColor: Color { secondaryText }
    var tertiaryTextColor: Color { tertiaryText }
    var borderColor: Color { border }

    // MARK: - Data Font (System font for numerical data)

    /// System font for data display - weights, reps, volumes, timers
    func dataFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight)
    }
}
