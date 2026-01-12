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

    var backgroundColor: Color {
        switch self {
        case .light:
            return Color(red: 0.96, green: 0.96, blue: 0.94) // Off-white
        case .dark:
            return Color(red: 0.05, green: 0.07, blue: 0.09) // Very dark navy
        }
    }

    var textColor: Color {
        switch self {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .light:
            return Color(red: 0.4, green: 0.4, blue: 0.4) // Dark gray
        case .dark:
            return Color.white.opacity(0.7)
        }
    }

    var tertiaryTextColor: Color {
        switch self {
        case .light:
            return Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
        case .dark:
            return Color.white.opacity(0.5)
        }
    }

    var cardBackgroundColor: Color {
        switch self {
        case .light:
            return Color(.systemBackground)
        case .dark:
            return Color(red: 0.125, green: 0.145, blue: 0.188) // #202530 - RGB(32, 37, 48)
        }
    }

    var borderColor: Color {
        switch self {
        case .light:
            return Color(red: 0.85, green: 0.85, blue: 0.85) // Light gray
        case .dark:
            return Color(red: 0.15, green: 0.165, blue: 0.21) // #262A36 - RGB(38, 42, 54)
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
