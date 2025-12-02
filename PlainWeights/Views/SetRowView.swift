//
//  SetRowView.swift
//  PlainWeights
//
//  Created by Claude on 09/11/2025.
//
//  Reusable component for displaying exercise set rows with fixed-width segments
//  for consistent vertical alignment across all sets.

import SwiftUI

// MARK: - Progress Comparison Data

struct ProgressComparison {
    let weightDelta: Double  // Difference from comparison weight
    let repsDelta: Int       // Difference from comparison reps
    let comparisonMode: String  // "vs Last" or "vs Best"
    let volumeProgress: Double  // Percentage progress (0.0 to 1.0)
}

// MARK: - Set Row View

struct SetRowView: View {
    let set: ExerciseSet
    let onTap: () -> Void
    let onDelete: () -> Void
    let progressComparison: ProgressComparison?  // Optional progress data for first set

    init(set: ExerciseSet, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, progressComparison: ProgressComparison? = nil) {
        self.set = set
        self.onTap = onTap
        self.onDelete = onDelete
        self.progressComparison = progressComparison
    }

    var body: some View {
        // New 5-column layout
        HStack(spacing: 0) {
            // Column 1
            Text("1")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray)

            // Column 2
            Text("2")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray)

            // Column 3
            Text("3")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray)

            // Column 4
            Text("4")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray)

            // Column 5 - Time
            Text(Formatters.formatTimeHM(set.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray)
        }
        .frame(height: 44)
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowBackground(
            progressComparison != nil ?
                Color.gray.opacity(0.1) : Color(.systemBackground)
        )
        .listRowSeparator(progressComparison != nil ? .hidden : .automatic)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Helper Methods

    private func deltaColor(for delta: Double) -> Color {
        if delta > 0 {
            return .green
        } else if delta < 0 {
            return .pw_red
        } else {
            return .pw_blue
        }
    }

    private func deltaText(for delta: Double) -> String {
        if delta > 0 {
            return "(+\(Int(delta)))"
        } else if delta < 0 {
            return "(\(Int(delta)))"
        } else {
            return "(same)"
        }
    }

    private func formatVolumeProgress(_ progress: Double, comparisonMode: String) -> String {
        let percentage = Int(progress * 100)
        let comparisonText = comparisonMode == "(vs Last)" ? "last" : "best"

        if progress > 0 {
            return "Total Volume +\(percentage)% of \(comparisonText)"
        } else if progress < 0 {
            return "Total Volume \(percentage)% of \(comparisonText)"
        } else {
            return "Total Volume same as \(comparisonText)"
        }
    }

    private func volumeProgressColor(for progress: Double) -> Color {
        if progress > 0 {
            return .pw_green
        } else if progress < 0 {
            return .pw_red
        } else {
            return .pw_blue
        }
    }
}
