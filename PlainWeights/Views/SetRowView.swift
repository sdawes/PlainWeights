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
    let volumeProgress: Double  // Percentage progress (e.g., 0.5 = 50%, -0.2 = -20%)
    let cumulativeVolume: Double  // Current cumulative volume in kg
    let comparisonVolume: Double  // Last/best session volume in kg for comparison
}

// MARK: - Set Row View

struct SetRowView: View {
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void
    let progressComparison: ProgressComparison?  // Optional progress data for first set
    let showTimer: Bool  // Only show timer on most recent set

    init(set: ExerciseSet, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, progressComparison: ProgressComparison? = nil, showTimer: Bool = false) {
        self.set = set
        self.onTap = onTap
        self.onDelete = onDelete
        self.progressComparison = progressComparison
        self.showTimer = showTimer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let progress = progressComparison {
                // Line 1: Weight and reps with deltas (full display)
                HStack(alignment: .center, spacing: 4) {
                    // Weight and reps group (shrinks to fit, never wraps)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        // Weight with delta
                        Text("\(Formatters.formatWeight(set.weight)) kg")
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        weightProgressView(for: progress.weightDelta)

                        Text("×")
                            .foregroundStyle(.secondary)

                        // Reps with delta
                        Text("\(set.reps) reps")
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        repsProgressView(for: progress.repsDelta)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

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

                        if set.isBonus {
                            Circle()
                                .fill(.yellow)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "star.fill")
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

                        // Only show colored progress when both volumes are > 0
                        if progress.comparisonVolume > 0 && progress.cumulativeVolume > 0 {
                            if progress.volumeProgress > 0 {
                                // Over 100%: Green for bonus (right of 100% line), grey for baseline (left)
                                let markerRatio = 1 / (1 + progress.volumeProgress)
                                let markerPosition = geometry.size.width * markerRatio

                                // Grey baseline portion (left of 100% marker)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: markerPosition, height: 4)
                                    .cornerRadius(2)

                                // Green bonus portion (right of 100% marker)
                                Rectangle()
                                    .fill(Color.pw_green)
                                    .frame(width: geometry.size.width - markerPosition, height: 4)
                                    .cornerRadius(2)
                                    .offset(x: markerPosition)

                                // 100% marker line
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 1, height: 12)
                                    .position(x: markerPosition, y: 4)
                            } else if progress.volumeProgress == 0 {
                                // Exactly 100%: Full green bar, no marker
                                Rectangle()
                                    .fill(Color.pw_green)
                                    .frame(height: 4)
                                    .cornerRadius(2)
                            } else {
                                // Under 100%: Red partial fill
                                let fillRatio = max(1.0 + progress.volumeProgress, 0)
                                Rectangle()
                                    .fill(Color.pw_red)
                                    .frame(width: geometry.size.width * fillRatio, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        // else: just show grey background track (already rendered above)
                    }
                }
                .frame(height: 8)
                .padding(.bottom, 1)

                // Line 3: Volume progress text with timer on right
                HStack(alignment: .top, spacing: 8) {
                    // Volume progress showing cumulative kg and percentage
                    HStack(spacing: 2) {
                        Text("Total Weight: ")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("\(Formatters.formatVolume(progress.cumulativeVolume)) kg")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        // Only show percentage when both volumes are > 0
                        if progress.comparisonVolume > 0 && progress.cumulativeVolume > 0 {
                            let percentage = Int((progress.cumulativeVolume / progress.comparisonVolume) * 100)
                            Text(" (\(percentage)%)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(volumeProgressColor(for: progress.volumeProgress))
                        }
                    }

                    Spacer()

                    // Rest timer (right-aligned, only on most recent set, disappears after 5 minutes)
                    if showTimer {
                        TimelineView(.periodic(from: set.timestamp, by: 1.0)) { context in
                            let rawElapsed = context.date.timeIntervalSince(set.timestamp)

                            // Only show timer for first 5 minutes (300 seconds)
                            if rawElapsed < 300 {
                                let elapsed = min(rawElapsed, 180)

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
                                        .font(.caption2)
                                        .foregroundStyle(timerColor)

                                    Text(Formatters.formatDuration(elapsed))
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .italic()
                                    .foregroundStyle(timerColor)
                                    .monospacedDigit()
                            }
                        }
                        }
                    }
                }
            } else {
                // Normal display (no progress data)
                HStack(alignment: .center, spacing: 0) {
                    Text(ExerciseSetFormatters.formatSet(set))
                        .monospacedDigit()
                        .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
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

                        if set.isBonus {
                            Circle()
                                .fill(.yellow)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "star.fill")
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

    @ViewBuilder
    private func weightProgressView(for delta: Double) -> some View {
        if delta > 0 {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 10))
                    .alignmentGuide(.lastTextBaseline) { d in d[.bottom] }
                Text("\(Int(delta))")
                    .monospacedDigit()
                    .fontWeight(.bold)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.green)
        } else if delta < 0 {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .alignmentGuide(.lastTextBaseline) { d in d[.bottom] }
                Text("\(Int(abs(delta)))")
                    .monospacedDigit()
                    .fontWeight(.bold)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.pw_red)
        } else {
            Text("SAME")
                .font(.system(size: 11))
                .fontWeight(.bold)
                .foregroundStyle(Color.pw_blue)
        }
    }

    @ViewBuilder
    private func repsProgressView(for delta: Int) -> some View {
        if delta > 0 {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 10))
                    .alignmentGuide(.lastTextBaseline) { d in d[.bottom] }
                Text("\(delta)")
                    .monospacedDigit()
                    .fontWeight(.bold)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.green)
        } else if delta < 0 {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .alignmentGuide(.lastTextBaseline) { d in d[.bottom] }
                Text("\(abs(delta))")
                    .monospacedDigit()
                    .fontWeight(.bold)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.pw_red)
        } else {
            Text("SAME")
                .font(.system(size: 11))
                .fontWeight(.bold)
                .foregroundStyle(Color.pw_blue)
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
