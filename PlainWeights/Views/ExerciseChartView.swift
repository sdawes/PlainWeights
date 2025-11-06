//
//  ExerciseChartView.swift
//  PlainWeights
//
//  Chart component for visualizing exercise performance over time
//

import SwiftUI

struct ExerciseChartView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("PERFORMANCE CHART")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            // Placeholder chart area
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
