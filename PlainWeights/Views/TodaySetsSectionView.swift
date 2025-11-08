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
    let todaySets: [ExerciseSet]
    let isMostRecentSet: (ExerciseSet, [ExerciseSet]) -> Bool
    let deleteSet: (ExerciseSet) -> Void

    var body: some View {
        ForEach(todaySets, id: \.persistentModelID) { set in
            HStack(alignment: .bottom) {
                Text(ExerciseSetFormatters.formatSet(set))
                    .monospacedDigit()
                    .foregroundStyle(set.isWarmUp ? .secondary : .primary)

                Spacer()

                if set.isWarmUp {
                    Circle()
                        .fill(.orange)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.white)
                        }
                }

                Text(Formatters.formatTimeHM(set.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
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