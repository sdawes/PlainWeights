import Charts
import SwiftUI

/// A ghosted preview chart shown when no historical data exists yet.
/// Renders realistic sample data at low opacity to show users what
/// their progress chart will look like after a few sessions.
struct GhostChartPreview: View {
    @Environment(ThemeManager.self) private var themeManager

    private let dataPoints = GhostPreviewData.chartDataPoints

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ghostChartWithAxes
                ghostLegend
            }
            .opacity(0.18)
            .accessibilityHidden(true)

            Text("Your progress appears here")
                .font(themeManager.effectiveTheme.subheadlineFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
        }
    }

    // MARK: - Chart with Y-Axes

    @ViewBuilder
    private var ghostChartWithAxes: some View {
        HStack(alignment: .center, spacing: 4) {
            // Left Y-axis: reps (sample range 8–11)
            VStack(alignment: .trailing, spacing: 0) {
                Text("11")
                Spacer()
                Text("9")
                Spacer()
                Text("8")
            }
            .font(themeManager.effectiveTheme.dataFont(size: 10))
            .foregroundStyle(themeManager.effectiveTheme.chartColor2)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(width: 25, height: 130)

            // Chart
            ghostChartView
                .frame(height: 150)

            // Right Y-axis: weight (sample range 37.5–43)
            VStack(alignment: .leading, spacing: 0) {
                Text("43")
                Spacer()
                Text("40")
                Spacer()
                Text("37.5")
            }
            .font(themeManager.effectiveTheme.dataFont(size: 10))
            .foregroundStyle(themeManager.effectiveTheme.chartColor1)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(width: 35, height: 130)
        }
    }

    // MARK: - Legend

    @ViewBuilder
    private var ghostLegend: some View {
        HStack(spacing: 16) {
            // Weight legend (solid line)
            HStack(spacing: 4) {
                Rectangle()
                    .fill(themeManager.effectiveTheme.chartColor1)
                    .frame(width: 16, height: 2)
                Text("Max Weight (kg)")
            }
            // Reps legend (dashed line)
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(themeManager.effectiveTheme.chartColor2)
                            .frame(width: 4, height: 2)
                    }
                }
                Text("Max Reps")
            }
        }
        .font(themeManager.effectiveTheme.captionFont)
        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
    }

    // MARK: - Chart View

    @ViewBuilder
    private var ghostChartView: some View {
        Chart(dataPoints) { point in
            // Weight area gradient
            AreaMark(
                x: .value("Index", point.index),
                y: .value("Weight", point.normalizedWeight),
                series: .value("Type", "WeightArea")
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        themeManager.effectiveTheme.chartColor1.opacity(0.3),
                        themeManager.effectiveTheme.chartColor1.opacity(0.05),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.monotone)

            // Weight line (solid)
            LineMark(
                x: .value("Index", point.index),
                y: .value("Weight", point.normalizedWeight),
                series: .value("Type", "Weight")
            )
            .foregroundStyle(themeManager.effectiveTheme.chartColor1)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.monotone)

            // Reps line (dashed)
            LineMark(
                x: .value("Index", point.index),
                y: .value("Reps", point.normalizedReps),
                series: .value("Type", "Reps")
            )
            .foregroundStyle(themeManager.effectiveTheme.chartColor2)
            .lineStyle(StrokeStyle(lineWidth: 1.0, dash: [5, 3]))
            .interpolationMethod(.monotone)

            // Endpoint dots
            if point.index == 0 || point.index == dataPoints.count - 1 {
                PointMark(
                    x: .value("Index", point.index),
                    y: .value("Weight", point.normalizedWeight)
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor1)
                .symbolSize(20)

                PointMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps)
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                .symbolSize(16)
            }

            // PB indicators
            if point.isPB {
                RuleMark(x: .value("Index", point.index))
                    .foregroundStyle(themeManager.effectiveTheme.pbColor.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                PointMark(
                    x: .value("Index", point.index),
                    y: .value("PB", 1.0)
                )
                .symbol {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(themeManager.effectiveTheme.pbColor)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...(dataPoints.count - 1))
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...1)
        .chartPlotStyle { plotArea in
            plotArea.overlay(alignment: .bottom) {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 0.5)
            }
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 0.5)
            }
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 0.5)
            }
        }
    }
}
