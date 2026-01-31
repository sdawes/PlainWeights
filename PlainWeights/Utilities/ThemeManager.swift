//
//  ThemeManager.swift
//  PlainWeights
//
//  Manages app theme persistence and access
//

import SwiftUI

@Observable
final class ThemeManager {
    private static let themeKey = "selectedTheme"
    private static let chartVisibleKey = "chartVisibleByDefault"

    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.themeKey)
        }
    }

    var chartVisibleByDefault: Bool {
        didSet {
            UserDefaults.standard.set(chartVisibleByDefault, forKey: Self.chartVisibleKey)
        }
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: Self.themeKey) ?? AppTheme.dark.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .dark

        // Chart visibility - defaults to true (visible)
        self.chartVisibleByDefault = UserDefaults.standard.object(forKey: Self.chartVisibleKey) as? Bool ?? true
    }
}
