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

    /// Caption font for progress bar label - SF Mono Regular
    static let progressLabel: Font = .system(.caption, design: .monospaced)

    /// Body font for Add Set button - SF Mono Regular
    static let addSetButton: Font = .system(.body, design: .monospaced)
}
