//
//  TagAnalyticsView.swift
//  PlainWeights
//
//  Tag analytics view for analyzing workout data by tags
//

import SwiftUI
import SwiftData

struct TagAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Tag Analytics")
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
    }
}
