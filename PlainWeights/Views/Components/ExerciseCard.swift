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
        let isDoneToday = cachedIsDoneToday ?? exercise.wasWorkedOutToday
        let info = liveStalenessInfo()

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

            // Last workout line with optional staleness dot
            HStack(spacing: 6) {
                if let info {
                    Circle()
                        .fill(info.color)
                        .frame(width: 6, height: 6)
                }
                lastDoneText(isDoneToday: isDoneToday, info: info)
            }
            .padding(.top, compact ? 8 : 12)
        }
    }

    // MARK: - Last-done line

    @ViewBuilder
    private func lastDoneText(
        isDoneToday: Bool,
        info: (color: Color, label: String)?
    ) -> some View {
        if isDoneToday {
            HStack(spacing: 0) {
                Text("Last: ").font(lastDoneFontRegular)
                Text("Today").font(lastDoneFontMedium)
            }
            .foregroundStyle(info?.color ?? .green)
        } else if let lastWorkout = exercise.lastWorkoutDate {
            HStack(spacing: 0) {
                Text("Last: ").font(lastDoneFontRegular)
                Text(Formatters.formatExerciseLastDone(lastWorkout)).font(lastDoneFontMedium)
            }
            .foregroundStyle(info?.color ?? themeManager.effectiveTheme.mutedForeground)
        } else {
            Text("No sets recorded")
                .font(lastDoneFontRegular)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
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
        themeManager.effectiveTheme.interFont(size: compact ? 13 : 14, weight: .regular)
    }

    private var lastDoneFontMedium: Font {
        themeManager.effectiveTheme.interFont(size: compact ? 13 : 14, weight: .medium)
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
