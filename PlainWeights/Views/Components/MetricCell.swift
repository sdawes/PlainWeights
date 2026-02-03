//
//  MetricCell.swift
//  PlainWeights
//
//  Reusable metric cell component for displaying label/value pairs in cards.
//

import SwiftUI

struct MetricCell<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
    }
}

// Convenience initializer for simple string values
extension MetricCell where Content == MetricCellValueText {
    init(label: String, value: String) {
        self.label = label
        self.content = MetricCellValueText(value: value)
    }
}

// Default value text styling
struct MetricCellValueText: View {
    @Environment(ThemeManager.self) private var themeManager
    let value: String

    var body: some View {
        Text(value)
            .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(themeManager.currentTheme.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
