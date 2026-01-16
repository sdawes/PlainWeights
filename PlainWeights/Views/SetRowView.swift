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
    @Environment(ThemeManager.self) private var themeManager
    let set: ExerciseSet
    let setNumber: Int
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let allSets: [ExerciseSet]?  // Pass sets array to calculate comparisons (nil = no comparison row)
    let showTimer: Bool  // Only show timer on most recent set

    init(set: ExerciseSet, setNumber: Int, isFirst: Bool = false, isLast: Bool = false, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, allSets: [ExerciseSet]? = nil, showTimer: Bool = false) {
        self.set = set
        self.setNumber = setNumber
        self.isFirst = isFirst
        self.isLast = isLast
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
        HStack(spacing: 0) {
            // Col 1: Vertical line with top/bottom caps
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 1)
                .padding(.top, isFirst ? 12 : 0)
                .padding(.bottom, isLast ? 12 : 0)

            // Content columns
            HStack(spacing: 0) {
                // Col 2: Set number
                Text(String(format: "%02d", setNumber))
                    .font(.jetBrainsMono(.subheadline))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .leading)
                    .padding(.leading, 12)

                // Col 3: Badges (fixed width for up to 2 badges)
                badgesView
                    .frame(width: 50, alignment: .leading)

                // Col 4: Weight value
                Text(Formatters.formatWeight(set.weight))
                    .font(.jetBrainsMono(.headline, weight: .regular))
                    .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                    .frame(width: 45, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                // Col 5: "kg ×" separator
                Text(" kg × ")
                    .font(.jetBrainsMono(.headline, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Col 6: Reps
                Text("\(set.reps)")
                    .font(.jetBrainsMono(.headline, weight: .regular))
                    .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                    .frame(width: 25, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                // Col 7: Weight progression
                if hasComparisonData {
                    deltaText(for: prevWeightDelta, suffix: "kg")
                        .font(.jetBrainsMono(.caption))
                        .frame(width: 50, alignment: .trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                // Col 8: Reps progression
                if hasComparisonData {
                    deltaText(for: prevRepsDelta, suffix: "")
                        .font(.jetBrainsMono(.caption))
                        .frame(width: 35, alignment: .trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                // Col 9: Timestamp
                Text(Formatters.formatTimeHM(set.timestamp))
                    .font(.jetBrainsMono(.headline))
                    .foregroundStyle(.primary)
                    .frame(width: 55, alignment: .trailing)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
                .foregroundStyle(.blue)
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
                .foregroundStyle(.blue)
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
                            .font(.jetBrainsMono(size: 9))
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
                        .font(.jetBrainsMono(size: 10))
                        .foregroundStyle(.white)
                }
        case "bonus":
            Circle()
                .fill(.yellow)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "star.fill")
                        .font(.jetBrainsMono(size: 10))
                        .foregroundStyle(.white)
                }
        case "dropset":
            Circle()
                .fill(.teal)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "chevron.down")
                        .font(.jetBrainsMono(size: 10))
                        .foregroundStyle(.white)
                }
        case "pause":
            Circle()
                .fill(.pink)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "pause.fill")
                        .font(.jetBrainsMono(size: 10))
                        .foregroundStyle(.white)
                }
        case "timed":
            Circle()
                .fill(.black)
                .frame(width: 20, height: 20)
                .overlay {
                    if set.tempoSeconds > 0 {
                        Text("\(set.tempoSeconds)")
                            .font(.jetBrainsMono(size: 11))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "timer")
                            .font(.jetBrainsMono(size: 10))
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
                .font(.jetBrainsMono(.caption2))
                .foregroundStyle(.secondary)

            Text(Formatters.formatDuration(Double(seconds)))
                .font(.jetBrainsMono(.caption2))
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
                        .font(.jetBrainsMono(.caption2))
                        .foregroundStyle(color)

                    if elapsed >= 180 {
                        Text("> 3 mins")
                            .font(.jetBrainsMono(.caption2))
                            .foregroundStyle(color)
                            .onAppear {
                                // Capture the expiry when timer hits 180s
                                captureRestTimeExpiry()
                            }
                    } else {
                        Text(Formatters.formatDuration(elapsed))
                            .font(.jetBrainsMono(.caption2))
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
