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
    @State private var searchText = ""

    var body: some View {
        FilteredExerciseListView(searchText: searchText, showingAddExercise: $showingAddExercise)
            .searchable(text: $searchText, prompt: "Search by name or category")
    }
}

struct FilteredExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @Binding var showingAddExercise: Bool
    let searchText: String
    
    init(searchText: String, showingAddExercise: Binding<Bool>) {
        self.searchText = searchText
        self._showingAddExercise = showingAddExercise
        
        // Dynamic query based on search text
        if searchText.isEmpty {
            _exercises = Query(
                sort: [SortDescriptor(\Exercise.lastUpdated, order: .reverse)]
            )
        } else {
            _exercises = Query(
                filter: #Predicate<Exercise> { exercise in
                    exercise.name.localizedStandardContains(searchText) ||
                    exercise.category.localizedStandardContains(searchText)
                },
                sort: [SortDescriptor(\Exercise.lastUpdated, order: .reverse)]
            )
        }
    }

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