//
//  WorkoutMetrics.swift
//  PlainWeights
//
//  Created by Claude on 27/09/2025.
//

import SwiftUI

struct WorkoutMetrics: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Summary")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("This Month")
                        .font(.caption2.italic())
                        .foregroundStyle(.secondary)
                }
            }

            // Main metrics row
            HStack(spacing: 16) {
                // Left metric
                VStack(alignment: .leading, spacing: 4) {
                    Text("28")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Middle metric
                VStack(alignment: .center, spacing: 4) {
                    Text("15")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("workout days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Right metric
                VStack(alignment: .trailing, spacing: 4) {
                    Text("342")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("total sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Bottom metric
            HStack {
                Text("12,450 kg")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("total volume lifted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    WorkoutMetrics()
        .padding()
}