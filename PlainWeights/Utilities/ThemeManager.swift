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
    private static let weightUnitKey = "weightUnit"

    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.themeKey)
        }
    }

    var weightUnit: WeightUnit {
        didSet {
            UserDefaults.standard.set(weightUnit.rawValue, forKey: Self.weightUnitKey)
        }
    }

    /// The system's current color scheme (updated by root view)
    var systemColorScheme: ColorScheme = .light

    /// The effective theme to use for colors (resolves .system to actual theme)
    var effectiveTheme: AppTheme {
        currentTheme.effectiveTheme(for: systemColorScheme)
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
        let savedTheme = UserDefaults.standard.string(forKey: Self.themeKey) ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system

        // Weight unit - defaults to kg
        let savedUnit = UserDefaults.standard.string(forKey: Self.weightUnitKey) ?? WeightUnit.kg.rawValue
        self.weightUnit = WeightUnit(rawValue: savedUnit) ?? .kg

        // Chart visibility - defaults to false (hidden)
        self.chartVisibleByDefault = UserDefaults.standard.object(forKey: Self.chartVisibleKey) as? Bool ?? false

        // Notes visibility - defaults to false (hidden)
        self.notesVisibleByDefault = UserDefaults.standard.object(forKey: Self.notesVisibleKey) as? Bool ?? false
    }

    // MARK: - Weight Conversion Helpers

    /// Convert kg value to display value in current unit
    func displayWeight(_ kg: Double) -> Double {
        weightUnit.fromKg(kg)
    }

    /// Convert display value back to kg for storage
    func toKg(_ displayValue: Double) -> Double {
        weightUnit.toKg(displayValue)
    }
}
