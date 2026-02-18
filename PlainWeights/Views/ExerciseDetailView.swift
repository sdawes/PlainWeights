//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Exercise detail view with metrics and sets history
//

import SwiftUI
import SwiftData

// MARK: - ExerciseDetailView

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]
    @State private var addSetConfig: AddSetConfig?

    // Form state
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var showNotes: Bool = false
    @State private var showingEditSheet = false
    @State private var comparisonMode: ComparisonMode = .lastSession
    @State private var showChart: Bool = true  // Will be set in onAppear from setting

    // Cached data for performance - updated only when sets change
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []
    @State private var visibleHistoricDaysCount: Int = 10  // Pagination - show 10 days initially
    @State private var previousTodaySetsCount: Int = 0  // Track for auto-scroll on new set
    @State private var cachedTodaysVolume: Double = 0
    @State private var cachedTodaysTotalReps: Int = 0
    @State private var cachedSessionDuration: Int? = nil
    @State private var cachedIsWeightedExercise: Bool = true
    @State private var cachedLastSessionVolume: Double = 0
    @State private var cachedBestSessionVolume: Double = 0
    @State private var cachedLastSessionReps: Int = 0
    @State private var cachedBestSessionReps: Int = 0
    @State private var cachedExerciseTypeChanged: Bool = false

    // Simple getters for cached values
    private var todaysVolume: Double { cachedTodaysVolume }
    private var todaysTotalReps: Int { cachedTodaysTotalReps }
    private var sessionDurationMinutes: Int? { cachedSessionDuration }
    private var isWeightedExercise: Bool { cachedIsWeightedExercise }
    private var lastSessionVolume: Double { cachedLastSessionVolume }
    private var bestSessionVolume: Double { cachedBestSessionVolume }
    private var lastSessionReps: Int { cachedLastSessionReps }
    private var bestSessionReps: Int { cachedBestSessionReps }

    // Derived properties (cheap - just use cached values)
    private var percentOfBaseline: Int {
        let divisor = max(cachedLastSessionVolume, 1)
        return Int(round((cachedTodaysVolume / divisor) * 100))
    }

    private var percentOfTarget: Int {
        let divisor = max(cachedBestSessionVolume, 1)
        return Int(round((cachedTodaysVolume / divisor) * 100))
    }

    private var comparisonVolume: Double {
        comparisonMode == .lastSession ? cachedLastSessionVolume : cachedBestSessionVolume
    }

    private var comparisonReps: Int {
        comparisonMode == .lastSession ? cachedLastSessionReps : cachedBestSessionReps
    }

    // Label for progress bar based on selected mode
    private var comparisonLabel: String {
        comparisonMode == .lastSession ? "Last" : "Best"
    }

    // Calculate session duration in minutes for a set of sets
    // Duration = time from first set to last set + 3 min rest after last set
    private func calculateSessionDuration(for sets: [ExerciseSet]) -> Int? {
        guard !sets.isEmpty else { return nil }
        let sortedSets = sets.sorted { $0.timestamp < $1.timestamp }
        guard let first = sortedSets.first, let last = sortedSets.last else { return nil }
        let duration = last.timestamp.timeIntervalSince(first.timestamp) + 180
        let minutes = Int(round(duration / 60))
        return minutes > 0 ? minutes : nil
    }

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        _noteText = State(initialValue: exercise.note ?? "")
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
        List {
            // Title section
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(themeManager.effectiveTheme.title2Font)
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    if !exercise.tags.isEmpty || !exercise.secondaryTags.isEmpty {
                        TagPillsRow(tags: exercise.tags, secondaryTags: exercise.secondaryTags)
                    }
                }
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id("top")
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Inline Notes - conditional based on toggle
            if showNotes {
                Section {
                    InlineNotesComponent(noteText: $noteText, onSave: updateNote)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Inline Progress Chart - conditional based on toggle
            if showChart {
                Section {
                    InlineProgressChart(sets: Array(sets))
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Comparison mode toggle - card style buttons
            Section {
                HStack(spacing: 12) {
                    ForEach(ComparisonMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                comparisonMode = mode
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: mode == .lastSession ? "calendar.badge.clock" : "star.fill")
                                    .font(.system(size: 16))
                                Text(mode == .lastSession ? "Last" : "Best")
                                    .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(
                                comparisonMode == mode
                                    ? themeManager.effectiveTheme.background
                                    : themeManager.effectiveTheme.primaryText
                            )
                            .background(
                                comparisonMode == mode
                                    ? themeManager.effectiveTheme.primaryText
                                    : themeManager.effectiveTheme.cardBackgroundColor
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        comparisonMode == mode
                                            ? Color.clear
                                            : themeManager.effectiveTheme.borderColor,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .id("comparisonButtons")
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Comparison metrics card (responds to toggle)
            Section {
                ComparisonMetricsCard(
                    comparisonMode: comparisonMode,
                    sets: Array(sets)
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Today's Sets Section (unified card appearance)
            Section {
                // TODAY card header
                TodaySessionCard(
                    volume: todaysVolume,
                    durationMinutes: sessionDurationMinutes,
                    comparisonVolume: comparisonVolume,
                    comparisonReps: comparisonReps,
                    comparisonLabel: comparisonLabel,
                    isWeightedExercise: isWeightedExercise,
                    totalReps: todaysTotalReps,
                    setCount: todaySets.count,
                    hasSetsBelow: !todaySets.isEmpty,
                    exerciseTypeChanged: cachedExerciseTypeChanged
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                if !todaySets.isEmpty {
                    // Set rows with card positions
                    ForEach(todaySets.enumerated(), id: \.element.persistentModelID) { index, set in
                        let isLast = index == todaySets.count - 1
                        SetRowView(
                            set: set,
                            setNumber: todaySets.count - index,
                            isFirst: false,
                            isLast: isLast,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            allSets: set.isWarmUp ? nil : Array(sets),
                            showTimer: index == 0,
                            cardPosition: isLast ? .bottom : .middle,
                            isFirstInCard: index == 0
                        )
                        .id(index == 0 ? "latestSet" : nil)
                    }
                }
            }

            // History label (only show if there are historic days)
            if !historicDayGroups.isEmpty {
                Section {
                    Text("History")
                        .font(themeManager.effectiveTheme.interFont(size: 17, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Historic sets: one Section per day (unified card appearance)
            // Show limited days initially for performance
            let visibleHistoricDays = Array(historicDayGroups.prefix(visibleHistoricDaysCount))
            let hasMoreHistory = historicDayGroups.count > visibleHistoricDaysCount
            let remainingCount = historicDayGroups.count - visibleHistoricDaysCount

            ForEach(visibleHistoricDays.indices, id: \.self) { groupIndex in
                let dayGroup = visibleHistoricDays[groupIndex]
                Section {
                    // Day header (must be struct for List spacing to work correctly)
                    HistoricDayHeader(
                        dayGroup: dayGroup,
                        sessionDurationMinutes: calculateSessionDuration(for: dayGroup.sets)
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    ForEach(dayGroup.sets.enumerated(), id: \.element.persistentModelID) { index, set in
                        let isLast = index == dayGroup.sets.count - 1
                        SetRowView(
                            set: set,
                            setNumber: dayGroup.sets.count - index,
                            isFirst: false,
                            isLast: isLast,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            cardPosition: isLast ? .bottom : .middle,
                            isFirstInCard: index == 0,
                            isLastSetInDay: isLast
                        )
                    }
                }
            }

            // "See older sessions" button when more history exists
            if hasMoreHistory {
                Section {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            visibleHistoricDaysCount += 10
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("See \(remainingCount) more sessions")
                                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(themeManager.effectiveTheme.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(themeManager.effectiveTheme.primary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 24, bottom: 8, trailing: 24))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Bottom spacer to allow scrolling latest set lower on screen
            Section {
                Spacer()
                    .frame(height: 300)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

        }
        .id(themeManager.systemColorScheme) // Force List re-render on theme change
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .listSectionSpacing(24)
        .environment(\.defaultMinListRowHeight, 1)  // Allow rows to be as short as needed
        .scrollContentBackground(.hidden)
        .background(AnimatedGradientBackground())
        .scrollDismissesKeyboard(.immediately)
        .contentMargins(.top, 0, for: .scrollContent)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                let lastSet = sets.first
                addSetConfig = .previous(
                    exercise: exercise,
                    weight: lastSet?.weight,
                    reps: lastSet?.reps
                )
            }) {
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
                Button(action: {
                    let willShow = !showChart
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showChart.toggle()
                        if willShow {
                            scrollProxy.scrollTo("top", anchor: .top)
                        }
                    }
                }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(showChart
                            ? themeManager.effectiveTheme.accent
                            : themeManager.effectiveTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let willShow = !showNotes
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showNotes.toggle()
                        if willShow {
                            scrollProxy.scrollTo("top", anchor: .top)
                        }
                    }
                }) {
                    Image(systemName: "note.text")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(showNotes
                            ? themeManager.effectiveTheme.accent
                            : themeManager.effectiveTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.effectiveTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                IconComponents.deleteIcon {
                    showingDeleteAlert = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Exercise", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete \"\(exercise.name)\" and all its sets. This action cannot be undone.")
        }
        .sheet(item: $addSetConfig) { config in
            AddSetView(
                exercise: config.exercise,
                initialWeight: config.initialWeight,
                initialReps: config.initialReps,
                setToEdit: config.setToEdit
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExerciseView(exerciseToEdit: exercise)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .onAppear {
            showChart = themeManager.chartVisibleByDefault
            showNotes = themeManager.notesVisibleByDefault
            updateCachedData()
            previousTodaySetsCount = todaySets.count
        }
        .onChange(of: sets) { _, newSets in
            let oldCount = previousTodaySetsCount
            updateCachedData()
            // Scroll to show latest set when a new set is added
            if todaySets.count > oldCount {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(150))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollProxy.scrollTo("comparisonButtons", anchor: .top)
                    }
                }
            }
            previousTodaySetsCount = todaySets.count
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDataChanged)) { _ in
            // Refresh when set properties change (warm-up, to-failure, etc.)
            // @Query doesn't always detect property changes within objects
            updateCachedData()
        }
        } // ScrollViewReader
    }

    // MARK: - Data Management

    /// Update cached expensive calculations when sets change
    private func updateCachedData() {
        let allSets = Array(sets)
        let (todaysData, historicData) = ExerciseDataGrouper.separateTodayFromHistoric(sets: sets)
        todaySets = todaysData
        historicDayGroups = historicData

        // Cache expensive calculations ONCE
        cachedTodaysVolume = TodaySessionCalculator.getTodaysVolume(from: allSets)
        cachedTodaysTotalReps = TodaySessionCalculator.getTodaysTotalReps(from: allSets)
        cachedSessionDuration = TodaySessionCalculator.getSessionDurationMinutes(from: allSets)
        cachedLastSessionVolume = LastSessionCalculator.getLastSessionVolume(from: allSets)
        cachedLastSessionReps = RepsAnalytics.getLastSessionTotalRepsVolume(from: allSets)

        // Exclude today for best calculations
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let setsExcludingToday = allSets.filter { calendar.startOfDay(for: $0.timestamp) < today }
        cachedBestSessionVolume = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)?.totalVolume ?? 0
        cachedBestSessionReps = RepsAnalytics.getBestSessionTotalReps(from: allSets)

        // Check if weighted exercise
        let workingSets = todaysData.workingSets
        cachedIsWeightedExercise = workingSets.contains { $0.weight > 0 }

        // Detect exercise type transition (e.g., bodyweight → weighted or vice versa)
        if !workingSets.isEmpty, let lastSets = ExerciseDataHelper.getLastCompletedDaySets(from: allSets) {
            let todayType = ExerciseMetricsType.determine(from: workingSets)
            let lastType = ExerciseMetricsType.determine(from: lastSets)
            cachedExerciseTypeChanged = todayType != lastType
        } else {
            cachedExerciseTypeChanged = false
        }
    }

    private func deleteSet(_ set: ExerciseSet) {
        withAnimation {
            do {
                try ExerciseSetService.deleteSet(set, context: context)
            } catch { }
        }
    }

    private func updateNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        exercise.note = trimmed.isEmpty ? nil : trimmed
        exercise.bumpUpdated()

        do {
            try context.save()
        } catch { }
    }

    /// Delete the exercise and all its associated sets (cascade delete)
    private func deleteExercise() {
        context.delete(exercise)
        do {
            try context.save()
            dismiss()
        } catch { }
    }

}
