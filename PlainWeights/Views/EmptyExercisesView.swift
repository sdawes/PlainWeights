//
//  EmptyExercisesView.swift
//  PlainWeights
//
//  Created for displaying empty state when no exercises exist
//

import SwiftUI

struct EmptyExercisesView: View {
    let searchText: String
    let onAddExercise: () -> Void

    var body: some View {
        if searchText.isEmpty {
            // First-time user experience - no exercises at all
            ContentUnavailableView {
                VStack(spacing: 12) {
                    RetroLifterView(pixelSize: 5)
                    Text("No Exercises Yet")
                        .font(.system(.title2, design: .monospaced))
                }
            } description: {
                Text("Start tracking your workouts by adding your first exercise")
                    .font(.system(.subheadline, design: .monospaced))
            } actions: {
                Button {
                    onAddExercise()
                } label: {
                    Text("Add Exercise")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .overlay(
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                .foregroundStyle(.black)
                        )
                }
                .buttonStyle(.plain)
            }
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
}
