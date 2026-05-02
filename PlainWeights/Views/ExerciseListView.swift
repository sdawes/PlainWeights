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

// Navigation destination type for the saved groups list
enum GroupsDestination: Hashable {
    case groupsList
}

// Search scope for filtering exercises by name or tags
enum ExerciseSearchScope: String, CaseIterable {
    case name = "Name"
    case tags = "Tags"
}

/// Mode that drives `FilteredExerciseListView`.
///
/// `.browse` is the default — tapping a row pushes the exercise detail,
/// the FAB is visible, and the AI / Groups / Settings / History toolbar
/// items are shown.
///
/// `.selectingForGroup` is used when the view is presented modally from
/// the Groups screen as a picker. Selection circles are always visible,
/// tapping a row toggles selection (does not navigate), the FAB is
/// hidden, and Cancel + Done replace the browse toolbar.
enum SelectionMode {
    case browse
    case selectingForGroup(
        contextLabel: String,
        initialSelection: Set<PersistentIdentifier>,
        /// Whether to render an explicit Cancel button. Pass `false`
        /// when this view is pushed onto a navigation stack (i.e. there
        /// is already an automatic Back button), `true` when it's the
        /// stack's root.
        showsCancel: Bool,
        onSubmit: ([Exercise]) -> Void,
        onCancel: () -> Void
    )

    var isSelectingForGroup: Bool {
        if case .selectingForGroup = self { return true }
        return false
    }

