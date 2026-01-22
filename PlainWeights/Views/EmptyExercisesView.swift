//
//  EmptyExercisesView.swift
//  PlainWeights
//
//  Created for displaying empty state when no exercises exist
//

import SwiftUI

struct EmptyExercisesView: View {
    @Environment(ThemeManager.self) private var themeManager
    let searchText: String
    let onAddExercise: () -> Void

    var body: some View {
        if searchText.isEmpty {
            // First-time user experience - no exercises at all
            ContentUnavailableView {
                VStack(spacing: 12) {
                    RetroLifterView(pixelSize: 5)
                    Text("No Exercises Yet")
                        .font(.jetBrainsMono(.title2))
                }
            } description: {
                Text("Start tracking your workouts by adding your first exercise")
                    .font(.jetBrainsMono(.subheadline))
            } actions: {
                Button {
                    onAddExercise()
                } label: {
                    Text("Add Exercise")
                        .font(.jetBrainsMono(.headline))
                        .foregroundStyle(themeManager.currentTheme.textColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .overlay(
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                .foregroundStyle(themeManager.currentTheme.textColor)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 24)
            }
            .padding(.top, 40)
        } else {
            // Search returned no results
            ContentUnavailableView.search(text: searchText)
        }
    }
}

#Preview {
    VStack {
        EmptyExercisesView(searchText: "", onAddExercise: {})
            .padding()

        Divider()

        EmptyExercisesView(searchText: "Bench Press", onAddExercise: {})
            .padding()
    }
    .environment(ThemeManager())
}
