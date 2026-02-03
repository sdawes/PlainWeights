//
//  TagAnalysisView.swift
//  PlainWeights
//
//  Tag analysis screen showing usage patterns and statistics.
//

import SwiftUI

struct TagAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Tag Analysis")
                    .font(themeManager.currentTheme.title3Font)
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Placeholder content
            Spacer()
            Text("Tag analysis coming soon")
                .font(themeManager.currentTheme.subheadlineFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .background(themeManager.currentTheme.background)
    }
}