    var contextLabel: String? {
        if case let .selectingForGroup(label, _, _, _, _) = self { return label }
        return nil
    }
}

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allExercises: [Exercise]
    @State private var showingAddExercise = false
    @State private var searchText = ""
    @State private var searchScope: ExerciseSearchScope = .name
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            filteredListView
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseDetailView(exercise: exercise)
                }
                .navigationDestination(for: GroupExerciseDestination.self) { dest in
                    ExerciseDetailView(exercise: dest.exercise, sourceGroup: dest.group)
                }
                .navigationDestination(for: HistoryDestination.self) { _ in
                    HistoryView(navigationPath: $navigationPath)
                }
                .navigationDestination(for: GroupsDestination.self) { _ in
                    ExerciseGroupsView(navigationPath: $navigationPath)
                }
        }
    }

    @ViewBuilder
    private var filteredListView: some View {
        let listView = FilteredExerciseListView(
            searchText: searchText,
            searchScope: searchScope,
            showingAddExercise: $showingAddExercise,
            navigationPath: $navigationPath,
            mode: .browse
        )

        // Only show search bar when exercises exist
        if allExercises.isEmpty {
            listView
        } else {
            listView
                .searchable(text: $searchText, prompt: "Search exercises")
                .searchScopes($searchScope, activation: .onTextEntry) {
                    Text("Name").tag(ExerciseSearchScope.name)
                    Text("Tags").tag(ExerciseSearchScope.tags)
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
    let searchScope: ExerciseSearchScope
    let mode: SelectionMode

    @State private var showingSettings = false
    @State private var showingNoSessionAlert = false
    @State private var showingAISummary = false
    /// Exercise IDs currently ticked. Initialised from `mode.initialSelection`
    /// in `.selectingForGroup`, otherwise empty (and unused).
    @State private var selectedGroupingIDs: Set<PersistentIdentifier>
    @State private var exerciseToDelete: Exercise?
    @State private var showError = false

    // MARK: - Cached Data (for scroll performance)
    /// Pre-computed staleness colors to avoid expensive Calendar operations during scroll
    @State private var cachedStalenessColors: [PersistentIdentifier: Color?] = [:]
    /// Pre-computed "done today" flags
    @State private var cachedDoneToday: Set<PersistentIdentifier> = []
    /// Pre-sorted exercises to avoid expensive lastWorkoutDate lookups on every render
    @State private var cachedSortedExercises: [Exercise] = []

    init(
        searchText: String,
        searchScope: ExerciseSearchScope,
        showingAddExercise: Binding<Bool>,
        navigationPath: Binding<NavigationPath>,
        mode: SelectionMode = .browse
    ) {
        self.searchText = searchText
        self.searchScope = searchScope
        self._showingAddExercise = showingAddExercise
        self._navigationPath = navigationPath
        self.mode = mode

        // Pre-tick the user's existing selection when editing an existing group.
        if case .selectingForGroup(_, let initial, _, _, _) = mode {
            _selectedGroupingIDs = State(initialValue: initial)
        } else {
            _selectedGroupingIDs = State(initialValue: [])
        }

        // Fetch all exercises — filtering by search text + scope happens in the sorted cache
        _exercises = Query(
            sort: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
    }

    /// Check if exercise hasn't been done in over 2 weeks (orange)
    /// Uses lastWorkoutDate (actual sets) not lastUpdated (metadata changes)
    private func isStale(_ exercise: Exercise) -> Bool {
        guard let lastWorkout = exercise.lastWorkoutDate else { return true } // No sets = stale
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        return lastWorkout < twoWeeksAgo
    }

    /// Check if exercise hasn't been done in over 1 month (red)
    /// Uses lastWorkoutDate (actual sets) not lastUpdated (metadata changes)
    private func isVeryStale(_ exercise: Exercise) -> Bool {
        guard let lastWorkout = exercise.lastWorkoutDate else { return true } // No sets = very stale
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return lastWorkout < oneMonthAgo
    }

    /// Check if exercise was done today (green)
    /// Uses lastWorkoutDate (actual sets) not lastUpdated (metadata changes)
    private func isDoneToday(_ exercise: Exercise) -> Bool {
        exercise.wasWorkedOutToday
    }

    /// Get timestamp color
    private func timestampColor(for exercise: Exercise) -> Color {
        themeManager.effectiveTheme.tertiaryText
    }

    /// Get staleness color (red for 30+ days, orange for 14+ days, green for today, nil for recent/no sets)
    private func stalenessColor(for exercise: Exercise) -> Color? {
        // No color for exercises with no sets yet
        guard exercise.lastWorkoutDate != nil else { return nil }
        let isDark = themeManager.currentTheme == .dark
        if isVeryStale(exercise) {
            return isDark ? Color(red: 1.0, green: 0.40, blue: 0.40) : .red
        }
        if isStale(exercise) {
            return isDark ? Color(red: 1.0, green: 0.70, blue: 0.30) : .orange
        }
        if isDoneToday(exercise) {
            return isDark ? Color(red: 0.40, green: 0.90, blue: 0.50) : .green
        }
        return nil
    }

    /// Rebuild the sorted exercises cache — filters by search text + scope, then sorts
    private func rebuildSortedExercisesCache() {
        // Filter by search text and scope
        let filtered: [Exercise]
        if searchText.isEmpty {
            filtered = exercises
        } else {
            switch searchScope {
            case .name:
                filtered = exercises.filter { $0.name.localizedStandardContains(searchText) }
            case .tags:
                filtered = exercises.filter { exercise in
                    exercise.tags.contains { $0.localizedStandardContains(searchText) }
                    || exercise.secondaryTags.contains { $0.localizedStandardContains(searchText) }
                }
            }
        }

        // Sort by most recent workout first
        cachedSortedExercises = filtered.sorted { a, b in
            let aDate = a.lastWorkoutDate ?? a.lastUpdated
            let bDate = b.lastWorkoutDate ?? b.lastUpdated
            return aDate > bDate
        }
    }

    /// Rebuild the staleness cache - call when exercises change
    private func rebuildStalenessCache() {
        // Reuse calendar instance and pre-compute thresholds
        let calendar = Calendar.current
        let now = Date()
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let oneMonthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let today = calendar.startOfDay(for: now)

        var colors: [PersistentIdentifier: Color?] = [:]
        var doneToday: Set<PersistentIdentifier> = []

        for exercise in exercises {
            let id = exercise.persistentModelID

            // Compute staleness color
            if let lastWorkout = exercise.lastWorkoutDate {
                if lastWorkout < oneMonthAgo {
                    colors[id] = .red
                } else if lastWorkout < twoWeeksAgo {
                    colors[id] = .orange
                } else if calendar.startOfDay(for: lastWorkout) == today {
                    colors[id] = .green
                    doneToday.insert(id)
                } else {
                    colors[id] = nil
                }
            } else {
                colors[id] = nil
            }
        }

        cachedStalenessColors = colors
        cachedDoneToday = doneToday
    }

    var body: some View {
        List {
            // Exercises section
            if exercises.isEmpty && searchText.isEmpty {
                // Empty state — faux exercise card pointing to the + button
                Section {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Add your first exercise")
                                .font(themeManager.effectiveTheme.interFont(size: 18, weight: .semibold))
                                .foregroundStyle(themeManager.effectiveTheme.primaryText)

                            Text("Tap the + at the bottom to start logging.")
                                .font(themeManager.effectiveTheme.interFont(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        }

                        Spacer()

                        Image(systemName: "arrow.down")
                            .font(.title3)
                            .foregroundStyle(themeManager.effectiveTheme.chartColor1)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.effectiveTheme.cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                // iCloud sync hint — pale blue info box below the card
                Section {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "icloud.and.arrow.down")
                            .font(.system(size: 13))
                            .foregroundStyle(.blue)
                        Text("If you've used the app before, your data may take a few minutes to sync from iCloud. Otherwise, add an exercise to get started.")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if cachedSortedExercises.isEmpty && !searchText.isEmpty {
                // No results for search query
                Section {
                    Text("No exercises found")
                        .font(themeManager.effectiveTheme.bodyFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(cachedSortedExercises.enumerated(), id: \.element.persistentModelID) { index, exercise in
                        exerciseRow(exercise)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .id(themeManager.systemColorScheme) // Force List re-render on theme change
        .listStyle(.plain)
        .contentMargins(.top, 12, for: .scrollContent)
        .scrollIndicators(.hidden)
        .listSectionSpacing(6)
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(mode.contextLabel.map { "Add to \($0)" } ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            // FAB only in browse mode — selection mode hides it.
            if !mode.isSelectingForGroup {
                Button(action: { showingAddExercise = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(themeManager.effectiveTheme.background)
                }
                .frame(width: 55, height: 55)
                .background(themeManager.effectiveTheme.primary)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .accessibilityLabel("Add exercise")
                .padding(.trailing, 20)
                .padding(.bottom, 3)
            }
        }
        .toolbar {
            if case .selectingForGroup(_, _, let showsCancel, let onSubmit, let onCancel) = mode {
                if showsCancel {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            onCancel()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Deselect all", systemImage: "xmark.circle") {
                        withAnimation {
                            selectedGroupingIDs.removeAll()
                        }
                    }
                    .disabled(selectedGroupingIDs.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        let selected = exercises.filter {
                            selectedGroupingIDs.contains($0.persistentModelID)
                        }
                        onSubmit(selected)
                    }
                    .fontWeight(.semibold)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(themeManager.effectiveTheme.textColor)
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("AI summary", systemImage: "sparkles") {
                        showingAISummary = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Check if any exercise has sets
                        let hasSets = exercises.contains { !($0.sets?.isEmpty ?? true) }
                        if !hasSets {
                            showingNoSessionAlert = true
                        } else {
                            navigationPath.append(HistoryDestination.history)
                        }
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .accessibilityLabel("View history")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Groups", systemImage: "rectangle.stack.fill") {
                        navigationPath.append(GroupsDestination.groupsList)
                    }
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
        .sheet(isPresented: $showingAISummary) {
            AISummaryView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .alert("Something Went Wrong", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The operation couldn't be completed. Please try again.")
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
        .onAppear {
            rebuildSortedExercisesCache()
            rebuildStalenessCache()
            // Warm up the on-device summarisation model so the first tap
            // of the AI button has lower latency.
            AISummaryService.prewarm()
        }
        .onChange(of: exercises) { _, _ in
            rebuildSortedExercisesCache()
            rebuildStalenessCache()
        }
        .onChange(of: searchText) { _, _ in
            rebuildSortedExercisesCache()
        }
        .onChange(of: searchScope) { _, _ in
            rebuildSortedExercisesCache()
        }
    }

    // MARK: - Exercise Row

    /// A single exercise row extracted from body to reduce compiler type-check complexity
    @ViewBuilder
    private func exerciseRow(_ exercise: Exercise) -> some View {
        let isSelected = selectedGroupingIDs.contains(exercise.persistentModelID)
        let cachedDone = cachedDoneToday.contains(exercise.persistentModelID)
        let inSelectionMode = mode.isSelectingForGroup

        HStack(spacing: 12) {
            // Selection circle — visible whenever the view is in selection mode.
            if inSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        isSelected
                            ? themeManager.effectiveTheme.primary
                            : themeManager.effectiveTheme.mutedForeground
                    )
                    .accessibilityLabel(isSelected ? "Selected" : "Not selected")
            }

            ExerciseCard(
                exercise: exercise,
                cachedIsDoneToday: cachedDone,
                nameAttributed: searchText.isEmpty ? nil : highlightedName(exercise.name),
                tagHighlight: searchScope == .tags ? searchText : "",
                compact: false
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            if inSelectionMode {
                toggleGroupingSelection(for: exercise)
            } else {
                navigationPath.append(exercise)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // No swipe-to-delete in selection mode — it would conflict with
            // the selection gesture and isn't relevant to the picking task.
            if !inSelectionMode {
                Button(role: .destructive) {
                    exerciseToDelete = exercise
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Helper Functions

    /// Toggle membership of an exercise in the grouping selection set.
    private func toggleGroupingSelection(for exercise: Exercise) {
        let id = exercise.persistentModelID
        if selectedGroupingIDs.contains(id) {
            selectedGroupingIDs.remove(id)
        } else {
            selectedGroupingIDs.insert(id)
        }
    }

    /// Delete an exercise and all its associated sets (cascade delete)
    private func deleteExercise(_ exercise: Exercise) {
        withAnimation {
            modelContext.delete(exercise)
            do {
                try modelContext.save()
            } catch {
                showError = true
            }
        }
    }

    /// Create highlighted text with search matches in yellow
    private func highlightedName(_ name: String) -> AttributedString {
        var attributedString = AttributedString(name)

        guard !searchText.isEmpty else { return attributedString }

        // Find range of search text (case-insensitive)
        if let range = name.localizedStandardRange(of: searchText) {
            // Convert String.Index range to AttributedString.Index range
            let start = AttributedString.Index(range.lowerBound, within: attributedString)
            let end = AttributedString.Index(range.upperBound, within: attributedString)

            if let start = start, let end = end {
                attributedString[start..<end].backgroundColor = .yellow
                attributedString[start..<end].foregroundColor = .black
            }
        }

        return attributedString
    }
}
