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
        if !searchText.isEmpty {
            // Search returned no results
            ContentUnavailableView.search(text: searchText)
        } else {
            // First-time user experience - no exercises at all
            VStack(spacing: 24) {
                Spacer()

                // Animated retro lifter
                RetroLifterView(pixelSize: 6)
                    .frame(height: 120)

                // Text content
                VStack(spacing: 8) {
                    Text("No Exercises Yet")
                        .font(themeManager.currentTheme.title2Font)
                        .foregroundStyle(themeManager.currentTheme.primaryText)

                    Text("Start tracking your workouts by adding your first exercise")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Add button - solid filled style
                Button(action: onAddExercise) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                    .font(themeManager.currentTheme.interFont(size: 17, weight: .semibold))
                    .foregroundStyle(themeManager.currentTheme.background)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(themeManager.currentTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
