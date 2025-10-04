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
        FilteredExerciseListView(
            searchText: searchText,
            showingAddExercise: $showingAddExercise
        )
        // Note: iOS 26+ automatically applies Liquid Glass styling to .searchable()
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

        // Query exercises directly with search filtering in predicate
        if searchText.isEmpty {
            _exercises = Query(
                sort: [SortDescriptor(\.lastUpdated, order: .reverse)]
            )
        } else {
            _exercises = Query(
                filter: #Predicate<Exercise> { exercise in
                    exercise.name.localizedStandardContains(searchText) ||
                    exercise.category.localizedStandardContains(searchText)
                },
                sort: [SortDescriptor(\.lastUpdated, order: .reverse)]
            )
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // WorkoutMetrics card
                WorkoutMetrics()
                    .padding(.horizontal, 16)

                // Exercises card
                VStack(spacing: 0) {
                    if exercises.isEmpty {
                        Text(searchText.isEmpty ? "No exercises yet" : "No matching exercises found")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(exercises.indices, id: \.self) { index in
                            let exercise = exercises[index]

                            NavigationLink(value: exercise) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(exercise.category)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(Formatters.formatExerciseLastDone(exercise.lastUpdated))
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteExercise(exercise)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                            if index < exercises.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.immediately)
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
                        .font(.callout)
                        .foregroundColor(.black)
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddExercise) { AddExerciseView() }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }

    // MARK: - Helper Functions

    /// Delete an exercise and all its associated sets (cascade delete)
    private func deleteExercise(_ exercise: Exercise) {
        withAnimation {
            modelContext.delete(exercise)
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete exercise: \(error)")
            }
        }
    }
}