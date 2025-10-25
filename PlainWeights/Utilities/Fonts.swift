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

    // MARK: - Metric Card Fonts

    /// Caption font for metric card labels (WEIGHT, REPS, VOLUME)
    static let metricLabel: Font = .system(.caption, design: .monospaced)

    /// Large font for metric card values (numbers)
    static let metricValue: Font = .system(size: 32, weight: .bold, design: .monospaced)

    /// Font for metric card units (kg, reps)
    static let metricUnit: Font = .system(size: 18, weight: .semibold, design: .monospaced)

    /// Caption font for metric card progress indicators
    static let metricProgress: Font = .system(.caption, design: .monospaced)

    // MARK: - Sets Display Fonts

    /// Footnote font for section headers (TODAY'S SETS)
    static let sectionHeader: Font = .system(.footnote, design: .monospaced)

    /// Body font for set details (12 kg x 12 reps)
    static let setDetail: Font = .system(.body, design: .monospaced)

    /// Caption font for time labels
    static let timeLabel: Font = .system(.caption, design: .monospaced)

    /// Caption font for historic date headers
    static let dateHeader: Font = .system(.caption, design: .monospaced)
}
