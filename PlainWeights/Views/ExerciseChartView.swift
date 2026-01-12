//
//  ExerciseChartView.swift
//  PlainWeights
//
//  Chart component for visualizing exercise performance over time
//

import SwiftUI
import Charts

// MARK: - Data Model

struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let reps: Int
    let isPB: Bool
}

// MARK: - Exercise Chart Type

enum ExerciseChartType {
    case repsOnly
    case weightAndReps
}

// MARK: - Empty Chart Preview

/// Ghost chart preview shown when no data exists yet
struct EmptyChartPreview: View {
    @Environment(ThemeManager.self) private var themeManager

    private var chartColor: Color {
        themeManager.currentTheme == .dark ? .white : .black
    }

    // Mock data points for the placeholder chart
    private let mockWeightData: [(day: Int, value: Double)] = [
        (0, 0.3), (1, 0.45), (2, 0.5), (3, 0.7), (4, 0.85)
    ]
    private let mockRepsData: [(day: Int, value: Double)] = [
        (0, 0.5), (1, 0.55), (2, 0.6), (3, 0.65), (4, 0.75)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Chart {
                // Weight area gradient (matches real chart)
                ForEach(mockWeightData, id: \.day) { point in
                    AreaMark(
                        x: .value("Day", point.day),
                        y: .value("Weight", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [chartColor.opacity(0.15), chartColor.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                // Weight line
                ForEach(mockWeightData, id: \.day) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Weight", point.value)
                    )
                    .foregroundStyle(chartColor)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }

                // Reps line (dotted)
                ForEach(mockRepsData, id: \.day) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Reps", point.value),
                        series: .value("Type", "Reps")
                    )
                    .foregroundStyle(chartColor)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .frame(height: 100)
            .opacity(0.8)

            // Text below chart
            Text("Your progress chart will appear here")
                .font(.jetBrainsMono(.caption))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Chart Toggle Button

struct ChartToggleButton: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack(spacing: 4) {
                Text("Chart")
                    .font(.jetBrainsMono(.caption))
                    .foregroundStyle(.blue)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.jetBrainsMono(size: 10))
                    .foregroundStyle(.blue)
            }
            .id(isExpanded)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

// MARK: - Chart Content

struct ChartContentView: View {
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    let sets: [ExerciseSet]

    private var chartColor: Color {
        themeManager.currentTheme == .dark ? .white : .black
    }

    // Determine exercise chart type based on weight data
    private var exerciseChartType: ExerciseChartType {
        let workingSets = sets.filter { !$0.isWarmUp && !$0.isBonus }
        let allZeroWeight = workingSets.allSatisfy { $0.weight == 0 }
        return allZeroWeight ? .repsOnly : .weightAndReps
    }

    // Compute daily max weights and reps from sets
    private var chartData: [WeightDataPoint] {
        let calendar = Calendar.current

        // Filter out warm-up sets
        let workingSets = sets.filter { !$0.isWarmUp && !$0.isBonus }

        // Group sets by day
        let grouped = Dictionary(grouping: workingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // For each day, find the appropriate max set based on exercise type
        let dataPoints = grouped.compactMap { (date, daySets) -> WeightDataPoint? in
            // Check if any set on this day is a PB
            let hasPB = daySets.contains { $0.isPB }

            if exerciseChartType == .repsOnly {
                // For reps-only: find max reps per day
                guard let maxRepsSet = daySets.max(by: { $0.reps < $1.reps }) else {
                    return nil
                }
                return WeightDataPoint(date: date, weight: 0, reps: maxRepsSet.reps, isPB: hasPB)
            } else {
                // For weight exercises: find max weight, then highest reps at that weight
                let maxWeight = daySets.map { $0.weight }.max() ?? 0

                // Get all sets with that max weight
                let maxWeightSets = daySets.filter { $0.weight == maxWeight }

                // Among max weight sets, find the one with highest reps
                guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else {
                    return nil
                }
                return WeightDataPoint(date: date, weight: bestSet.weight, reps: bestSet.reps, isPB: hasPB)
            }
        }

        // Sort by date
        return dataPoints.sorted { $0.date < $1.date }
    }

    // Check if we have only a single data point
    private var hasSingleDataPoint: Bool {
        chartData.count == 1
    }

    // Normalization values for dual y-axis
    private var weightMax: Double {
        chartData.map { $0.weight }.max() ?? 1
    }

    private var repsMax: Double {
        Double(chartData.map { $0.reps }.max() ?? 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if chartData.isEmpty {
                // Empty state - ghost chart preview
                EmptyChartPreview()
            } else {
                // Adaptive chart based on exercise type
                Chart(chartData) { dataPoint in
                    if exerciseChartType == .repsOnly {
                        if hasSingleDataPoint {
                            // Single data point: show small dot only
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Reps", dataPoint.reps)
                            )
                            .foregroundStyle(chartColor)
                            .symbolSize(20)  // Smaller dot
                        } else {
                            // Multiple points: show line with gradient
                            // Subtle gradient under reps line
                            AreaMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Reps", dataPoint.reps)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [chartColor.opacity(0.15), chartColor.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Reps", dataPoint.reps)
                            )
                            .foregroundStyle(chartColor)
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        }
                    } else {
                        // Weight and reps: show both series
                        if hasSingleDataPoint {
                            // Single data point: show dot for weight (use actual value, not normalized)
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Weight", dataPoint.weight)
                            )
                            .foregroundStyle(chartColor)
                            .symbolSize(20)  // Smaller dot

                            // Single data point: show dot for reps (use actual value, not normalized)
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Reps", dataPoint.reps)
                            )
                            .foregroundStyle(chartColor)
                            .symbolSize(20)  // Smaller dot
                        } else {
                            // Multiple points: show lines with gradient

                            // Subtle gradient under weight line
                            AreaMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Weight", dataPoint.weight / weightMax),
                                series: .value("Type", "Weight")
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [chartColor.opacity(0.15), chartColor.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            // Weight line (solid)
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Weight", dataPoint.weight / weightMax),
                                series: .value("Type", "Weight")
                            )
                            .foregroundStyle(chartColor)
                            .lineStyle(StrokeStyle(lineWidth: 1))

                            // Reps line (dotted)
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Reps", Double(dataPoint.reps) / repsMax),
                                series: .value("Type", "Reps")
                            )
                            .foregroundStyle(chartColor)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        }
                    }

                    // PB indicator: vertical line from top to bottom with badge at top
                    if dataPoint.isPB {
                        // Vertical line extending from top to bottom of chart
                        RuleMark(x: .value("PB Date", dataPoint.date))
                            .foregroundStyle(.purple.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1))

                        // PB badge at top (positioned using invisible point)
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("PB", exerciseChartType == .repsOnly ? Double(dataPoint.reps) :
                                       (hasSingleDataPoint ? max(dataPoint.weight, Double(dataPoint.reps)) : 1.0))
                        )
                        .opacity(0)  // Invisible point, just for annotation positioning
                        .annotation(position: .top, spacing: 4) {
                            Circle()
                                .fill(.purple)
                                .frame(width: 12, height: 12)
                                .overlay {
                                    Text("PB")
                                        .font(.jetBrainsMono(size: 6))
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 100)

                // Custom legend below chart (only for multi-point charts)
                if !hasSingleDataPoint {
                    HStack(spacing: 12) {
                        if exerciseChartType == .weightAndReps {
                            // Weight legend item
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(chartColor)
                                    .frame(width: 8, height: 8)
                                Text("Weight")
                                    .font(.jetBrainsMono(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Reps legend item
                        HStack(spacing: 4) {
                            Circle()
                                .fill(chartColor)
                                .frame(width: 8, height: 8)
                            Text("Reps")
                                .font(.jetBrainsMono(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - Full Chart View (with toggle and content)

struct ExerciseChartView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chart content (only when expanded)
            if isExpanded {
                ChartContentView(exercise: exercise, sets: sets)
            }
        }
    }
}
