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
}
