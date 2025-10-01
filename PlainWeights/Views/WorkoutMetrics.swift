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
        .background(
            ZStack {
                // Metallic red gradient (iOS style)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.4, blue: 0.4),  // Lighter red
                        Color(red: 0.7, green: 0.2, blue: 0.2)   // Deeper red
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Subtle overlay for depth
                Color.white.opacity(0.1)
                    .blendMode(.overlay)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

#Preview {
    WorkoutMetrics()
        .padding()
}