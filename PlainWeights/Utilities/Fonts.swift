//
//  Fonts.swift
//  PlainWeights
//
//  Centralized font definitions for consistent typography
//

import SwiftUI

enum AppFonts {
    /// Large title font for exercise names - SF Mono Bold
    static let exerciseTitle: Font = .system(.largeTitle, design: .monospaced).bold()

    /// Caption font for exercise notes - SF Mono Regular
    static let exerciseNotes: Font = .system(.caption, design: .monospaced)
}
