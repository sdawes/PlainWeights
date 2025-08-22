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
    @State private var showingAddExercise = false

    var body: some View {
        SortedExerciseListView(showingAddExercise: $showingAddExercise)
    }
}

struct SortedExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Exercise.lastUpdated, order: .reverse)]) private var exercises: [Exercise]
    @Binding var showingAddExercise: Bool

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(value: exercise) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name).font(.headline)
                        Text(exercise.category).font(.subheadline).foregroundStyle(.secondary)
                        Text(exercise.lastUpdated, format: .relative(presentation: .named))
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
            #if DEBUG
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Print Data to Console") {
                        TestDataGenerator.printCurrentData(modelContext: modelContext)
                    }
                    Divider()
                    Button("Generate Set 1 (1 Month)") {
                        TestDataGenerator.generateTestDataSet1(modelContext: modelContext)
                    }
                    Button("Generate Set 2 (1 Year)") {
                        TestDataGenerator.generateTestDataSet2(modelContext: modelContext)
                    }
                    Button("Generate Set 3 (2 Weeks)") {
                        TestDataGenerator.generateTestDataSet3(modelContext: modelContext)
                    }
                    Button("Generate Live Data (Real Workouts)") {
                        TestDataGenerator.generateTestDataSet4(modelContext: modelContext)
                    }
                    Divider()
                    Button("Clear All Data", role: .destructive) {
                        TestDataGenerator.clearAllData(modelContext: modelContext)
                    }
                } label: {
                    Image(systemName: "ladybug.fill")
                        .foregroundColor(.orange)
                }
            }
            #endif
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