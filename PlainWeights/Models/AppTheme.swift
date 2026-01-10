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
