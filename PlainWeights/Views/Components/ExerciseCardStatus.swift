//
//  ExerciseCardStatus.swift
//  PlainWeights
//
//  Pre-computed, theme-independent display data for an ExerciseCard's
//  "last done" line. Built once in a batched pass by the exercise list
//  (see FilteredExerciseListView.rebuildCardStatusCache) so the card does
//  zero Calendar math or `sets` faulting during scroll. Colours stay out
//  of this type on purpose — the card resolves them live from `level` so
//  in-app theme switches update instantly without rebuilding the cache.
//

/// Staleness bucket for an exercise, mirroring the live logic that used
/// to run inside ExerciseCard.liveStalenessInfo.
struct ExerciseCardStatus {
    enum Level {
        case today      // worked out today
        case recent     // 1–13 days ago — no callout dot
        case twoWeeks   // 14–29 days ago
        case month      // 30+ days ago
        case noSets     // no sets recorded yet
    }

    let level: Level
    /// Formatted "X days ago" text (empty for `.today` / `.noSets`, which
    /// render fixed strings).
    let lastDoneString: String
}
