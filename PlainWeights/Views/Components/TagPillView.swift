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

    // Truncate very long tags and ensure lowercase
    private var displayTag: String {
        let lowercased = tag.lowercased()
        if lowercased.count > 20 {
            return String(lowercased.prefix(17)) + "..."
        }
        return lowercased
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(displayTag)
                .font(.caption)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(themeManager.currentTheme.mutedForeground.opacity(0.7))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(themeManager.currentTheme.muted)
        .clipShape(RoundedRectangle(cornerRadius: 4))
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
