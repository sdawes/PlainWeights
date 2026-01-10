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
            return Color.white
        case .dark:
            return Color(red: 0.141, green: 0.161, blue: 0.2) // #242933
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
            return Color(.secondaryLabel)
        case .dark:
            return Color.white.opacity(0.7)
        }
    }

    var tertiaryTextColor: Color {
        switch self {
        case .light:
            return Color(.tertiaryLabel)
        case .dark:
            return Color.white.opacity(0.5)
        }
    }

    var cardBackgroundColor: Color {
        switch self {
        case .light:
            return Color(.systemBackground)
        case .dark:
            return Color(red: 0.18, green: 0.2, blue: 0.25) // Slightly lighter than bg
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
