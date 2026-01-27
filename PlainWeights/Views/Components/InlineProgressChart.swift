//
//  InlineProgressChart.swift
//  PlainWeights
//
//  Inline progress chart component that shows weight and reps trends
//  over time with dual Y-axis visualization.
//

import SwiftUI
import Charts

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let date: Date
    let dateLabel: String
    let maxWeight: Double
    let maxReps: Int
    let normalizedWeight: Double
    let normalizedReps: Double
}

// MARK: - Inline Progress Chart

struct InlineProgressChart: View {
    @Environment(ThemeManager.self) private var themeManager
    let sets: [ExerciseSet]

    // Animation state
    @State private var isAnimating = false

    // MARK: - Data Transformation

    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        // Filter out warm-up and bonus sets
        let workingSets = sets.filter { !$0.isWarmUp && !$0.isBonus }

        // Group sets by day
        let grouped = Dictionary(grouping: workingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Calculate max weight and reps per day
        var dataPoints: [(date: Date, maxWeight: Double, maxReps: Int)] = []
        for (date, daySets) in grouped {
            let maxWeight = daySets.map { $0.weight }.max() ?? 0
            let maxReps = daySets.map { $0.reps }.max() ?? 0
            dataPoints.append((date, maxWeight, maxReps))
        }

        // Sort by date ascending
        dataPoints.sort { $0.date < $1.date }

        // Calculate normalization ranges (with padding for visual clarity)
        let weightMax = dataPoints.map { $0.maxWeight }.max() ?? 1
        let weightMin = dataPoints.map { $0.maxWeight }.min() ?? 0
        let repsMax = Double(dataPoints.map { $0.maxReps }.max() ?? 1)
        let repsMin = Double(dataPoints.map { $0.maxReps }.min() ?? 0)

        // Add 10% padding to ranges
        let weightPadding = max((weightMax - weightMin) * 0.1, 1)
        let repsPadding = max((repsMax - repsMin) * 0.1, 1)

        let weightRange = max(weightMax - weightMin + weightPadding * 2, 1)
        let repsRange = max(repsMax - repsMin + repsPadding * 2, 1)

        let adjustedWeightMin = weightMin - weightPadding
        let adjustedRepsMin = repsMin - repsPadding

        // Create chart data points with normalized values and index
        return dataPoints.enumerated().map { index, point in
            ChartDataPoint(
                index: index,
                date: point.date,
                dateLabel: dateFormatter.string(from: point.date),
                maxWeight: point.maxWeight,
                maxReps: point.maxReps,
                normalizedWeight: (point.maxWeight - adjustedWeightMin) / weightRange,
                normalizedReps: (Double(point.maxReps) - adjustedRepsMin) / repsRange
            )
        }
    }

    // Axis range values for labels
    private var weightRange: (min: Double, max: Double) {
        let weights = chartData.map { $0.maxWeight }
        let minVal = weights.min() ?? 0
        let maxVal = weights.max() ?? 100
        let padding = max((maxVal - minVal) * 0.1, 1)
        return (min: minVal - padding, max: maxVal + padding)
    }

    private var repsRange: (min: Int, max: Int) {
        let reps = chartData.map { $0.maxReps }
        let minVal = reps.min() ?? 0
        let maxVal = reps.max() ?? 10
        let padding = max(Int(Double(maxVal - minVal) * 0.1), 1)
        return (min: max(0, minVal - padding), max: maxVal + padding)
    }

    // Check if there's only one data point
    private var hasSingleDataPoint: Bool {
        chartData.count == 1
    }

    // Check if this is a reps-only exercise (all weights are 0)
    private var isRepsOnly: Bool {
        let workingSets = sets.filter { !$0.isWarmUp && !$0.isBonus }
        return workingSets.allSatisfy { $0.weight == 0 }
    }

    // Determine if data spans multiple years
    private var spansMultipleYears: Bool {
        guard let first = chartData.first?.date,
              let last = chartData.last?.date else { return false }
        let calendar = Calendar.current
        return calendar.component(.year, from: first) != calendar.component(.year, from: last)
    }

