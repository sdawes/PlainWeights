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
    var onRemove: (() -> Void)?

    // Inverted colors: text is opposite of background
    private var highlightBackground: Color {
        themeManager.currentTheme == .dark ? .white : .black
    }

    private var highlightText: Color {
        themeManager.currentTheme == .dark ? .black : .white
    }

    // Truncate very long tags
    private var displayTag: String {
        if tag.count > 20 {
            return String(tag.prefix(17)) + "..."
        }
        return tag
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(displayTag)
                .font(.jetBrainsMono(.caption))
                .foregroundStyle(highlightText)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(highlightText.opacity(0.7))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(highlightBackground)
    }
}

/// Display-only version without remove button (for lists)
struct TagPillsRow: View {
    let tags: [String]

    var body: some View {
        if tags.isEmpty {
            EmptyView()
        } else {
            FlowLayout(spacing: 4) {
                ForEach(tags, id: \.self) { tag in
                    TagPillView(tag: tag)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
