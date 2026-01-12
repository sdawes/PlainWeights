//
//  AppFonts.swift
//  PlainWeights
//
//  Centralized font configuration using JetBrains Mono
//

import SwiftUI

extension Font {
    /// Font weight options for JetBrains Mono
    enum JetBrainsWeight {
        case thin, extraLight, light, regular, medium, semiBold, bold, extraBold

        var fontName: String {
            switch self {
            case .thin: return "JetBrainsMono-Thin"
            case .extraLight: return "JetBrainsMono-ExtraLight"
            case .light: return "JetBrainsMono-Light"
            case .regular: return "JetBrainsMono-Regular"
            case .medium: return "JetBrainsMono-Medium"
            case .semiBold: return "JetBrainsMono-SemiBold"
            case .bold: return "JetBrainsMono-Bold"
            case .extraBold: return "JetBrainsMono-ExtraBold"
            }
        }
    }

    /// Create JetBrains Mono font with specific size
    static func jetBrainsMono(size: CGFloat, weight: JetBrainsWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)
    }

    /// Create JetBrains Mono font with text style (dynamic type support)
    static func jetBrainsMono(_ style: Font.TextStyle, weight: JetBrainsWeight = .regular) -> Font {
        .custom(weight.fontName, size: style.size, relativeTo: style)
    }
}

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
