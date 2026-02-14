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
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    var tagDistribution: [(tag: String, percentage: Double)] {
        ExerciseService.todayTagDistribution(context: modelContext)
    }

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
            .padding(.bottom, 24)

            // Content
            if tagDistribution.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tag")
                        .font(.system(size: 40))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground.opacity(0.5))
                    Text("No tagged exercises done today")
                        .font(themeManager.effectiveTheme.bodyFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                VStack(spacing: 24) {
                    // Section header
                    Text("TODAY'S SESSION")
                        .font(themeManager.effectiveTheme.interFont(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Distribution bar chart
                    TagDistributionBar(data: tagDistribution)
                        .frame(maxWidth: .infinity)

                    // Color legend
                    legendView
                }
            }

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
    }

    private var legendView: some View {
        // Compact color legend in a flow layout
        FlowLayout(spacing: 12) {
            ForEach(tagDistribution.enumerated(), id: \.element.tag) { index, item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(TagDistributionBar.color(for: index))
                        .frame(width: 10, height: 10)
                    Text(item.tag)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                }
            }
        }
        .padding(.top, 8)
    }
}
