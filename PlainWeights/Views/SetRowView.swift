//
//  SetRowView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Reusable component for displaying exercise set rows with fixed-width segments
//  for consistent vertical alignment across all sets.

import SwiftUI

struct SetRowView: View {
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Segment 1: Weight/Reps (natural width)
            Text(ExerciseSetFormatters.formatSet(set))
                .monospacedDigit()
                .foregroundStyle(set.isWarmUp ? .secondary : .primary)

            // Segment 2: Icon Container (120pt fixed, 8pt left padding)
            HStack(spacing: 5) {
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

                if set.isDropSet {
                    Circle()
                        .fill(.teal)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(.white)
                        }
                }

                if set.isPauseAtTop {
                    Circle()
                        .fill(.pink)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.white)
                        }
                }

                if set.isTimedSet {
                    Circle()
                        .fill(.black)
                        .frame(width: 20, height: 20)
                        .overlay {
                            if set.tempoSeconds > 0 {
                                Text("\(set.tempoSeconds)")
                                    .font(.system(size: 11))
                                    .italic()
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            } else {
                                Image(systemName: "timer")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            }
                        }
                }

                if set.isPB {
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Text("PB")
                                .font(.system(size: 9))
                                .italic()
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 120, alignment: .leading)
            .padding(.leading, 8)

            Spacer()

            // Segment 3: Timestamp (50pt fixed, right-aligned)
            Text(Formatters.formatTimeHM(set.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
