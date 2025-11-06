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

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with toggle button
            HStack {
                Text("PERFORMANCE CHART")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Hide Chart" : "Show Chart")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }

            // Placeholder chart area (collapsible)
            if isExpanded {
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
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}
