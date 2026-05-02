//
//  GroupExerciseRow.swift
//  PlainWeights
//
//  Exercise row used inside an expanded GroupCard. Unlike the main
//  list's `ExerciseCard`, this row reflects GROUP-level state only:
//  it shows a green "Done" tick exclusively when the user has logged
//  a set for this exercise today *from within this specific group's
//  context* (i.e. the set's `sourceGroup` matches the parent group).
//
//  Sets logged for the same exercise via another group, or via the
//  main list, do not affect this row's appearance — keeping the
//  per-row indicator consistent with the group card's "X/Y done
//  today" counter.
//
//  The "done" flag is computed once at the parent `GroupCard` level
//  and passed in here, avoiding per-row scans through the exercise's
//  set history.
//

import SwiftUI

struct GroupExerciseRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise
    /// True when the user has logged any set for this exercise today
    /// with `sourceGroup` matching the parent group. Supplied by the
    /// parent so we don't repeat the scan per row.
    let isDoneFromGroupToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top row — name + done indicator
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(exercise.name)
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)

                Spacer(minLength: 8)

                if isDoneFromGroupToday {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("Logged")
                            .font(themeManager.effectiveTheme.interFont(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.green)
                }
            }

            // Tag pills (when present)
            if !exercise.tags.isEmpty || !exercise.secondaryTags.isEmpty {
                TagPillsRow(
                    tags: exercise.tags,
                    secondaryTags: exercise.secondaryTags
                )
            }

            // Plain "Last: ..." line — purely informational, no colour
            // logic, no dots. Mirrors what the main list shows but
            // stripped down so it doesn't compete with the green
            // "Logged" badge above.
            if let lastWorkout = exercise.lastWorkoutDate {
                HStack(spacing: 0) {
                    Text("Last: ")
                        .font(themeManager.effectiveTheme.interFont(size: 13, weight: .regular))
                    Text(Formatters.formatExerciseLastDone(lastWorkout))
                        .font(themeManager.effectiveTheme.interFont(size: 13, weight: .medium))
                }
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .padding(.top, 2)
            }
        }
    }
}
