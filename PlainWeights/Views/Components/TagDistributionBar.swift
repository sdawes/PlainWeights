//
//  TagDistributionBar.swift
//  PlainWeights
//
//  Ranked list showing tag distribution with inline bars
//

import SwiftUI

struct TagDistributionBar: View {
    @Environment(ThemeManager.self) private var themeManager

    let data: [(tag: String, percentage: Double)]

    /// Filtered data excluding tags under 1%
    private var visibleData: [(tag: String, percentage: Double)] {
        data.filter { $0.percentage >= 1 }
    }

    // Color palette for chart segments
    static let chartColors: [Color] = [
        Color(red: 0.93, green: 0.47, blue: 0.20),  // Orange
        Color(red: 0.20, green: 0.40, blue: 0.75),  // Deep blue
        Color(red: 0.35, green: 0.70, blue: 0.45),  // Green
        Color(red: 0.75, green: 0.35, blue: 0.55),  // Pink/magenta
        Color(red: 0.55, green: 0.45, blue: 0.70),  // Purple
    ]

    static func color(for index: Int) -> Color {
        chartColors[index % chartColors.count]
    }

    private var maxPercentage: Double {
        data.map { $0.percentage }.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(visibleData.enumerated(), id: \.element.tag) { index, item in
                let isLast = index == visibleData.count - 1

                tagRow(
                    tag: item.tag,
                    percentage: item.percentage,
                    color: Self.color(for: index),
                    isLast: isLast
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func tagRow(tag: String, percentage: Double, color: Color, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(tag)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .frame(width: 90, alignment: .leading)
                    .lineLimit(1)

                GeometryReader { geometry in
                    let barWidth = geometry.size.width * (percentage / maxPercentage)

                    ZStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(color)
                                .frame(width: 3)

                            Rectangle()
                                .fill(color.opacity(themeManager.currentTheme == .dark ? 0.2 : 0.12))
                        }
                        .frame(width: barWidth, height: geometry.size.height)

                        Text("\(Int(percentage))%")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                            .monospacedDigit()
                            .padding(.leading, 13)
                    }
                }
                .frame(height: 28)
            }
            .padding(.vertical, 6)

            if !isLast {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
            }
        }
    }
}
