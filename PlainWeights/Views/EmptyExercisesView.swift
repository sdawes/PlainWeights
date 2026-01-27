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
                        .font(themeManager.currentTheme.title2Font)
                }
            } description: {
                Text("Start tracking your workouts by adding your first exercise")
                    .font(themeManager.currentTheme.subheadlineFont)
            } actions: {
                Button {
                    onAddExercise()
                } label: {
                    Text("Add Exercise")
                        .font(themeManager.currentTheme.headlineFont)
                        .foregroundStyle(themeManager.currentTheme.textColor)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                .foregroundStyle(themeManager.currentTheme.textColor)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(RoundedRectangle(cornerRadius: 10))
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
