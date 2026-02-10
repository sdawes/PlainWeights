//
//  ExerciseListView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

// Navigation destination type for History
enum HistoryDestination: Hashable {
    case history
}

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
                .navigationDestination(for: HistoryDestination.self) { destination in
                    switch destination {
                    case .history:
                        HistoryView()
                    }
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
    @Query private var allSets: [ExerciseSet]
    @Binding var showingAddExercise: Bool
    @Binding var navigationPath: NavigationPath
    let searchText: String
    @State private var showingSettings = false
    @State private var showingNoSessionAlert = false

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

    /// Check if exercise was done today (green)
    private func isDoneToday(_ exercise: Exercise) -> Bool {
        Calendar.current.isDateInToday(exercise.lastUpdated)
    }

    /// Get timestamp color
    private func timestampColor(for exercise: Exercise) -> Color {
        themeManager.effectiveTheme.tertiaryText
    }

    /// Get staleness color (red for 30+ days, orange for 14+ days, green for today, nil for recent)
    private func stalenessColor(for exercise: Exercise) -> Color? {
        if isVeryStale(exercise) { return .red }
        if isStale(exercise) { return .orange }
        if isDoneToday(exercise) { return .green }
        return nil
    }

    var body: some View {
        List {
            // Exercises section
            if exercises.isEmpty && searchText.isEmpty {
                // Simple inline hint when no exercises exist
                Section {
                    HStack {
                        Text("Tap + to add your first exercise")
                            .font(themeManager.effectiveTheme.bodyFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                        Spacer()

                        // Arrow pointing down-right toward FAB
                        Image(systemName: "arrow.down.right")
                            .font(.title3)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .padding(.trailing, 5)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(Array(exercises.enumerated()), id: \.element.persistentModelID) { index, exercise in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(exercise.name)
                                .font(themeManager.effectiveTheme.interFont(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                            if !exercise.tags.isEmpty {
                                TagPillsRow(tags: exercise.tags)
                                    .padding(.top, 6)
                            }
                            HStack(spacing: 4) {
                                if let color = stalenessColor(for: exercise), !isDoneToday(exercise) {
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(color)
                                }
                                if isDoneToday(exercise) {
                                    Text("Last: ")
                                        .font(themeManager.effectiveTheme.interFont(size: 14, weight: .regular))
                                        .foregroundStyle(.green)
                                    + Text("Today")
                                        .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Last: ")
                                        .font(themeManager.effectiveTheme.interFont(size: 14, weight: .regular))
                                        .foregroundStyle(stalenessColor(for: exercise) ?? themeManager.effectiveTheme.mutedForeground)
                                    + Text(Formatters.formatExerciseLastDone(exercise.lastUpdated))
                                        .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                                        .foregroundStyle(stalenessColor(for: exercise) ?? themeManager.effectiveTheme.mutedForeground)
                                }
                            }
                            .padding(.top, 12)
                        }
                        .padding(.leading, 14)
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
                            Group {
                                if let color = stalenessColor(for: exercise) {
                                    HStack(spacing: 0) {
                                        Color.clear.frame(width: 16)  // Match list leading inset
                                        // Vertical accent bar
                                        Rectangle()
                                            .fill(color)
                                            .frame(width: 2)
                                        // Background tint
                                        Rectangle()
                                            .fill(color.opacity(themeManager.currentTheme == .dark ? 0.15 : 0.05))
                                    }
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        .listRowSeparatorTint(themeManager.effectiveTheme.borderColor)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    }
                }
            }
        }
        .listStyle(.plain)
        .contentMargins(.top, 12, for: .scrollContent)
        .id(themeManager.effectiveTheme)  // Force list rebuild on theme change (uses effectiveTheme to handle System mode)
        .scrollIndicators(.hidden)
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) {
            Button(action: { showingAddExercise = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(themeManager.effectiveTheme.background)
            }
            .frame(width: 50, height: 50)
            .background(themeManager.effectiveTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if allSets.isEmpty {
                        showingNoSessionAlert = true
                    } else {
                        navigationPath.append(HistoryDestination.history)
                    }
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.effectiveTheme.textColor)
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
        .alert("No Session Data", isPresented: $showingNoSessionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Complete your first workout to see a session summary.")
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
