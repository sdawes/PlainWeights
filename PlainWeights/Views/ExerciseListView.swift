//
//  ExerciseListView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State private var showingAddExercise = false

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(value: exercise) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name).font(.headline)
                        Text(exercise.category).font(.subheadline).foregroundStyle(.secondary)
                        Text(exercise.createdDate, format: .dateTime)
                            .font(.caption).foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteExercises)
        }
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddExercise = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAddExercise) { AddExerciseView() }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        offsets.forEach { index in
            modelContext.delete(exercises[index])
        }
    }
}