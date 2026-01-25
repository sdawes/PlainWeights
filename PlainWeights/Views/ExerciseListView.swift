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
            .searchable(text: $searchText, prompt: "Search by name or tags")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
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

    #if DEBUG
    @State private var showingGenerateDataAlert = false
    @State private var showingClearDataAlert = false
    #endif

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

    /// Check if exercise hasn't been done in over a month
    private func isStale(_ exercise: Exercise) -> Bool {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return exercise.lastUpdated < oneMonthAgo
    }

    /// Check if exercise hasn't been done in over two months
    private func isVeryStale(_ exercise: Exercise) -> Bool {
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        return exercise.lastUpdated < twoMonthsAgo
    }

    /// Get name opacity based on staleness
    private func nameOpacity(for exercise: Exercise) -> Double {
        if isVeryStale(exercise) { return 0.4 }
        if isStale(exercise) { return 0.6 }
        return 1.0
    }

    /// Get timestamp color
    private func timestampColor(for exercise: Exercise) -> Color {
        themeManager.currentTheme.tertiaryText
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
                    .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(Array(exercises.enumerated()), id: \.element.persistentModelID) { index, exercise in
                        NavigationLink(value: exercise) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(exercise.name)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(themeManager.currentTheme.primaryText)
                                    .opacity(nameOpacity(for: exercise))
                                if !exercise.tags.isEmpty {
                                    TagPillsRow(tags: exercise.tags)
                                        .padding(.top, 6)
                                }
                                Text(Formatters.formatExerciseLastDone(exercise.lastUpdated))
                                    .font(.caption)
                                    .foregroundStyle(timestampColor(for: exercise))
                                    .padding(.top, 10)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteExercise(exercise)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        .listRowSeparatorTint(themeManager.currentTheme.borderColor)
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
        .toolbarBackground(themeManager.currentTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 0.5)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("PlainWeights")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(themeManager.currentTheme.primaryText)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.currentTheme.textColor)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingAddExercise = true } label: {
                    Image(systemName: "plus")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
            #if DEBUG
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Print Data to Console") {
                        TestDataGenerator.printCurrentData(modelContext: modelContext)
                    }

                    Divider()

                    Button("Generate Test Data", role: .destructive) {
                        showingGenerateDataAlert = true
                    }
                    Button("Clear All Data", role: .destructive) {
                        showingClearDataAlert = true
                    }
                } label: {
                    Image(systemName: "hammer")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.currentTheme.textColor)
                }
            }
            #endif
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSummary = true
                } label: {
                    Image(systemName: "chart.bar.doc.horizontal")
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
        .fullScreenCover(isPresented: $showingSummary) {
            SessionSummaryView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        #if DEBUG
        .alert("Generate Test Data?", isPresented: $showingGenerateDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete & Generate", role: .destructive) {
                TestDataGenerator.generateTestData(modelContext: modelContext)
            }
        } message: {
            Text("This will DELETE all your existing workout data and replace it with test data. This cannot be undone.")
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                TestDataGenerator.clearAllData(modelContext: modelContext)
            }
        } message: {
            Text("This will DELETE all your workout data including exercises and sets. This cannot be undone.")
        }
        #endif
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
