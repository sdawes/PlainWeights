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
    @Query private var sets: [ExerciseSet]
    @Binding var showingAddExercise: Bool
    let searchText: String

    init(searchText: String, showingAddExercise: Binding<Bool>) {
        self.searchText = searchText
        self._showingAddExercise = showingAddExercise

        // Query recent sets (30 days) with search filtering in predicate
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast

        if searchText.isEmpty {
            _sets = Query(
                filter: #Predicate<ExerciseSet> { $0.timestamp >= startDate },
                sort: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        } else {
            _sets = Query(
                filter: #Predicate<ExerciseSet> { set in
                    set.timestamp >= startDate &&
                    (
                        (set.exercise?.name.localizedStandardContains(searchText) ?? false) ||
                        (set.exercise?.category.localizedStandardContains(searchText) ?? false)
                    )
                },
                sort: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        }
    }

    // Compute workout journal groups using service
    private var workoutDays: [ExerciseDataGrouper.WorkoutDay] {
        ExerciseDataGrouper.createWorkoutJournal(from: sets)
    }

    var body: some View {
        List {
            if sets.isEmpty {
                Text(searchText.isEmpty ? "No recent workouts" : "No matching exercises found")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(workoutDays, id: \.date) { day in
                    Section {
                        ForEach(day.exercises) { exercise in
                            NavigationLink(value: exercise.exercise) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.exercise.name)
                                        .font(.headline)
                                    Text(exercise.exercise.category)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    HStack {
                                        Text("\(exercise.setCount) sets")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                        Text("·")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                        Text("\(Formatters.formatVolume(exercise.volume)) kg")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        HStack {
                            Text(Formatters.formatWorkoutDayLabel(day.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(day.exerciseCount) exercises · \(Formatters.formatVolume(day.totalVolume)) kg")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
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
}