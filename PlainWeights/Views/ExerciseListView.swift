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
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            FilteredExerciseListView(
                searchText: searchText,
                showingAddExercise: $showingAddExercise,
                navigationPath: $navigationPath
            )
            // Note: iOS 26+ automatically applies Liquid Glass styling to .searchable()
            .searchable(text: $searchText, prompt: "Search by name or category")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
}

struct FilteredExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @Binding var showingAddExercise: Bool
    @Binding var navigationPath: NavigationPath
    let searchText: String

    init(searchText: String, showingAddExercise: Binding<Bool>, navigationPath: Binding<NavigationPath>) {
        self.searchText = searchText
        self._showingAddExercise = showingAddExercise
        self._navigationPath = navigationPath

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
        List {
            // Exercises section
            if exercises.isEmpty {
                Section {
                    EmptyExercisesView(
                        searchText: searchText,
                        onAddExercise: { showingAddExercise = true }
                    )
                }
            } else {
                Section {
                    ForEach(exercises, id: \.persistentModelID) { exercise in
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
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteExercise(exercise)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("EXERCISES")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.94, green: 0.96, blue: 0.99))
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title3)
                    .foregroundStyle(.black)
                    .allowsHitTesting(false)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddExercise = true } label: { Image(systemName: "plus") }
            }
            #if DEBUG
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Print Data to Console") {
                        TestDataGenerator.printCurrentData(modelContext: modelContext)
                    }
                    Button("Generate Test Data") {
                        TestDataGenerator.generateTestData(modelContext: modelContext)
                    }
                    Button("Clear All Data", role: .destructive) {
                        TestDataGenerator.clearAllData(modelContext: modelContext)
                    }
                } label: {
                    Image(systemName: "hammer.fill")
                        .font(.callout)
                        .foregroundColor(.black)
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { newExercise in
                // Navigate to the newly created exercise after sheet dismisses
                navigationPath.append(newExercise)
            }
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