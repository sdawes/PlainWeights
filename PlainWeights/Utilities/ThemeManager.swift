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
    private static let notesVisibleKey = "notesVisibleByDefault"

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

    var notesVisibleByDefault: Bool {
        didSet {
            UserDefaults.standard.set(notesVisibleByDefault, forKey: Self.notesVisibleKey)
        }
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: Self.themeKey) ?? AppTheme.light.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .light

        // Chart visibility - defaults to false (hidden)
        self.chartVisibleByDefault = UserDefaults.standard.object(forKey: Self.chartVisibleKey) as? Bool ?? false

        // Notes visibility - defaults to false (hidden)
        self.notesVisibleByDefault = UserDefaults.standard.object(forKey: Self.notesVisibleKey) as? Bool ?? false
    }
}
