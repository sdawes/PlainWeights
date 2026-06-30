//
//  ExerciseCard.swift
//  PlainWeights
//
//  Single visual + behavioural source of truth for "what an exercise
//  card looks like". Used by both the main exercise list and inside
//  expanded group cards on the Groups screen — same name + tags +
//  last-done line, same staleness dot, same green-when-done-today text.
//
//  Renders content only; the caller is responsible for the surrounding
//  chrome (background, padding, corner radius, tap/swipe handlers) so
//  each context can pick the right wrapper for its layout.
//
//  Performance:
//  - For scroll-heavy contexts (the main list) the caller can supply a
//    pre-computed `cachedIsDoneToday` so we skip a per-frame scan of
//    the exercise's sets.
//  - For small-N contexts (a group with 4-8 exercises) the cache can
//    be omitted; live computation cost is negligible.
//

import SwiftUI

struct ExerciseCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise

    /// Optional cached "done today" check. Supply for scroll-heavy
    /// contexts. nil → computed live from the exercise.
    var cachedIsDoneToday: Bool? = nil

    /// Pre-computed staleness level + "last done" string from the caller's
    /// batched cache. When supplied, the card renders the last-done line
    /// from this and does zero Calendar / set-scan work during scroll.
    /// nil → computed live from the exercise (small-N callers).
    var status: ExerciseCardStatus? = nil

    /// If set, render the name as the supplied `AttributedString`
    /// (used by the main list's search bar to highlight matches).
    /// nil → render `exercise.name` plainly.
    var nameAttributed: AttributedString? = nil

    /// Substring to highlight inside tag pills — passed through to
    /// `TagPillsRow`. Empty disables highlighting.
    var tagHighlight: String = ""

    /// Slightly smaller fonts and tighter top padding for nested
    /// contexts (e.g. inside a group's expanded body).
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name (with optional search highlight)
            if let nameAttributed {
                Text(nameAttributed)
                    .font(nameFont)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
            } else {
                Text(exercise.name)
                    .font(nameFont)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
            }

            // Tag pills (only when tags exist)
            if !exercise.tags.isEmpty || !exercise.secondaryTags.isEmpty {
                TagPillsRow(
                    tags: exercise.tags,
                    secondaryTags: exercise.secondaryTags,
                    highlightText: tagHighlight
                )
                .padding(.top, 6)
            }

            // Last workout line with optional staleness dot — green (today),
            // orange (14+ days), red (30+ days). The 1-13 days "no callout"
            // range and the no-sets case both render no dot.
            statusLine
                .padding(.top, compact ? 8 : 12)
        }
    }

    // MARK: - Status line

    /// Renders from the caller's precomputed status when available (the
    /// scroll-perf path), otherwise falls back to live computation.
    @ViewBuilder
    private var statusLine: some View {
        if let status {
            cachedStatusLine(status)
        } else {
            liveStatusLine
        }
    }

    /// Last-done line built from precomputed status. Colours are resolved
    /// here (live, from the current theme) so theme switches stay instant;
    /// only the expensive Calendar / set-scan work was moved upstream.
    private func cachedStatusLine(_ status: ExerciseCardStatus) -> some View {
        let isDark = themeManager.currentTheme == .dark
        let green: Color = isDark ? Color(red: 0.40, green: 0.90, blue: 0.50) : .green
        let orange: Color = isDark ? Color(red: 1.0, green: 0.70, blue: 0.30) : .orange
        let red: Color = isDark ? Color(red: 1.0, green: 0.40, blue: 0.40) : .red

        let dotColor: Color?
        let text: String
        let textColor: Color
        let usesSmallFont: Bool
        switch status.level {
        case .today:
            dotColor = green
            text = "Last logged today"
            textColor = green
            usesSmallFont = false
        case .recent:
            dotColor = nil
            text = "Last logged \(status.lastDoneString)"
            textColor = themeManager.effectiveTheme.mutedForeground
            usesSmallFont = true
        case .twoWeeks:
            dotColor = orange
            text = "Last logged \(status.lastDoneString)"
            textColor = orange
            usesSmallFont = false
        case .month:
            dotColor = red
            text = "Last logged \(status.lastDoneString)"
            textColor = red
            usesSmallFont = false
        case .noSets:
            dotColor = nil
            text = "No sets recorded"
            textColor = red
            usesSmallFont = false
        }

        return HStack(spacing: 6) {
            if let dotColor {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
            }
            Text(text)
                .font(usesSmallFont ? lastDoneFontSmall : lastDoneFontRegular)
                .foregroundStyle(textColor)
        }
    }

    /// Live fallback — original per-render computation, used when no cached
    /// status is supplied (small-N callers).
    @ViewBuilder
    private var liveStatusLine: some View {
        let isDoneToday = cachedIsDoneToday ?? exercise.wasWorkedOutToday
        let info = liveStalenessInfo()
        HStack(spacing: 6) {
            if let info {
                Circle()
                    .fill(info.color)
                    .frame(width: 6, height: 6)
            }
            lastDoneText(isDoneToday: isDoneToday, info: info)
        }
    }

    // MARK: - Last-done line

    @ViewBuilder
    private func lastDoneText(
        isDoneToday: Bool,
        info: (color: Color, label: String)?
    ) -> some View {
        if isDoneToday {
            Text("Last logged today")
                .font(lastDoneFontRegular)
                .foregroundStyle(info?.color ?? .green)
        } else if let lastWorkout = exercise.lastWorkoutDate {
            // The grey "no callout" 1-13 days range renders one step
            // smaller, so the orange / red staleness states stand out.
            Text("Last logged \(Formatters.formatExerciseLastDone(lastWorkout))")
                .font(info == nil ? lastDoneFontSmall : lastDoneFontRegular)
                .foregroundStyle(info?.color ?? themeManager.effectiveTheme.mutedForeground)
        } else {
            // No history at all — flag in red so brand-new exercises stand
            // out alongside the stale-staleness reds elsewhere in the list.
            let isDark = themeManager.currentTheme == .dark
            let red: Color = isDark ? Color(red: 1.0, green: 0.40, blue: 0.40) : .red
            Text("No sets recorded")
                .font(lastDoneFontRegular)
                .foregroundStyle(red)
        }
    }

    // MARK: - Fonts

    private var nameFont: Font {
        themeManager.effectiveTheme.interFont(
            size: compact ? 16 : 18,
            weight: compact ? .medium : .semibold
        )
    }

    private var lastDoneFontRegular: Font {
        themeManager.effectiveTheme.interFont(size: compact ? 12 : 13, weight: .regular)
    }

    /// One step smaller — used for the grey "1-13 days" range so the
    /// orange / red staleness states stand out more.
    private var lastDoneFontSmall: Font {
        themeManager.effectiveTheme.interFont(size: compact ? 11 : 12, weight: .regular)
    }

    private var lastDoneFontMedium: Font {
        themeManager.effectiveTheme.interFont(size: compact ? 12 : 13, weight: .medium)
    }

    // MARK: - Staleness

    /// Compute staleness colour + label from the exercise's last set.
    /// Returns nil when the exercise has no sets, or when its last set
    /// was 1–13 days ago (the "no callout" range — recent enough not to
    /// flag as stale, but not today).
    ///
    /// Mirrors the logic that previously lived in
    /// `FilteredExerciseListView.stalenessInfo(for:)` — moved here so
    /// every context that renders an exercise card sees identical
    /// visual behaviour.
    private func liveStalenessInfo() -> (color: Color, label: String)? {
        guard let lastWorkout = exercise.lastWorkoutDate else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastWorkout),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
        if days == 0 { return (.green, "Today") }
        let isDark = themeManager.currentTheme == .dark
        if days >= 30 {
            return (isDark ? Color(red: 1.0, green: 0.40, blue: 0.40) : .red, "30d+")
        }
        if days >= 14 {
            return (isDark ? Color(red: 1.0, green: 0.70, blue: 0.30) : .orange, "\(days / 7) wks")
        }
        return nil
    }
}
