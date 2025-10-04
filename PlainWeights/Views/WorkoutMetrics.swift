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
                        .foregroundStyle(.white.opacity(0.8))
                        .textCase(.uppercase)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("This Month")
                        .font(.caption2.italic())
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            // Main metrics row
            HStack(spacing: 16) {
                // Left metric
                VStack(alignment: .leading, spacing: 4) {
                    Text("28")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("exercises")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                // Middle metric
                VStack(alignment: .center, spacing: 4) {
                    Text("15")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("workout days")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                // Right metric
                VStack(alignment: .trailing, spacing: 4) {
                    Text("342")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("total sets")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            // Bottom metric
            HStack {
                Text("12,450 kg")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("total volume lifted")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.2, blue: 0.28))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

#Preview {
    WorkoutMetrics()
        .padding()
}