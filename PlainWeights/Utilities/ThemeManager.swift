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

    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.themeKey)
        }
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: Self.themeKey) ?? AppTheme.light.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .light
    }
}
