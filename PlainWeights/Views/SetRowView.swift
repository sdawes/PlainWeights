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

    var body: some View {
        HStack(spacing: 0) {
            // Content columns
            HStack(spacing: 0) {
                // Col 1: Set number (left-aligned, with padding for warm-up/bonus border clearance)
                Text("\(setNumber)")
                    .font(themeManager.currentTheme.dataFont(size: 17, weight: .medium))
                    .foregroundStyle(set.isWarmUp ? .orange : (set.isBonus ? .purple : .secondary))
                    .frame(width: 28, alignment: .leading)
                    .padding(.leading, 8)

                // Col 2: PB indicator (between set number and weight)
                if set.isPB {
                    Text("PB")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.primaryText)
                        .frame(width: 24, alignment: .center)
                } else {
                    Spacer()
                        .frame(width: 24)
                }

                // Weight × Reps (baseline aligned, larger font to match Make)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(Formatters.formatWeight(set.weight))
                        .font(themeManager.currentTheme.dataFont(size: 20, weight: .medium))
                        .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(" kg")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text(" × ")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("\(set.reps)")
                        .font(themeManager.currentTheme.dataFont(size: 20, weight: .medium))
                        .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.leading, 4)

                Spacer()

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
        .listRowBackground(setTypeRowBackground)  // Keep for List contexts
        .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
        .listRowSeparatorTint(themeManager.currentTheme.borderColor)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Methods

    /// Get the background view for set type styling (left border + light background)
    @ViewBuilder
    private var setTypeRowBackground: some View {
        if set.isWarmUp {
            HStack(spacing: 0) {
                Color.clear.frame(width: 16)
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 2)
                Rectangle()
                    .fill(Color.orange.opacity(0.05))
            }
        } else if set.isBonus {
            HStack(spacing: 0) {
                Color.clear.frame(width: 16)
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: 2)
                Rectangle()
                    .fill(Color.purple.opacity(0.05))
            }
        } else {
            Color.clear
        }
    }

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
                    .font(themeManager.currentTheme.dataFont(size: 14))
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

    // Check if more than 3 minutes have passed since this set
    private var hasExceededRestTime: Bool {
        Date().timeIntervalSince(set.timestamp) >= 180
    }

    @ViewBuilder
    private var restTimeView: some View {
        // Priority 1: Show captured rest time (static display)
        if let restSeconds = set.restSeconds {
            staticRestTimeView(seconds: restSeconds)
        }
        // Priority 2: Show live timer for most recent set (under 3 mins, not yet captured)
        else if showTimer && !hasExceededRestTime {
            liveTimerView
        }
        // Priority 3: Most recent set exceeded 3 mins but not captured yet - capture and show
        else if showTimer && hasExceededRestTime {
            staticRestTimeView(seconds: 180)
                .onAppear {
                    captureRestTimeExpiry()
                }
        }
        // Priority 4: Default - show timestamp
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
                .font(themeManager.currentTheme.dataFont(size: 12))
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
                        }
    }

    @ViewBuilder
    private var liveTimerView: some View {
        TimelineView(.periodic(from: set.timestamp, by: 1.0)) { context in
            let elapsed = context.date.timeIntervalSince(set.timestamp)
            let color = restTimeColor(for: Int(elapsed))

            if elapsed >= 180 {
                // At 3 minutes, show static display and capture rest time
                HStack(spacing: 4) {
                    Image(systemName: "moon.zzz")
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)

                    Text("3:00")
                        .font(themeManager.currentTheme.dataFont(size: 12))
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                }
                .onAppear {
                    captureRestTimeExpiry()
                }
            } else {
                // Under 3 minutes, show live timer
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(color)

                    Text(Formatters.formatDuration(elapsed))
                        .font(themeManager.currentTheme.dataFont(size: 12, weight: .bold))
                        .foregroundStyle(color)
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
