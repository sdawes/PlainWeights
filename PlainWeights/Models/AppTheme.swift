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

    // MARK: - Chart Colors

    /// Primary chart color (for weight line)
    var chartColor1: Color {
        switch self {
        case .light: return Color(red: 0.92, green: 0.45, blue: 0.18)  // Vibrant orange
        case .dark: return Color(red: 0.45, green: 0.50, blue: 0.95)   // Bright blue/purple
        }
    }

    /// Secondary chart color (for reps line)
    var chartColor2: Color {
        switch self {
        case .light: return Color(red: 0.18, green: 0.70, blue: 0.65)  // Vibrant teal
        case .dark: return Color(red: 0.45, green: 0.82, blue: 0.58)   // Bright green
        }
    }

    // MARK: - PB (Personal Best) Color

    /// Gold color for PB indicators
    var pbColor: Color {
        switch self {
        case .light: return Color(red: 1.0, green: 0.75, blue: 0.0)   // Bright vivid gold
        case .dark: return Color(red: 1.0, green: 0.82, blue: 0.2)    // Brighter gold for contrast
        }
    }

    /// Subtle background tint for PB rows
    var pbBackgroundTint: Color {
        Color.yellow.opacity(0.12)
    }

    // MARK: - Inter Font

    /// Get the Inter font name for a specific weight
    private func interFontName(for weight: Font.Weight) -> String {
        switch weight {
        case .thin, .ultraLight:
            return "Inter-Regular_Thin"
        case .light:
            return "Inter-Regular_Light"
        case .regular:
            return "Inter-Regular"
        case .medium:
            return "Inter-Regular_Medium"
        case .semibold:
            return "Inter-Regular_SemiBold"
        case .bold:
            return "Inter-Regular_Bold"
        case .heavy, .black:
            return "Inter-Regular_Black"
        default:
            return "Inter-Regular"
        }
    }

    /// Inter font for general text
    func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(interFontName(for: weight), size: size)
    }

    /// Inter font for numerical data with tabular figures
    func dataFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(interFontName(for: weight), size: size)
            .monospacedDigit()
    }

    // MARK: - Semantic Font Helpers

    var headlineFont: Font { interFont(size: 17, weight: .semibold) }
    var bodyFont: Font { interFont(size: 17, weight: .regular) }
    var subheadlineFont: Font { interFont(size: 15, weight: .regular) }
    var captionFont: Font { interFont(size: 12, weight: .regular) }
    var caption2Font: Font { interFont(size: 11, weight: .regular) }
    var footnoteFont: Font { interFont(size: 13, weight: .regular) }
    var title2Font: Font { interFont(size: 22, weight: .bold) }
    var title3Font: Font { interFont(size: 20, weight: .semibold) }
}
