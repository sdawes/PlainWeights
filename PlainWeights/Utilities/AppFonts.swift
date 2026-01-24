//
//  AppFonts.swift
//  PlainWeights
//
//  Centralized font configuration - change fonts in ONE place
//

import SwiftUI

// MARK: - Font Configuration (CHANGE FONTS HERE)

enum AppFontFamily {
    /// Primary app font - change this value to swap fonts app-wide
    static let primary = "RobotoMono"

    // Future use:
    // static let secondary = "AnotherFont"
}

// MARK: - Font Weights

enum AppFontWeight {
    case thin, light, regular, medium, semiBold, bold

    /// Constructs the full font name for a given family
    func fontName(for family: String) -> String {
        "\(family)-\(rawName)"
    }

    private var rawName: String {
        switch self {
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semiBold: return "SemiBold"
        case .bold: return "Bold"
        }
    }
}

// MARK: - Font API

extension Font {
    /// Create app font with specific size
    static func appFont(size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        .custom(weight.fontName(for: AppFontFamily.primary), size: size)
    }

    /// Create app font with text style (dynamic type support)
    static func appFont(_ style: Font.TextStyle, weight: AppFontWeight = .regular) -> Font {
        .custom(weight.fontName(for: AppFontFamily.primary), size: style.size, relativeTo: style)
    }
}

// MARK: - Text Style Sizes

extension Font.TextStyle {
    /// Default sizes for each text style
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}