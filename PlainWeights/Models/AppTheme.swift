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
    case system = "System"

    var displayName: String {
        rawValue
    }

    /// Returns the effective theme for color resolution
    /// When .system is selected, pass in the current system colorScheme
    func effectiveTheme(for systemScheme: ColorScheme) -> AppTheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return systemScheme == .dark ? .dark : .light
        }
    }

    // MARK: - Primary Color (used for text, symbols, progress)

    var primary: Color {
        switch self {
        case .light, .system: return .black
        case .dark: return Color(white: 0.93)  // Slightly softer than pure white
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
        case .light, .system: return .white
        case .dark: return .black
        }
    }

    var background1: Color { background }
    var background2: Color { background }

    // MARK: - Border Color

    var border: Color {
        primary.opacity(0.3)
    }

    // MARK: - Muted Colors (for tags, badges, subtle UI)

    var muted: Color {
        switch self {
        case .light, .system: return Color(red: 0.93, green: 0.93, blue: 0.94) // #ececf0
        case .dark: return Color(red: 0.16, green: 0.16, blue: 0.16)  // #2a2a2a
        }
    }

    var mutedForeground: Color {
        switch self {
        case .light, .system: return Color(red: 0.44, green: 0.44, blue: 0.51) // #717182
        case .dark: return Color(red: 0.63, green: 0.63, blue: 0.63)  // #a0a0a0
        }
    }

    // MARK: - Card Header Background

    var cardHeaderBackground: Color {
        muted.opacity(0.5)  // Was 0.3, now one step darker/lighter
    }

    // MARK: - Dark Mode Detection

    /// Whether this theme uses a dark background (for adjusting tint opacities)
    var isDark: Bool {
        switch self {
        case .dark: return true
        case .light, .system: return false
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

    /// Returns the color scheme to apply, or nil to follow system
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil  // nil = follow system setting
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
        case .light, .system: return Color(red: 0.92, green: 0.45, blue: 0.18)  // Vibrant orange
        case .dark: return Color(red: 0.45, green: 0.50, blue: 0.95)   // Bright blue/purple
        }
    }

    /// Secondary chart color (for reps line)
    var chartColor2: Color {
        switch self {
        case .light, .system: return Color(red: 0.18, green: 0.70, blue: 0.65)  // Vibrant teal
        case .dark: return Color(red: 0.45, green: 0.82, blue: 0.58)   // Bright green
        }
    }

    /// Tertiary chart color (for volume mode)
    var chartColor3: Color {
        switch self {
        case .light, .system: return Color(red: 0.65, green: 0.35, blue: 0.75)  // Purple/violet
        case .dark: return Color(red: 0.85, green: 0.55, blue: 0.65)   // Coral/rose
        }
    }

    /// Quaternary chart color (for total reps in volume mode - reps-only exercises)
    var chartColor4: Color {
        switch self {
        case .light, .system: return Color(red: 0.20, green: 0.40, blue: 0.75)  // Deep blue
        case .dark: return Color(red: 0.95, green: 0.85, blue: 0.55)   // Pastel yellow
        }
    }

    // MARK: - PB (Personal Best) Color

    /// Gold color for PB indicators (#faac05)
    var pbColor: Color {
        Color(red: 0.980, green: 0.675, blue: 0.020)  // #faac05
    }

    /// Subtle background tint for PB rows (stronger in dark mode for visibility)
    var pbBackgroundTint: Color {
        pbColor.opacity(isDark ? 0.20 : 0.12)
    }

    // MARK: - Set Type Colors (static - same across themes)

    /// Color for warm-up sets
    static var warmUpColor: Color { .orange }

    /// Color for drop sets
    static var dropSetColor: Color { .blue }

    /// Color for assisted sets (pink)
    static var assistedColor: Color { Color(red: 1.0, green: 0.2, blue: 0.5) }

    /// Color for timed/tempo sets
    static var timedSetColor: Color { .gray }

    /// Color for pause-at-top sets
    static var pauseAtTopColor: Color { .indigo }

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
