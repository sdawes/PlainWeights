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

    // Animation progress for bar roll-out effect (0 to 1) - per row for stagger
    @State private var animationProgress: [Int: Double] = [:]

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
            ForEach(Array(data.enumerated()), id: \.element.tag) { index, item in
                let isLast = index == data.count - 1

                tagRow(
                    tag: item.tag,
                    percentage: item.percentage,
                    color: Self.color(for: index),
                    isLast: isLast,
                    rowIndex: index
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .onAppear {
            triggerStaggeredAnimation()
        }
        .onChange(of: data.map { $0.tag }) { _, _ in
            triggerStaggeredAnimation()
        }
    }

    private func triggerStaggeredAnimation() {
        // Reset all progress
        animationProgress = [:]

        // Stagger each row's animation
        for index in 0..<data.count {
            let delay = Double(index) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animationProgress[index] = 1
                }
            }
        }
    }

    @ViewBuilder
    private func tagRow(tag: String, percentage: Double, color: Color, isLast: Bool, rowIndex: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Tag name
                Text(tag)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .frame(width: 90, alignment: .leading)
                    .lineLimit(1)

                // Bar area - all bars start from left, width proportional to percentage
                GeometryReader { geometry in
                    let progress = animationProgress[rowIndex] ?? 0
                    let barWidth = geometry.size.width * (percentage / maxPercentage) * progress

                    HStack(spacing: 0) {
                        // Colored vertical bar (left edge)
                        Rectangle()
                            .fill(color)
                            .frame(width: 3)

                        // % value inside shaded area
                        Text("\(Int(percentage))%")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                            .monospacedDigit()
                            .padding(.leading, 10)

                        Spacer(minLength: 0)
                    }
                    .frame(width: barWidth, height: geometry.size.height)
                    .background(color.opacity(themeManager.currentTheme == .dark ? 0.2 : 0.12))
                }
                .frame(height: 28)
            }
            .padding(.vertical, 6)

            // Divider (except for last row)
            if !isLast {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
            }
        }
    }
}
