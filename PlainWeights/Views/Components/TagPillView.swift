//
//  TagPillView.swift
//  PlainWeights
//
//  Reusable tag pill component with optional remove button
//

import SwiftUI

struct TagPillView: View {
    @Environment(ThemeManager.self) private var themeManager
    let tag: String
    var isSecondary: Bool = false
    var isHighlighted: Bool = false
    var onRemove: (() -> Void)?

    // Truncate very long tags and ensure lowercase
    private var displayTag: String {
        let lowercased = tag.lowercased()
        if lowercased.count > 20 {
            return String(lowercased.prefix(17)) + "..."
        }
        return lowercased
    }

    // Primary tags: pastel blue
    // Secondary tags: pastel violet
    private var pillBackground: Color {
        isSecondary
            ? themeManager.effectiveTheme.secondaryTagBackground
            : themeManager.effectiveTheme.primaryTagBackground
    }

    private var textColor: Color {
        isSecondary
            ? themeManager.effectiveTheme.secondaryTagText
            : themeManager.effectiveTheme.primaryTagText
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(displayTag)
                .font(themeManager.effectiveTheme.interFont(size: 12, weight: .medium))
                .foregroundStyle(textColor)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(textColor.opacity(0.7))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityLabel("Remove tag \(displayTag)")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isHighlighted ? themeManager.effectiveTheme.chartColor1.opacity(0.2) : pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            isHighlighted
                ? RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(themeManager.effectiveTheme.chartColor1, lineWidth: 1.5)
                : nil
        )
    }
}

/// Display-only version without remove button (for lists)
/// When highlightText is set, matching tags get a highlighted border
struct TagPillsRow: View {
    let tags: [String]
    var secondaryTags: [String] = []
    var highlightText: String = ""

    var body: some View {
        if tags.isEmpty && secondaryTags.isEmpty {
            EmptyView()
        } else {
            FlowLayout(spacing: 4) {
                // Primary tags
                ForEach(tags, id: \.self) { tag in
                    TagPillView(
                        tag: tag,
                        isHighlighted: !highlightText.isEmpty && tag.localizedStandardContains(highlightText)
                    )
                }
                // Secondary tags (grey styling)
                ForEach(secondaryTags, id: \.self) { tag in
                    TagPillView(
                        tag: tag,
                        isSecondary: true,
                        isHighlighted: !highlightText.isEmpty && tag.localizedStandardContains(highlightText)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
