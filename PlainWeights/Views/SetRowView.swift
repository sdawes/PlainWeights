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
    @Environment(\.modelContext) private var modelContext
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
                // Grid layout: 3 rows × 8 columns
                Grid(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 6) {
                    // Row 1: Weight | kg | × | Reps | rep(s) | Badge | Badge | PB
                    GridRow(alignment: .center) {
                        Text(Formatters.formatWeight(set.weight))
                            .monospacedDigit()
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                        Text("kg")
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                        Text("×")
                            .foregroundStyle(.secondary)

                        Text("\(set.reps)")
                            .monospacedDigit()
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                        Text(set.reps == 1 ? "rep" : "reps")
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                        // Badges in cols 6-8 (right-aligned within 3-column span)
                        badgesView
                            .gridCellColumns(3)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // Row 2: Weight delta (col 1) | empty | empty | Reps delta (col 4) | empty cols
                    GridRow(alignment: .center) {
                        weightProgressView(for: progress.weightDelta)

                        Color.clear
                        Color.clear

                        repsProgressView(for: progress.repsDelta)

                        Color.clear
                            .gridCellColumns(4)
                    }

                    // Row 3: Total weight (cols 1-6) | Timer (cols 7-8)
                    GridRow(alignment: .center) {
                        HStack(spacing: 4) {
                            Text("Total weight:")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Text("\(Formatters.formatVolume(progress.cumulativeVolume)) / \(Formatters.formatVolume(progress.comparisonVolume)) kg")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        .gridCellColumns(6)

                        restTimeView
                            .gridCellColumns(2)
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

                    // Badges (using shared badgesView)
                    badgesView
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Show rest time if available, otherwise nothing
                    if let restSeconds = set.restSeconds {
                        HStack(spacing: 4) {
                            Image(systemName: "moon.zzz")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(Formatters.formatDuration(Double(restSeconds)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .padding(.leading, 4)
                    }
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

    // Badges view: PB always in rightmost position, user badges fill from right
    @ViewBuilder
    private var badgesView: some View {
        HStack(spacing: 5) {
            // User badges (max 2, displayed left of PB)
            // Order: warm-up → bonus → drop → pause → timed
            ForEach(userBadges.prefix(2), id: \.self) { badge in
                badgeCircle(for: badge)
            }

            // PB badge always rightmost when present
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
    }

    private var userBadges: [String] {
        var badges: [String] = []
        if set.isWarmUp { badges.append("warmup") }
        if set.isBonus { badges.append("bonus") }
        if set.isDropSet { badges.append("dropset") }
        if set.isPauseAtTop { badges.append("pause") }
        if set.isTimedSet { badges.append("timed") }
        return badges
    }

    @ViewBuilder
    private func badgeCircle(for badge: String) -> some View {
        switch badge {
        case "warmup":
            Circle()
                .fill(.orange)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                }
        case "bonus":
            Circle()
                .fill(.yellow)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                }
        case "dropset":
            Circle()
                .fill(.teal)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                }
        case "pause":
            Circle()
                .fill(.pink)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                }
        case "timed":
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
        default:
            EmptyView()
        }
    }

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

    // MARK: - Rest Time Display

    @ViewBuilder
    private var restTimeView: some View {
        // Priority 1: Show captured rest time (static display)
        if let restSeconds = set.restSeconds {
            staticRestTimeView(seconds: restSeconds)
        }
        // Priority 2: Show live timer only for most recent set (no captured rest time yet)
        else if showTimer {
            liveTimerView
        }
        // Priority 3: First set of session - show nothing
    }

    @ViewBuilder
    private func staticRestTimeView(seconds: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.zzz")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(Formatters.formatDuration(Double(seconds)))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private var liveTimerView: some View {
        TimelineView(.periodic(from: set.timestamp, by: 1.0)) { context in
            let rawElapsed = context.date.timeIntervalSince(set.timestamp)

            // Only show timer for first 5 minutes (300 seconds)
            if rawElapsed < 300 {
                let elapsed = min(rawElapsed, 180)
                let color = restTimeColor(for: Int(elapsed))

                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption2)
                        .foregroundStyle(color)

                    if elapsed >= 180 {
                        Text("> 3 mins")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                            .onAppear {
                                // Capture the expiry when timer hits 180s
                                captureRestTimeExpiry()
                            }
                    } else {
                        Text(Formatters.formatDuration(elapsed))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private func restTimeColor(for seconds: Int) -> Color {
        if seconds < 60 {
            return .black
        } else if seconds < 120 {
            return .orange
        } else {
            return .pw_red
        }
    }

    private func captureRestTimeExpiry() {
        // Only capture if not already captured
        guard set.restSeconds == nil else { return }
        try? ExerciseSetService.captureRestTimeExpiry(for: set, context: modelContext)
    }
}
