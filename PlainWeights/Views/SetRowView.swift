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
                // Col 1: Set number (left-aligned, with padding for set type border clearance)
                Text("\(setNumber)")
                    .font(themeManager.currentTheme.dataFont(size: 17, weight: .medium))
                    .foregroundStyle(setNumberColor)
                    .frame(width: 24, alignment: .leading)
                    .padding(.leading, 8)

                // Col 2: PB indicator (trophy without circle)
                if set.isPB {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(themeManager.currentTheme.pbColor)
                        .frame(width: 24, alignment: .center)
                } else {
                    Spacer()
                        .frame(width: 24)
                }

                // Weight × Reps with PB underline
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(Formatters.formatWeight(set.weight))
                            .font(themeManager.currentTheme.dataFont(size: 20, weight: .medium))
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(" kg")
                            .font(themeManager.currentTheme.interFont(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text(" × ")
                            .font(themeManager.currentTheme.interFont(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text("\(set.reps)")
                            .font(themeManager.currentTheme.dataFont(size: 20, weight: .medium))
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    // PB underline under weight×reps
                    if set.isPB {
                        Rectangle()
                            .fill(themeManager.currentTheme.pbColor)
                            .frame(height: 2)
                    }
                }

                Spacer()

                // Badges (immediately left of timer/timestamp)
                badgesView
                    .frame(minWidth: 55, alignment: .trailing)
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
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(setTypeRowBackground)
        .listRowSeparator(isFirst ? .hidden : .visible, edges: .top)
        .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
        .listRowSeparatorTint(themeManager.currentTheme.borderColor)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Methods

    /// Color for set number based on set type
    private var setNumberColor: Color {
        if set.isWarmUp { return .orange }
        if set.isBonus { return .green }
        if set.isDropSet { return .blue }
        if set.isTimedSet { return .blue }
        if set.isPauseAtTop { return .indigo }
        return .secondary
    }

    /// Get the background view for set type with colored left border accent
    @ViewBuilder
    private var setTypeRowBackground: some View {
        if let tintColor = setTypeTintColor {
            // Special set types get colored left border + subtle tint
            HStack(spacing: 0) {
                Rectangle()
                    .fill(tintColor)
                    .frame(width: 3)
                Rectangle()
                    .fill(tintColor.opacity(0.06))
            }
        } else {
            // Normal sets use default list row background
            Color.clear
        }
    }

    /// Get set type tint color (nil for normal sets)
    private var setTypeTintColor: Color? {
        if set.isWarmUp { return .orange }
        if set.isBonus { return .green }
        if set.isDropSet { return .blue }
        if set.isTimedSet { return .blue }
        if set.isPauseAtTop { return .indigo }
        return nil
    }

    // MARK: - Badges

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
        switch badge {
        case "warmup":
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                Text("Warm Up")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(.orange)
        case "bonus":
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                Text("Bonus")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(.green)
        case "dropset":
            HStack(spacing: 4) {
                Image(systemName: "chevron.down.2")
                    .font(.system(size: 14, weight: .bold))
                Text("Drop Set")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(.blue)
        case "pause":
            HStack(spacing: 4) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 14))
                Text("Pause")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(.indigo)
        case "timed":
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                if set.tempoSeconds > 0 {
                    Text("\(set.tempoSeconds)s")
                        .font(themeManager.currentTheme.dataFont(size: 12, weight: .medium))
                } else {
                    Text("Timed")
                        .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
                }
            }
            .foregroundStyle(.blue)
        default:
            EmptyView()
        }
    }

    // MARK: - Rest Time Display

    private var hasExceededRestTime: Bool {
        Date().timeIntervalSince(set.timestamp) >= 180
    }

    @ViewBuilder
    private var restTimeView: some View {
        if let restSeconds = set.restSeconds {
            staticRestTimeView(seconds: restSeconds)
        } else if showTimer && !hasExceededRestTime {
            liveTimerView
        } else if showTimer && hasExceededRestTime {
            staticRestTimeView(seconds: 180)
                .onAppear {
                    captureRestTimeExpiry()
                }
        } else {
            Text(Formatters.formatTimeHM(set.timestamp))
                .font(themeManager.currentTheme.dataFont(size: 12))
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
        }
    }

    @ViewBuilder
    private func staticRestTimeView(seconds: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
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
                HStack(spacing: 4) {
                    Image(systemName: "timer")
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
        guard set.restSeconds == nil else { return }
        try? ExerciseSetService.captureRestTimeExpiry(for: set, context: modelContext)
    }
}

