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
}

// MARK: - Set Row View

struct SetRowView: View {
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void
    let progressComparison: ProgressComparison?  // Optional progress data for first set

    init(set: ExerciseSet, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, progressComparison: ProgressComparison? = nil) {
        self.set = set
        self.onTap = onTap
        self.onDelete = onDelete
        self.progressComparison = progressComparison
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let progress = progressComparison {
                // Line 1: Weight and reps with deltas (full display)
                HStack(alignment: .center, spacing: 4) {
                    // Weight with delta
                    Text("\(Formatters.formatWeight(set.weight)) kg")
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text(deltaText(for: progress.weightDelta))
                        .font(.system(size: 13))
                        .italic()
                        .monospacedDigit()
                        .foregroundStyle(deltaColor(for: progress.weightDelta))

                    Text("×")
                        .foregroundStyle(.secondary)

                    // Reps with delta
                    Text("\(set.reps) reps")
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text(deltaText(for: Double(progress.repsDelta)))
                        .font(.system(size: 13))
                        .italic()
                        .monospacedDigit()
                        .foregroundStyle(deltaColor(for: Double(progress.repsDelta)))

                    Spacer()

                    // Icons and timestamp
                    HStack(spacing: 5) {
                        if set.isWarmUp {
                            Circle()
                                .fill(.orange)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isDropSet {
                            Circle()
                                .fill(.teal)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isPauseAtTop {
                            Circle()
                                .fill(.pink)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isTimedSet {
                            Circle()
                                .fill(.black)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    if set.tempoSeconds > 0 {
                                        Text("\(set.tempoSeconds)")
                                            .font(.system(size: 11))
                                            .italic()
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    } else {
                                        Image(systemName: "timer")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.white)
                                    }
                                }
                        }

                        if set.isPB {
                            Circle()
                                .fill(.purple)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Text("PB")
                                        .font(.system(size: 9))
                                        .italic()
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                        }
                    }

                    Text(Formatters.formatTimeHM(set.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
                .padding(.bottom, 8)

                // Line 2: Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)

                        // Progress fill
                        Rectangle()
                            .fill(progress.volumeProgress >= 0 ? Color.green : Color.pw_red)
                            .frame(width: geometry.size.width * min(abs(progress.volumeProgress), 1.0), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
                .padding(.bottom, 4)

                // Line 3: Volume progress text with timer on right
                HStack(alignment: .top, spacing: 8) {
                    Text(formatVolumeProgress(progress.volumeProgress, comparisonMode: progress.comparisonMode))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Rest timer pill (right-aligned, disappears after 5 minutes)
                    TimelineView(.periodic(from: set.timestamp, by: 1.0)) { context in
                        let rawElapsed = context.date.timeIntervalSince(set.timestamp)

                        // Only show timer for first 5 minutes (300 seconds)
                        if rawElapsed < 300 {
                            let elapsed = min(rawElapsed, 120)

                            let timerColor: Color = {
                                if elapsed < 60 {
                                    return .black
                                } else if elapsed < 120 {
                                    return .orange
                                } else {
                                    return .pw_red
                                }
                            }()

                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.caption)
                                    .foregroundStyle(timerColor)

                                Text(Formatters.formatDuration(elapsed))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .italic()
                                    .foregroundStyle(timerColor)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .overlay(
                                Capsule()
                                    .stroke(timerColor, lineWidth: 1)
                            )
                        }
                    }
                }
            } else {
                // Normal display (no progress data)
                HStack(alignment: .center, spacing: 0) {
                    Text(ExerciseSetFormatters.formatSet(set))
                        .monospacedDigit()
                        .foregroundStyle(set.isWarmUp ? .secondary : .primary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)

                    // Icon Container (flexible width, fills available space)
                    HStack(spacing: 5) {
                        if set.isWarmUp {
                            Circle()
                                .fill(.orange)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isDropSet {
                            Circle()
                                .fill(.teal)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isPauseAtTop {
                            Circle()
                                .fill(.pink)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white)
                                }
                        }

                        if set.isTimedSet {
                            Circle()
                                .fill(.black)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    if set.tempoSeconds > 0 {
                                        Text("\(set.tempoSeconds)")
                                            .font(.system(size: 11))
                                            .italic()
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    } else {
                                        Image(systemName: "timer")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.white)
                                    }
                                }
                        }

                        if set.isPB {
                            Circle()
                                .fill(.purple)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Text("PB")
                                        .font(.system(size: 9))
                                        .italic()
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(Formatters.formatTimeHM(set.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.leading, 4)
                }
            }
        }
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowBackground(
            progressComparison != nil ?
                Color.gray.opacity(0.1) : Color(.systemBackground)
        )
        .listRowSeparator(progressComparison != nil ? .hidden : .automatic)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Methods

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
}
