//
//  SetRowView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Reusable component for displaying exercise set rows with fixed-width segments
//  for consistent vertical alignment across all sets.

import SwiftUI

// MARK: - Progress Comparison Data

struct ProgressComparison {
    let weightDelta: Double  // Difference from comparison weight
    let repsDelta: Int       // Difference from comparison reps
    let comparisonMode: String  // "vs Last" or "vs Best"
    let volumeProgress: Double  // Percentage progress (0.0 to 1.0)
    let lastSessionVolume: Double  // Last session's total volume (for per-row comparison)
}

// MARK: - Set Row View

struct SetRowView: View {
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void
    let progressComparison: ProgressComparison?  // Optional progress data for first set
    let cumulativeVolume: Double  // Running total of weight × reps up to and including this set
    let setNumber: Int  // 1-based set number for display

    init(set: ExerciseSet, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, progressComparison: ProgressComparison? = nil, cumulativeVolume: Double = 0, setNumber: Int = 0) {
        self.set = set
        self.onTap = onTap
        self.onDelete = onDelete
        self.progressComparison = progressComparison
        self.cumulativeVolume = cumulativeVolume
        self.setNumber = setNumber
    }

    var body: some View {
        // 6-column layout
        HStack(spacing: 0) {
            // Column 0 - Set Number
            Text("\(setNumber)")
                .font(.body)
                .fontWeight(.bold)
                .monospacedDigit()
                .frame(width: 30)
                .frame(maxHeight: .infinity)
                        
            // Column 1 - Weight (wider)
            VStack(spacing: 2) {
                Text("Weight")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Formatters.formatWeight(set.weight)) kg")
                    .font(.body)
                    .monospacedDigit()
                if let progress = progressComparison {
                    progressPill(delta: progress.weightDelta, unit: "kg")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
                        
            // Column 2 - Reps (wider)
            VStack(spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(set.reps) rep")
                    .font(.body)
                    .monospacedDigit()
                if let progress = progressComparison {
                    progressPill(delta: Double(progress.repsDelta), unit: "reps")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
                        
            // Column 3 - Cumulative Total (wider)
            VStack(spacing: 2) {
                Text("Total")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Formatters.formatVolume(cumulativeVolume)) kg")
                    .font(.body)
                    .monospacedDigit()
                if let progress = progressComparison {
                    let volumeDelta = cumulativeVolume - progress.lastSessionVolume
                    progressPill(delta: volumeDelta, unit: "kg")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
                        
            // Column 4 - Time
            Text(Formatters.formatTimeHM(set.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 45)
                .frame(maxHeight: .infinity)
                
            // Column 5 - Icons (narrow, stacked vertically)
            VStack(spacing: 2) {
                if set.isWarmUp {
                    Circle()
                        .fill(.orange)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.white)
                        }
                }
                if set.isDropSet {
                    Circle()
                        .fill(.teal)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8))
                                .foregroundStyle(.white)
                        }
                }
                if set.isPauseAtTop {
                    Circle()
                        .fill(.pink)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.white)
                        }
                }
                if set.isTimedSet {
                    Circle()
                        .fill(.black)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Text("\(set.tempoSeconds)s")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
                if set.isPB {
                    Circle()
                        .fill(.purple)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Text("PB")
                                .font(.system(size: 7))
                                .italic()
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 24, alignment: .center)
            .frame(maxHeight: .infinity)
                    }
        .frame(height: 44)
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowBackground(Color(.systemBackground))
        .listRowSeparator(.automatic)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Methods

    private func progressPill(delta: Double, unit: String) -> some View {
        let color: Color = delta > 0 ? .green : (delta < 0 ? .pw_red : .pw_blue)
        let text: String = {
            if delta > 0 {
                return "+\(Formatters.formatWeight(delta)) \(unit)"
            } else if delta < 0 {
                return "\(Formatters.formatWeight(delta)) \(unit)"
            } else {
                return "same"
            }
        }()

        return GeometryReader { geo in
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(.white)
                .frame(width: geo.size.width * 0.8, height: 18)
                .background(color)
                .clipShape(Capsule())
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 18)
    }

    private func deltaColor(for delta: Double) -> Color {
        if delta > 0 {
            return .green
        } else if delta < 0 {
            return .pw_red
        } else {
            return .pw_blue
        }
    }

    private func deltaText(for delta: Double) -> String {
        if delta > 0 {
            return "(+\(Int(delta)))"
        } else if delta < 0 {
            return "(\(Int(delta)))"
        } else {
            return "(same)"
        }
    }

    private func formatVolumeProgress(_ progress: Double, comparisonMode: String) -> String {
        let percentage = Int(progress * 100)
        let comparisonText = comparisonMode == "(vs Last)" ? "last" : "best"

        if progress > 0 {
            return "Total Volume +\(percentage)% of \(comparisonText)"
        } else if progress < 0 {
            return "Total Volume \(percentage)% of \(comparisonText)"
        } else {
            return "Total Volume same as \(comparisonText)"
        }
    }

    private func volumeProgressColor(for progress: Double) -> Color {
        if progress > 0 {
            return .pw_green
        } else if progress < 0 {
            return .pw_red
        } else {
            return .pw_blue
        }
    }
}
