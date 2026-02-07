//
//  TodaySetsSectionView.swift
//  PlainWeights
//
//  Created by Claude on 28/09/2025.
//

import SwiftUI
import SwiftData

/// Component for displaying today's sets separately from historic sets
struct TodaySetsSectionView: View {
    @Environment(ThemeManager.self) private var themeManager
    let todaySets: [ExerciseSet]
    let isMostRecentSet: (ExerciseSet, [ExerciseSet]) -> Bool
    let deleteSet: (ExerciseSet) -> Void
    let onSetTap: (ExerciseSet) -> Void

    var body: some View {
        ForEach(todaySets, id: \.persistentModelID) { set in
            HStack(alignment: .bottom) {
                Text(ExerciseSetFormatters.formatSet(set))
                    .font(themeManager.currentTheme.bodyFont)
                    .foregroundStyle((set.isWarmUp || set.isBonus) ? .secondary : .primary)

                Spacer()

                if set.isWarmUp {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                }

                if set.isBonus {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                }

                if set.isDropSet {
                    Image(systemName: "chevron.down.2")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                }

                if set.isPauseAtTop {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                }

                if set.isTimedSet {
                    if set.tempoSeconds > 0 {
                        Text("\(set.tempoSeconds)")
                            .font(themeManager.currentTheme.dataFont(size: 14))
                            .foregroundStyle(.primary)
                    } else {
                        Image(systemName: "timer")
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                    }
                }

                if set.isPB {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(themeManager.currentTheme.pbColor)
                }

                Text(Formatters.formatTimeHM(set.timestamp))
                    .font(themeManager.currentTheme.dataFont(size: 12))
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onSetTap(set)
            }
            .listRowSeparator(isFirst(set) ? .hidden : .visible, edges: .top)
            .listRowSeparator(isLast(set) ? .hidden : .visible, edges: .bottom)
            .swipeActions {
                Button("Delete", role: .destructive) {
                    deleteSet(set)
                }
            }
        }
    }

    // MARK: - Helper Methods

    /// Check if a set is the first in today's list
    private func isFirst(_ set: ExerciseSet) -> Bool {
        set.persistentModelID == todaySets.first?.persistentModelID
    }

    /// Check if a set is the last in today's list
    private func isLast(_ set: ExerciseSet) -> Bool {
        set.persistentModelID == todaySets.last?.persistentModelID
    }
}