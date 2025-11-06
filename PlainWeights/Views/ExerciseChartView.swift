//
//  ExerciseChartView.swift
//  PlainWeights
//
//  Chart component for visualizing exercise performance over time
//

import SwiftUI

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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PERFORMANCE CHART")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    Text("Chart Placeholder")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
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
