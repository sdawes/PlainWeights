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
    @Query private var allExercises: [Exercise]
    @State private var showingAddExercise = false
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            filteredListView
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseDetailView(exercise: exercise)
                }
        }
    }

    @ViewBuilder
    private var filteredListView: some View {
        let listView = FilteredExerciseListView(
            searchText: searchText,
            showingAddExercise: $showingAddExercise,
            navigationPath: $navigationPath
        )

        // Only show search bar when exercises exist
        if allExercises.isEmpty {
            listView
        } else {
            listView
                .searchable(text: $searchText, prompt: "Search by name or tags")
        }
    }
}

struct FilteredExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Query private var exercises: [Exercise]
    @Binding var showingAddExercise: Bool
    @Binding var navigationPath: NavigationPath
    let searchText: String
    @State private var showingSummary = false
    @State private var showingSettings = false

    @State private var exerciseToDelete: Exercise?

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
                    exercise.tagsSearchable.localizedStandardContains(searchText)
                },
                sort: [SortDescriptor(\.lastUpdated, order: .reverse)]
            )
        }
    }

    /// Check if exercise hasn't been done in over 2 weeks (orange)
    private func isStale(_ exercise: Exercise) -> Bool {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        return exercise.lastUpdated < twoWeeksAgo
    }

    /// Check if exercise hasn't been done in over 1 month (red)
    private func isVeryStale(_ exercise: Exercise) -> Bool {
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return exercise.lastUpdated < oneMonthAgo
    }

    /// Get timestamp color
    private func timestampColor(for exercise: Exercise) -> Color {
        themeManager.currentTheme.tertiaryText
    }

    /// Get staleness color (red for 30+ days, orange for 14+ days, nil for recent)
    private func stalenessColor(for exercise: Exercise) -> Color? {
        if isVeryStale(exercise) { return .red }
        if isStale(exercise) { return .orange }
        return nil
    }

    var body: some View {
        List {
            // Exercises section
            if exercises.isEmpty && searchText.isEmpty {
                Section {
                    EmptyExercisesView(
                        onAddExercise: { showingAddExercise = true }
                    )
                    .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(Array(exercises.enumerated()), id: \.element.persistentModelID) { index, exercise in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(exercise.name)
                                .font(themeManager.currentTheme.interFont(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.currentTheme.primaryText)
                            if !exercise.tags.isEmpty {
                                TagPillsRow(tags: exercise.tags)
                                    .padding(.top, 6)
                            }
                            HStack(spacing: 4) {
                                if let color = stalenessColor(for: exercise) {
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(color)
                                }
                                Text("Last: \(Formatters.formatExerciseLastDone(exercise.lastUpdated))")
                                    .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                                    .foregroundStyle(stalenessColor(for: exercise) ?? themeManager.currentTheme.mutedForeground)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigationPath.append(exercise)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                exerciseToDelete = exercise
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(
                            HStack(spacing: 0) {
                                Color.clear.frame(width: 16)  // Match list leading inset
                                if let color = stalenessColor(for: exercise) {
                                    Rectangle()
                                        .fill(color)
                                        .frame(width: 2)
                                }
                                Rectangle()
                                    .fill(stalenessColor(for: exercise)?.opacity(0.05) ?? Color.clear)
                            }
                        )
                        .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        .listRowSeparatorTint(themeManager.currentTheme.borderColor)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.currentTheme.textColor)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSummary = true
                } label: {
                    Image(systemName: "trophy")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingAddExercise = true } label: {
                    Image(systemName: "plus")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { newExercise in
                // Navigate to the newly created exercise after sheet dismisses
                navigationPath.append(newExercise)
            }
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingSummary) {
            SessionSummaryView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .alert("Delete Exercise", isPresented: Binding(
            get: { exerciseToDelete != nil },
            set: { if !$0 { exerciseToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let exercise = exerciseToDelete {
                    deleteExercise(exercise)
                    exerciseToDelete = nil
                }
            }
        } message: {
            if let exercise = exerciseToDelete {
                Text("This will permanently delete \"\(exercise.name)\" and all its sets. This action cannot be undone.")
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
