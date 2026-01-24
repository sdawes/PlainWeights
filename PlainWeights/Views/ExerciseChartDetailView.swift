//
//  ExerciseChartDetailView.swift
//  PlainWeights
//
//  Full-screen chart view for exercise progress visualization
//

import SwiftUI
import SwiftData

struct ExerciseChartDetailView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ChartContentView(exercise: exercise, sets: sets)
                    .padding(.horizontal)
                    .padding(.top, 20)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .navigationBarTitleDisplayMode(.inline)
    }
}
