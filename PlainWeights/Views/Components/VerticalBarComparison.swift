//
//  VerticalBarComparison.swift
//  PlainWeights
//
//  Horizontal gauge bars comparing reference, last set, and session best values.
//  Each metric column shows thin horizontal bars stacked under its reference value:
//  grey = reference, colored = last set, dashed green = session best today.
//  Bars, deltas, and hints are laid out in aligned rows.
//

import SwiftUI

// MARK: - Data Model

/// Data for a single metric column (e.g. Weight, Reps, or Volume)
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

// MARK: - Vertical Bar Comparison

/// Horizontal gauge bars under each reference value, with aligned delta and hint rows
struct VerticalBarComparison: View {
    @Environment(ThemeManager.self) private var themeManager
    let columns: [BarColumnData]

    private let barHeight: CGFloat = 8
    private let bookendOverhang: CGFloat = 4

    // Whether any column has a last set to show deltas for
    private var hasAnyLastSet: Bool {
        columns.contains { $0.lastSetValue != nil }
    }

    // Whether any column has a volume hint
    private var hasAnyHint: Bool {
        columns.contains { $0.volumeHint != nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Horizontal bars under each metric column
            barsRow
                .padding(.top, 8)
                .padding(.bottom, 4)

            // Delta values row
            if hasAnyLastSet {
                deltasRow
            }

            // Hints row as footer (e.g. "12 to beat")
            if hasAnyHint {
                hintsRow
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Bars Row (gauge bars under each column)

    private var barsRow: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(columns.indices, id: \.self) { index in
                gaugeStack(for: columns[index])
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// Single gauge bar per metric.
    /// Grey track = reference. Colored fill = last set progress.
    /// If session best exceeds last set, green fill from last-set bookend to bar end + green bookend.
    @ViewBuilder
    private func gaugeStack(for data: BarColumnData) -> some View {
        let maxVal = maxValue(for: data)

        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let bookendHeight = barHeight + (bookendOverhang * 2)

            ZStack(alignment: .leading) {
                // Grey track (always full width)
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.effectiveTheme.muted)
                    .frame(width: totalWidth, height: barHeight)

                // Colored fill + bookend — only when a set has been added
                if let lastValue = data.lastSetValue {
                    let fillRatio = max(lastValue / maxVal, 0.02)
                    let fillWidth = CGFloat(fillRatio) * totalWidth

                    let barColor: Color = data.isSame ? .gray.opacity(0.6)
                        : data.isUp ? .green : .red

                    // Last set fill (squared right edge so bookend sits flush)
                    UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4, bottomTrailingRadius: 0, topTrailingRadius: 0)
                        .fill(barColor)
                        .frame(width: fillWidth, height: barHeight)

                    // Last set bookend
                    RoundedRectangle(cornerRadius: 1)
                        .fill(barColor)
                        .frame(width: 2, height: bookendHeight)
                        .offset(x: fillWidth - 1)

                    // Session best: green shading from last-set bookend to best value + green bookend
                    if data.showSessionBest,
                       let bestValue = data.sessionBestValue,
                       bestValue > lastValue {
                        let bestRatio = max(bestValue / maxVal, 0.02)
                        let bestWidth = CGFloat(bestRatio) * totalWidth
                        let greenStart = fillWidth
                        let greenWidth = bestWidth - fillWidth

                        // Green fill between last set and session best
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.green.opacity(0.2))
                            .frame(width: greenWidth, height: barHeight)
                            .offset(x: greenStart)

                        // Green bookend at the session best position
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.green)
                            .frame(width: 2, height: bookendHeight)
                            .offset(x: bestWidth - 1)
                    }
                }
            }
        }
        .frame(height: barHeight + (bookendOverhang * 2))
    }

    // MARK: - Deltas Row

    private var deltasRow: some View {
        HStack(spacing: 0) {
            ForEach(columns.indices, id: \.self) { index in
                deltaView(for: columns[index])
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func deltaView(for data: BarColumnData) -> some View {
        if data.lastSetValue != nil {
            if data.isSame {
                Text("0")
                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            } else {
                let prefix = data.isUp ? "+" : ""
                Text("\(prefix)\(formatValue(data.delta, asWeight: data.formatAsWeight))")
                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .semibold))
                    .foregroundStyle(data.isUp ? .green : .red)
            }
        } else {
            Text(" ")
                .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .semibold))
        }
    }

    // MARK: - Hints Row

    private var hintsRow: some View {
        HStack(spacing: 0) {
            ForEach(columns.indices, id: \.self) { index in
                Group {
                    if let hint = columns[index].volumeHint {
                        let data = columns[index]
                        Text(hint)
                            .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                            .foregroundStyle(data.isUp ? .green : .red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text(" ")
                            .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                    }
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Legend Row

    // MARK: - Helpers

    private func maxValue(for data: BarColumnData) -> Double {
        let values: [Double] = [data.referenceValue, data.sessionBestValue ?? 0, data.lastSetValue ?? 0]
        return max(values.max() ?? 1, 1)
    }

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

