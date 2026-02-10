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

    // Minimum percentage to show as its own row (below this gets collapsed)
    private let minPercentageToShow: Double = 8

    // Track expanded state
    @State private var isExpanded = false

    // Animation progress for bar roll-out effect (0 to 1)
    @State private var animationProgress: Double = 0

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

    // Always visible items (>= 5%)
    private var alwaysVisibleItems: [(tag: String, percentage: Double)] {
        data.filter { $0.percentage >= minPercentageToShow }
    }

    // Extra items shown when expanded (< 5%)
    private var extraItems: [(tag: String, percentage: Double)] {
        data.filter { $0.percentage < minPercentageToShow }
    }

    private var collapsedPercentage: Double {
        extraItems.reduce(0) { $0 + $1.percentage }
    }

    // Use max of individual percentages only (stable regardless of expand state)
    private var maxPercentage: Double {
        data.map { $0.percentage }.max() ?? 1
    }

    private var hasMoreItems: Bool {
        !extraItems.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Always visible rows (first 5) - no animation
            ForEach(Array(alwaysVisibleItems.enumerated()), id: \.element.tag) { index, item in
                // Last row hides divider if there are no more items, OR if there are more items (toggle provides divider)
                let isLastVisible = index == alwaysVisibleItems.count - 1
                let isLast = isLastVisible

                tagRow(
                    tag: item.tag,
                    percentage: item.percentage,
                    color: Self.color(for: index),
                    isLast: isLast
                )
            }
            .animation(nil, value: isExpanded)

            // Expandable section
            if hasMoreItems {
                // Toggle row - always present, changes between "+X more" and "Show less"
                VStack(spacing: 0) {
                    // Divider above toggle
                    Rectangle()
                        .fill(themeManager.effectiveTheme.borderColor)
                        .frame(height: 1)

                    // Toggle button
                    HStack {
                        if isExpanded {
                            Spacer()
                            Text("Show less")
                                .font(themeManager.effectiveTheme.interFont(size: 13, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            Image(systemName: "chevron.up")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            Spacer()
                        } else {
                            Text("+\(extraItems.count) more")
                                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        }
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }
                }
                .animation(nil, value: isExpanded)

                // Extra rows - appear below with animation
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(Array(extraItems.enumerated()), id: \.element.tag) { index, item in
                            let actualIndex = alwaysVisibleItems.count + index
                            let isLast = index == extraItems.count - 1

                            tagRow(
                                tag: item.tag,
                                percentage: item.percentage,
                                color: Self.color(for: actualIndex),
                                isLast: isLast
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .onAppear {
            animationProgress = 0
            withAnimation(.easeOut(duration: 0.6)) {
                animationProgress = 1
            }
        }
        .onChange(of: data.map { $0.tag }) { _, _ in
            // Reset and replay animation when data changes
            animationProgress = 0
            withAnimation(.easeOut(duration: 0.6)) {
                animationProgress = 1
            }
        }
    }

    @ViewBuilder
    private func tagRow(tag: String, percentage: Double, color: Color, isLast: Bool) -> some View {
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
                    let barWidth = geometry.size.width * (percentage / maxPercentage) * animationProgress

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
                            .padding(.leading, 6)

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
