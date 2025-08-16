//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        Form {
            LabeledContent("Category", value: exercise.category)
            LabeledContent("Created", value: exercise.createdDate.formatted(date: .abbreviated, time: .shortened))
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
