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
    var onRemove: (() -> Void)?

    // Truncate very long tags and ensure lowercase
    private var displayTag: String {
        let lowercased = tag.lowercased()
        if lowercased.count > 20 {
            return String(lowercased.prefix(17)) + "..."
        }
        return lowercased
    }

    // Primary tags: standard grey
    // Secondary tags: lighter grey
    private var pillBackground: Color {
        isSecondary
            ? themeManager.effectiveTheme.muted.opacity(0.5)
            : themeManager.effectiveTheme.muted
    }

    private var textColor: Color {
        isSecondary
            ? themeManager.effectiveTheme.mutedForeground.opacity(0.6)
            : themeManager.effectiveTheme.mutedForeground
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
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

/// Display-only version without remove button (for lists)
struct TagPillsRow: View {
    let tags: [String]
    var secondaryTags: [String] = []

    var body: some View {
        if tags.isEmpty && secondaryTags.isEmpty {
            EmptyView()
        } else {
            FlowLayout(spacing: 4) {
                // Primary tags
                ForEach(tags, id: \.self) { tag in
                    TagPillView(tag: tag)
                }
                // Secondary tags (grey styling)
                ForEach(secondaryTags, id: \.self) { tag in
                    TagPillView(tag: tag, isSecondary: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
