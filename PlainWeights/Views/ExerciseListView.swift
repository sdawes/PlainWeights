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

    // State for view version selection
    @State private var selectedExercise: ExerciseNavigation?

    enum ViewVersion {
        case v1, v2
    }

    struct ExerciseNavigation: Identifiable, Hashable {
        let id = UUID()
        let exercise: Exercise
        let version: ViewVersion

        static func == (lhs: ExerciseNavigation, rhs: ExerciseNavigation) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

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
        List {
            // Exercises section
            if exercises.isEmpty {
                Section {
                    Text(searchText.isEmpty ? "No exercises yet" : "No matching exercises found")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(exercises, id: \.persistentModelID) { exercise in
                        // ORIGINAL NAVIGATION LINK - COMMENTED OUT FOR V1/V2 TESTING
                        // Will be restored later
                        /*
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
                        */

                        // TEMPORARY: V1/V2 button navigation
                        HStack(spacing: 12) {
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

                            Spacer()

                            // V1 Button (current design)
                            Button(action: {
                                selectedExercise = ExerciseNavigation(exercise: exercise, version: .v1)
                            }) {
                                Text("V1")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)

                            // V2 Button (new design)
                            Button(action: {
                                selectedExercise = ExerciseNavigation(exercise: exercise, version: .v2)
                            }) {
                                Text("V2")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
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
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Plain Weights")
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
        // ORIGINAL NAVIGATION - COMMENTED OUT FOR V1/V2 TESTING
        /*
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        */
        // TEMPORARY: Conditional navigation based on view version
        .navigationDestination(item: $selectedExercise) { selection in
            switch selection.version {
            case .v1:
                ExerciseDetailView(exercise: selection.exercise)
            case .v2:
                ExerciseDetailViewV2(exercise: selection.exercise)
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