    // Format date based on data span - ultra compact
    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        if spansMultipleYears {
            formatter.dateFormat = "M/yy"   // "1/25" - month/year
        } else {
            formatter.dateFormat = "d/M"    // "27/1" - day/month
        }
        return formatter.string(from: date)
    }

    // Calculate evenly-spaced indices for X-axis labels (max 5)
    private var xAxisIndices: [Int] {
        let count = chartData.count
        guard count > 1 else { return count == 1 ? [0] : [] }

        let maxLabels = min(5, count)
        if count <= maxLabels {
            return Array(0..<count)
        }

        // Evenly spaced indices including first and last
        var indices: [Int] = []
        let step = Double(count - 1) / Double(maxLabels - 1)
        for i in 0..<maxLabels {
            indices.append(Int(round(Double(i) * step)))
        }
        return indices
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(themeManager.currentTheme.headlineFont)
                .foregroundStyle(themeManager.currentTheme.primaryText)

            if chartData.isEmpty {
                emptyState
            } else {
                chartWithAxes
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                legendView
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .padding(16)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        Text("No data yet. Log sets to see progress.")
            .font(themeManager.currentTheme.subheadlineFont)
            .foregroundStyle(themeManager.currentTheme.mutedForeground)
            .frame(height: 200)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Chart with Y-Axes

    @ViewBuilder
    private var chartWithAxes: some View {
        HStack(alignment: .center, spacing: 4) {
            if isRepsOnly {
                // Reps-only: single Y-axis on left for reps (green/teal)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(repsRange.max)")
                    Spacer()
                    Text("\((repsRange.min + repsRange.max) / 2)")
                    Spacer()
                    Text("\(repsRange.min)")
                }
                .font(themeManager.currentTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.currentTheme.chartColor2)
                .frame(width: 25, height: 180)

                // Main chart
                chartView
                    .frame(height: 200)
            } else {
                // Dual Y-axes: weight on left, reps on right
                VStack(alignment: .trailing, spacing: 0) {
                    Text(Formatters.formatWeight(weightRange.max))
                    Spacer()
                    Text(Formatters.formatWeight((weightRange.min + weightRange.max) / 2))
                    Spacer()
                    Text(Formatters.formatWeight(weightRange.min))
                }
                .font(themeManager.currentTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.currentTheme.chartColor1)
                .frame(width: 35, height: 180)

                // Main chart
                chartView
                    .frame(height: 200)

                // Right Y-axis labels (Reps)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(repsRange.max)")
                    Spacer()
                    Text("\((repsRange.min + repsRange.max) / 2)")
                    Spacer()
                    Text("\(repsRange.min)")
                }
                .font(themeManager.currentTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.currentTheme.chartColor2)
                .frame(width: 25, height: 180)
            }
        }
    }

    // MARK: - Chart View

    @ViewBuilder
    private var chartView: some View {
        Chart(chartData) { point in
            if hasSingleDataPoint {
                // Single point: show dot at center
                if isRepsOnly {
                    // Reps-only: show single reps dot in green/teal
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Reps", 0.5)
                    )
                    .foregroundStyle(themeManager.currentTheme.chartColor2)
                    .symbolSize(50)
                } else {
                    // Weight and reps: show both dots
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Weight", 0.5)
                    )
                    .foregroundStyle(themeManager.currentTheme.chartColor1)
                    .symbolSize(50)

                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Reps", 0.5)
                    )
                    .foregroundStyle(themeManager.currentTheme.chartColor2)
                    .symbolSize(50)
                }
            } else if isRepsOnly {
                // Reps-only: show reps as solid line with gradient (no weight line)
                // Uses chartColor2 (green/teal) to match the reps color

                // Reps area gradient
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "RepsArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.currentTheme.chartColor2.opacity(0.3),
                                 themeManager.currentTheme.chartColor2.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                // Reps line (solid)
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "Reps")
                )
                .foregroundStyle(themeManager.currentTheme.chartColor2)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)
            } else {
                // Multiple points with weight and reps: show both lines

                // Weight area gradient
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Weight", point.normalizedWeight),
                    series: .value("Type", "WeightArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.currentTheme.chartColor1.opacity(0.3),
                                 themeManager.currentTheme.chartColor1.opacity(0.05)],
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
                .foregroundStyle(themeManager.currentTheme.chartColor1)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)

                // Reps line (dashed, no gradient)
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "Reps")
                )
                .foregroundStyle(themeManager.currentTheme.chartColor2)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .interpolationMethod(.monotone)
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisIndices) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(themeManager.currentTheme.borderColor)
                AxisTick()
                if let index = value.as(Int.self), index < chartData.count {
                    AxisValueLabel {
                        Text(formatDateLabel(chartData[index].date))
                            .font(.system(size: 9))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)
                    }
                }
            }
        }
        .chartXScale(domain: 0...(max(chartData.count - 1, 1)))
        .chartYAxis {
            AxisMarks(values: [0.0, 0.25, 0.5, 0.75, 1.0]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(themeManager.currentTheme.borderColor)
            }
        }
        .chartYScale(domain: 0...1)
    }

    // MARK: - Legend View

    @ViewBuilder
    private var legendView: some View {
        HStack(spacing: 16) {
            if isRepsOnly {
                // Only show reps legend for reps-only exercises (green/teal)
                legendItem(color: themeManager.currentTheme.chartColor2, label: "Reps", isDashed: false)
            } else {
                // Show both weight and reps legends
                legendItem(color: themeManager.currentTheme.chartColor1, label: "Weight (kg)", isDashed: false)
                legendItem(color: themeManager.currentTheme.chartColor2, label: "Reps", isDashed: true)
            }
        }
        .font(themeManager.currentTheme.captionFont)
        .foregroundStyle(themeManager.currentTheme.mutedForeground)
    }

    @ViewBuilder
    private func legendItem(color: Color, label: String, isDashed: Bool) -> some View {
        HStack(spacing: 4) {
            if isDashed {
                // Dashed line indicator
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(color)
                            .frame(width: 4, height: 2)
                    }
                }
            } else {
                // Solid line indicator
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
            }
            Text(label)
        }
    }
}

// MARK: - Preview

#Preview {
    InlineProgressChart(sets: [])
        .padding()
        .environment(ThemeManager())
}
