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
    let cardPosition: ListRowCardPosition?  // For unified card appearance with today's sets
    let isFirstInCard: Bool  // True for first set after header (no top divider needed)
    let isLastSetInDay: Bool  // True for last set in a day (shows 3:00 if no restSeconds)

    init(set: ExerciseSet, setNumber: Int, isFirst: Bool = false, isLast: Bool = false, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, allSets: [ExerciseSet]? = nil, showTimer: Bool = false, cardPosition: ListRowCardPosition? = nil, isFirstInCard: Bool = true, isLastSetInDay: Bool = false) {
        self.set = set
        self.setNumber = setNumber
        self.isFirst = isFirst
        self.isLast = isLast
        self.onTap = onTap
        self.onDelete = onDelete
        self.allSets = allSets
        self.showTimer = showTimer
        self.cardPosition = cardPosition
        self.isFirstInCard = isFirstInCard
        self.isLastSetInDay = isLastSetInDay
    }

    var body: some View {
        VStack(spacing: 0) {
            // Divider at top (between rows, not first row after header)
            if cardPosition != nil && !isFirstInCard {
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(height: 1)
            }

            HStack(spacing: 0) {
                // Content columns
                HStack(spacing: 0) {
                    // Col 1: Set number (left-aligned, positioned after the set type border)
                    Text("\(setNumber)")
                        .font(themeManager.currentTheme.dataFont(size: 17, weight: .medium))
                        .foregroundStyle(setNumberColor)
                        .frame(width: 24, alignment: .leading)
                        .padding(.leading, 22)  // 16pt spacer + 2pt border + 4pt gap

                    // Col 2: PB indicator or spacer
                    if set.isPB {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(themeManager.currentTheme.pbColor)
                            .frame(width: 24, alignment: .leading)
                            .offset(x: -2)
                    } else {
                        Spacer()
                            .frame(width: 24)
                    }

                    // Weight × Reps
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(Formatters.formatWeight(set.weight))
                            .font(themeManager.currentTheme.dataFont(size: 20, weight: .medium))
                            .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

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
                            .minimumScaleFactor(0.5)
                    }

                    Spacer()

                    // Badges (immediately left of timer/timestamp) - only reserve space when badge exists
                    if !userBadges.isEmpty {
                        badgesView
                            .frame(minWidth: 55, alignment: .trailing)
                            .padding(.trailing, 4)
                    }

                    // Col 9: Timer or Timestamp
                    restTimeView
                        .frame(width: 55, alignment: .trailing)
                        .lineLimit(1)
                }
                .padding(.vertical, 12)
                .padding(.trailing, 16)  // Match right side spacing
                .background(setTypeTintBackground)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(cardPosition != nil ? themeManager.currentTheme.cardBackgroundColor : Color.clear)
        .clipShape(cardPosition != nil ? RoundedCorner(radius: 12, corners: cardCorners) : RoundedCorner(radius: 0, corners: []))
        .overlay(cardBorderOverlay)
        .listRowBackground(rowBackground)
        .listRowInsets(cardPosition != nil ? EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16) : EdgeInsets())
        .listRowSeparator(cardPosition != nil ? .hidden : (isFirst ? .hidden : .visible), edges: .top)
        .listRowSeparator(cardPosition != nil ? .hidden : (isLast ? .hidden : .visible), edges: .bottom)
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

    /// Row background - clear for card mode, setTypeRowBackground otherwise
    @ViewBuilder
    private var rowBackground: some View {
        if cardPosition != nil {
            Color.clear
        } else {
            setTypeRowBackground
        }
    }

    /// Corners to round based on card position
    private var cardCorners: UIRectCorner {
        guard let position = cardPosition else { return [] }
        switch position {
        case .top: return [.topLeft, .topRight]
        case .middle: return []
        case .bottom: return [.bottomLeft, .bottomRight]
        case .single: return .allCorners
        }
    }

    /// Border overlay based on card position - draws only the edges needed to connect with adjacent rows
    @ViewBuilder
    private var cardBorderOverlay: some View {
        if let position = cardPosition {
            switch position {
            case .top:
                TopOpenBorder(radius: 12)
                    .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
            case .middle:
                SidesOnlyBorder()
                    .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
            case .bottom:
                BottomOpenBorder(radius: 12)
                    .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
            case .single:
                RoundedCorner(radius: 12, corners: .allCorners)
                    .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
            }
        }
    }

    /// Color for set number based on set type (uses model's setTypeColor)
    private var setNumberColor: Color {
        self.set.setTypeColor ?? .secondary
    }

    /// Get the background view for set type with colored left border accent
    /// Mimics the staleness indicator pattern from ExerciseListView
    @ViewBuilder
    private var setTypeRowBackground: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: 16)  // Match list leading inset
            if let tintColor = set.setTypeColor {
                Rectangle()
                    .fill(tintColor)
                    .frame(width: 2)
            }
            Rectangle()
                .fill(set.setTypeColor?.opacity(0.05) ?? Color.clear)
        }
    }

    /// Tinted background for special set types (warm-up, bonus, etc.)
    /// Shows colored left border + light fill, starting left of set number
    @ViewBuilder
    private var setTypeTintBackground: some View {
        if let tintColor = set.setTypeColor {
            let bgOpacity = set.isAssisted ? 0.05 : 0.1  // Lighter background for assisted
            HStack(spacing: 0) {
                Rectangle()
                    .fill(tintColor)
                    .frame(width: 2)
                Rectangle()
                    .fill(tintColor.opacity(bgOpacity))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
            .padding(.leading, 12)  // Start a few pixels left of set number
        }
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
        if set.isAssisted { badges.append("assisted") }
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
                Text("Warm")
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
                Text("Drop")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(.blue)
        case "assisted":
            HStack(spacing: 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 14))
                Text("Assist")
                    .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(Color(red: 1.0, green: 0.2, blue: 0.5))
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
            .foregroundStyle(.gray)
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
        } else if isLastSetInDay {
            // Last set in a historic day with no captured rest time - show 3:00
            staticRestTimeView(seconds: 180)
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
        if seconds >= 120 { return .red }
        if seconds >= 60 { return .orange }
        return themeManager.currentTheme.primaryText
    }

    private func captureRestTimeExpiry() {
        guard set.restSeconds == nil else { return }
        try? ExerciseSetService.captureRestTimeExpiry(for: set, context: modelContext)
    }
}

