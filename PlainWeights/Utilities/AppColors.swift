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

    // Future custom colors can be added here:
    // static let ptw_accent = Color(...)
    // static let ptw_success = Color(...)
    // static let ptw_error = Color(...)
}
