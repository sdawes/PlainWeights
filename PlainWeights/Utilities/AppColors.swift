//
//  AppColors.swift
//  PlainWeights
//
//  Centralized color theme for PlainWeights app
//

import SwiftUI

/// Extension providing custom app-wide colors
extension Color {
    /// Light grey background - lighter than systemGroupedBackground but not white
    /// Used for main backgrounds and card backgrounds
    /// RGB: (247, 247, 247) - #F7F7F7
    static let ptw_lightGrey = Color(red: 0.97, green: 0.97, blue: 0.97)

    // MARK: - PlainWeights Theme Colors (iPhone 17-Inspired)

    // Orange family (inspired by iPhone 17 Pro Cosmic Orange)
    /// Light orange for subtle backgrounds and highlights
    static let pw_orangeLight = Color(red: 0.98, green: 0.65, blue: 0.35)
    /// Cosmic Orange - warm burnt orange for accents and primary actions
    static let pw_orange = Color(red: 0.93, green: 0.47, blue: 0.20)
    /// Dark orange for depth and contrast
    static let pw_orangeDark = Color(red: 0.75, green: 0.35, blue: 0.10)

    // Blue family (inspired by iPhone 17 Pro Deep Blue)
    /// Light blue for secondary accents and backgrounds
    static let pw_blueLight = Color(red: 0.35, green: 0.55, blue: 0.75)
    /// Bright iOS blue for borders, highlights, and interactive elements
    static let pw_blue = Color(red: 0.0, green: 0.48, blue: 1.0)
    /// Deep Blue - rich, dark blue for depth and sophistication
    static let pw_blueDark = Color(red: 0.11, green: 0.28, blue: 0.45)

    // Grey family (inspired by iPhone 17 Silver/neutral tones)
    /// Very light grey for card backgrounds and subtle surfaces
    static let pw_greyLight = Color(red: 0.95, green: 0.95, blue: 0.96)
    /// Medium grey for secondary text and dividers
    static let pw_grey = Color(red: 0.75, green: 0.75, blue: 0.77)
    /// Dark grey for primary text and strong contrast
    static let pw_greyDark = Color(red: 0.35, green: 0.35, blue: 0.37)

    // Accent colors
    /// Cyan/turquoise for app branding
    static let pw_cyan = Color(red: 103/255, green: 222/255, blue: 251/255) // RGB(103, 222, 251)

    // Progress indicators
    /// Red for negative progress indicators
    static let pw_red = Color.red
    /// Green for positive progress indicators (slightly darker than system green)
    static let pw_green = Color(red: 0.2, green: 0.78, blue: 0.35)
    /// Amber/gold for overflow/bonus progress beyond 100%
    static let pw_amber = Color(red: 0.95, green: 0.66, blue: 0.11) // #f2a81d
}
