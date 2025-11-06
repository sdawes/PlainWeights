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
}

// MARK: - Chart Toggle Button

struct ChartToggleButton: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack(spacing: 4) {
                Text(isExpanded ? "Hide Chart" : "Show Chart")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            .id(isExpanded)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chart Content

struct ChartContentView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    // Compute daily max weights and reps from sets
    private var chartData: [WeightDataPoint] {
        let calendar = Calendar.current

        // Filter out warm-up sets
        let workingSets = sets.filter { !$0.isWarmUp }

        // Group sets by day
        let grouped = Dictionary(grouping: workingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // For each day, find the set with max weight and get its reps
        let dataPoints = grouped.compactMap { (date, daySets) -> WeightDataPoint? in
            guard let maxWeightSet = daySets.max(by: { $0.weight < $1.weight }) else {
                return nil
            }
            return WeightDataPoint(date: date, weight: maxWeightSet.weight, reps: maxWeightSet.reps)
        }

        // Sort by date
        return dataPoints.sorted { $0.date < $1.date }
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
            Text("PERFORMANCE CHART")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if chartData.isEmpty {
                // Empty state
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("No data to display")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            } else {
                // Dual y-axis line chart
                Chart(chartData) { dataPoint in
                    // Weight area with gradient
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.weight / weightMax),
                        series: .value("Type", "Weight")
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Weight line (normalized to 0-1 scale)
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.weight / weightMax),
                        series: .value("Type", "Weight")
                    )
                    .foregroundStyle(.blue)

                    // Reps line (normalized to 0-1 scale)
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Reps", Double(dataPoint.reps) / repsMax),
                        series: .value("Type", "Reps")
                    )
                    .foregroundStyle(.green)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 200)
            }
        }
    }
}

// MARK: - Full Chart View (with toggle and content)

struct ExerciseChartView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chart content (only when expanded)
            if isExpanded {
                ChartContentView(exercise: exercise, sets: sets)
            }
        }
    }
}
