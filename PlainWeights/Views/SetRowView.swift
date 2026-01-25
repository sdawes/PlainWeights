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
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .leading)
                    .padding(.leading, 8)

                // Col 2.5: PB indicator (between set number and weight)
                if set.isPB {
                    Text("PB")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.primaryText)
                        .frame(width: 20, alignment: .center)
                } else {
                    Spacer()
                        .frame(width: 20)
                }

                // Col 3: Weight × Reps (baseline aligned)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(Formatters.formatWeight(set.weight))
                        .font(.headline.weight(.regular))
                        .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                        .frame(width: 45, alignment: .trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(" kg × ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("\(set.reps)")
                        .font(.headline.weight(.regular))
                        .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                        .frame(width: 25, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.leading, 8)

                Spacer()

                // Col 7: Weight progression (always reserve space)
                Group {
                    if hasComparisonData {
                        deltaText(for: prevWeightDelta, suffix: "kg")
                            .font(.system(size: 14))
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 45, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                // Col 8: Reps progression (always reserve space)
                Group {
                    if hasComparisonData {
                        deltaText(for: prevRepsDelta, suffix: "")
                            .font(.system(size: 14))
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 30, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                // Badges (immediately left of timer/timestamp)
                badgesView
                    .frame(width: 55, alignment: .trailing)
                    .padding(.trailing, 4)

                // Col 9: Timer or Timestamp
                restTimeView
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
        .listRowBackground(set.isWarmUp ? themeManager.currentTheme.primary.opacity(0.05) : Color.clear)
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
            Text("+\(intDelta)\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressUp)
        } else if intDelta < 0 {
            Text("\(intDelta)\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressDown)
        } else {
            Text("0\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressSame)
        }
    }

    @ViewBuilder
    private func deltaText(for delta: Int, suffix: String) -> some View {
        if delta > 0 {
            Text("+\(delta)\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressUp)
        } else if delta < 0 {
            Text("\(delta)\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressDown)
        } else {
            Text("0\(suffix)")
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.progressSame)
        }
    }

    // MARK: - Helper Methods

    // Badges view: user badges only (PB is shown separately after set number)
    @ViewBuilder
    private var badgesView: some View {
        // Only show first badge to keep row clean
        // Priority order: warm-up → bonus → drop → pause → timed
        if let firstBadge = userBadges.first {
            badgeCircle(for: firstBadge)
        } else {
            Color.clear
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
        let color = themeManager.currentTheme.primaryText
        switch badge {
        case "warmup":
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundStyle(color)
        case "bonus":
            Image(systemName: "trophy.fill")
                .font(.system(size: 14))
                .foregroundStyle(color)
        case "dropset":
            Image(systemName: "chevron.down.2")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
        case "pause":
            Image(systemName: "pause.fill")
                .font(.system(size: 14))
                .foregroundStyle(color)
        case "timed":
            if set.tempoSeconds > 0 {
                Text("\(set.tempoSeconds)")
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            } else {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
        default:
            EmptyView()
        }
    }


    // MARK: - Rest Time Display

    @ViewBuilder
    private var restTimeView: some View {
        // Priority 1: Show live timer for most recent set (no captured rest time yet)
        if showTimer && set.restSeconds == nil {
            liveTimerView
        }
        // Priority 2: Show captured rest time (static display)
        else if let restSeconds = set.restSeconds {
            staticRestTimeView(seconds: restSeconds)
        }
        // Priority 3: Default - show timestamp
        else {
            Text(Formatters.formatTimeHM(set.timestamp))
                .font(.caption)
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
        }
    }

    @ViewBuilder
    private func staticRestTimeView(seconds: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.zzz")
                .font(.caption)
                .foregroundStyle(themeManager.currentTheme.tertiaryText)

            Text(Formatters.formatDuration(Double(seconds)))
                .font(.caption)
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
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
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(color)

                    if elapsed >= 180 {
                        Text("> 3m")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                            .onAppear {
                                // Capture the expiry when timer hits 180s
                                captureRestTimeExpiry()
                            }
                    } else {
                        Text(Formatters.formatDuration(elapsed))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private func restTimeColor(for seconds: Int) -> Color {
        themeManager.currentTheme.primaryText
    }

    private func captureRestTimeExpiry() {
        // Only capture if not already captured
        guard set.restSeconds == nil else { return }
        try? ExerciseSetService.captureRestTimeExpiry(for: set, context: modelContext)
    }
}
