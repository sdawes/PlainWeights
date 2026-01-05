//
//  SetRowView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Reusable component for displaying exercise set rows with fixed-width segments
//  for consistent vertical alignment across all sets.

import SwiftUI

// MARK: - Set Row View

struct SetRowView: View {
    @Environment(\.modelContext) private var modelContext
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void
    let allSets: [ExerciseSet]?  // Pass sets array to calculate comparisons (nil = no comparison row)
    let showTimer: Bool  // Only show timer on most recent set

    init(set: ExerciseSet, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, allSets: [ExerciseSet]? = nil, showTimer: Bool = false) {
        self.set = set
        self.onTap = onTap
        self.onDelete = onDelete
        self.allSets = allSets
        self.showTimer = showTimer
    }

    // MARK: - Computed Comparisons (using existing services)

    private var hasComparisonData: Bool {
        guard let sets = allSets else { return false }
        return LastSessionCalculator.hasLastSession(from: sets) ||
               BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday(sets)) != nil
    }

    private func setsExcludingToday(_ sets: [ExerciseSet]) -> [ExerciseSet] {
        sets.filter {
            Calendar.current.startOfDay(for: $0.timestamp) < Calendar.current.startOfDay(for: Date())
        }
    }

    private var prevWeightDelta: Double {
        guard let sets = allSets else { return 0 }
        return set.weight - LastSessionCalculator.getLastSessionMaxWeight(from: sets)
    }

    private var prevRepsDelta: Int {
        guard let sets = allSets else { return 0 }
        return set.reps - LastSessionCalculator.getLastSessionMaxReps(from: sets)
    }

    private var bestWeightDelta: Double {
        guard let sets = allSets else { return 0 }
        let bestWeight = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday(sets))?.maxWeight ?? 0
        return set.weight - bestWeight
    }

    private var bestRepsDelta: Int {
        guard let sets = allSets else { return 0 }
        let bestReps = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday(sets))?.repsAtMaxWeight ?? 0
        return set.reps - bestReps
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row 1: Weight × Reps + Badges | Timer
            HStack {
                // Weight × Reps
                Text("\(Formatters.formatWeight(set.weight)) kg × \(set.reps) \(set.reps == 1 ? "rep" : "reps")")
                    .monospacedDigit()
                    .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                // Badges
                badgesView

                Spacer()

                // Timer (only for today's sets with comparison data or when showTimer is true)
                restTimeView
            }

            // Row 2: Prev and Best comparisons (only when we have historical data)
            if hasComparisonData {
                HStack(spacing: 4) {
                    // Prev comparison
                    Text("Prev:")
                        .foregroundStyle(.secondary)
                    deltaText(for: prevWeightDelta, suffix: "kg")
                    deltaText(for: prevRepsDelta, suffix: "reps")

                    Text("|")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    // Best comparison
                    Text("Best:")
                        .foregroundStyle(.secondary)
                    deltaText(for: bestWeightDelta, suffix: "kg")
                    deltaText(for: bestRepsDelta, suffix: "reps")
                }
                .font(.caption)
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

    // MARK: - Delta Text Helper

    @ViewBuilder
    private func deltaText(for delta: Double, suffix: String) -> some View {
        let intDelta = Int(delta)
        if intDelta > 0 {
            Text("+\(intDelta) \(suffix)")
                .foregroundStyle(.green)
        } else if intDelta < 0 {
            Text("\(intDelta) \(suffix)")
                .foregroundStyle(.red)
        } else {
            Text("0 \(suffix)")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func deltaText(for delta: Int, suffix: String) -> some View {
        if delta > 0 {
            Text("+\(delta) \(suffix)")
                .foregroundStyle(.green)
        } else if delta < 0 {
            Text("\(delta) \(suffix)")
                .foregroundStyle(.red)
        } else {
            Text("0 \(suffix)")
                .foregroundStyle(.secondary)
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
