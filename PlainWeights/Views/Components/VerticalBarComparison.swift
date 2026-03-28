//
//  VerticalBarComparison.swift
//  PlainWeights
//
//  The gauge section of the Session Comparison Card. Sits below the reference
//  metrics (Max Weight, Reps, Total Volume) and shows horizontal gauge bars
//  comparing the user's current session against those reference values.
//
//  Layout (top to bottom):
//    ┌─────────────────────────────────────────────┐
//    │  Gauges Row — one gauge bar per metric       │
//    │  Deltas Row — +/- change values per metric   │
//    │  ─────────────────────────────────────────── │
//    │  Footer Hint — e.g. "12 reps to beat volume" │
//    └─────────────────────────────────────────────┘
//
//  Each gauge bar shows:
//    - Grey track = reference value (what they did last time / best ever)
//    - Colored fill = last set progress (green if up, red if down, grey if same)
//    - Green shading = session best that exceeds the last set
//

import SwiftUI

// MARK: - Gauge Column Data

/// Data for a single metric column (e.g. Weight, Reps, or Volume).
/// Built by ComparisonMetricsCard from cached session data.
struct BarColumnData: Equatable {
    let label: String
    let referenceValue: Double
    let sessionBestValue: Double?
    let lastSetValue: Double?
    let delta: Double
    let isUp: Bool
    let isSame: Bool
    let showSessionBest: Bool
    let formatAsWeight: Bool
    var volumeHint: String?
}

// MARK: - Session Comparison Gauges

/// Horizontal gauge bars with aligned delta and footer hint rows
struct VerticalBarComparison: View {
    @Environment(ThemeManager.self) private var themeManager
    let columns: [BarColumnData]

    private let barHeight: CGFloat = 8

    /// Whether any column has a last set value (determines if deltas row shows)
    private var hasAnyLastSet: Bool {
        columns.contains { $0.lastSetValue != nil }
    }

    /// Whether the footer hint row should be shown
    private var hasAnyHint: Bool {
        columns.contains { $0.volumeHint != nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gauges — one horizontal bar per metric, aligned under reference values above
            gaugesRow
                .padding(.top, 8)
                .padding(.bottom, hasAnyLastSet ? 4 : 16)

            // Deltas — the +/- change value for each metric (e.g. "-5", "+2", "-275")
            if hasAnyLastSet {
                deltasRow
                    .padding(.bottom, hasAnyHint ? 0 : 12)
            }

            // Footer hint — e.g. "12 reps to beat total volume"
            if hasAnyHint {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
                    .padding(.top, 8)

                footerHintRow
                    .padding(.top, 9)
                    .padding(.bottom, 11)
            }
        }
    }

    // MARK: - Gauges Row

    /// One gauge bar per metric, left-aligned under its reference value
    private var gaugesRow: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(columns.indices, id: \.self) { index in
                gaugeBar(for: columns[index])
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// A single gauge bar: grey track (reference), colored fill (last set),
    /// optional green shading (session best exceeding last set), and a small
    /// label showing the session best value at the end of the green shading
    @ViewBuilder
    private func gaugeBar(for data: BarColumnData) -> some View {
        let maxVal = maxValue(for: data)

        GeometryReader { geometry in
            let totalWidth = geometry.size.width

            ZStack(alignment: .leading) {
                // Grey track — represents the reference value (always full width)
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.effectiveTheme.muted)
                    .frame(width: totalWidth, height: barHeight)

                // Colored fill + session best shading
                if let lastValue = data.lastSetValue {
                    let fillRatio = max(lastValue / maxVal, 0.02)
                    let fillWidth = CGFloat(fillRatio) * totalWidth

                    let barColor: Color = data.isSame ? .gray.opacity(0.6)
                        : data.isUp ? .green : .red

                    // Session best shading — drawn FIRST so the colored fill overlaps it
                    // Only show when last set is under the reference (not when same/equal)
                    if data.showSessionBest,
                       !data.isSame,
                       let bestValue = data.sessionBestValue,
                       bestValue > lastValue {
                        let bestRatio = max(bestValue / maxVal, 0.02)
                        let bestWidth = CGFloat(bestRatio) * totalWidth
                        // Overlap under the colored fill by 4px to eliminate gap
                        let overlap: CGFloat = 4
                        let greenWidth = bestWidth - fillWidth + overlap

                        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 4, topTrailingRadius: 4)
                            .fill(Color.green.opacity(0.4))
                            .frame(width: greenWidth, height: barHeight)
                            .offset(x: fillWidth - overlap)
                    }

                    // Colored fill — drawn AFTER green so it renders on top
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: fillWidth, height: barHeight)
                }
            }
        }
        .frame(height: barHeight)
    }

    // MARK: - Deltas Row

    /// The +/- change values, one per metric column, aligned under their gauge bars
    private var deltasRow: some View {
        HStack(spacing: 0) {
            ForEach(columns.indices, id: \.self) { index in
                deltaLabel(for: columns[index])
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// A single delta label: "+5", "-2", "+0" (grey when same)
    @ViewBuilder
    private func deltaLabel(for data: BarColumnData) -> some View {
        if data.lastSetValue != nil {
            if data.isSame {
                Text("+0")
                    .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            } else {
                let prefix = data.isUp ? "+" : ""
                Text("\(prefix)\(formatValue(data.delta, asWeight: data.formatAsWeight))")
                    .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .medium))
                    .foregroundStyle(data.isUp ? .green : .red)
            }
        } else {
            Text(" ")
                .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .medium))
        }
    }

    // MARK: - Footer Hint Row

    /// Footer row showing volume progress hint (e.g. "12 reps to beat total volume")
    private var footerHintRow: some View {
        Group {
            if let hintColumn = columns.first(where: { $0.volumeHint != nil }) {
                Text(hintColumn.volumeHint ?? "")
                    .font(themeManager.effectiveTheme.interFont(size: 17, weight: .regular))
                    .foregroundStyle(hintColumn.isUp || hintColumn.isSame ? .green : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Helpers

    /// The highest value across all bars in a column, used to scale gauge widths
    private func maxValue(for data: BarColumnData) -> Double {
        let values: [Double] = [data.referenceValue, data.sessionBestValue ?? 0, data.lastSetValue ?? 0]
        return max(values.max() ?? 1, 1)
    }

    /// Format a delta value for display — uses weight formatter or integer formatting
    private func formatValue(_ value: Double, asWeight: Bool) -> String {
        if asWeight {
            return Formatters.formatWeight(value)
        } else {
            if abs(value) >= 1000 {
                return Formatters.formatVolume(value)
            }
            return "\(Int(value))"
        }
    }
}
