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
    @State private var cachedTodaysVolume: Double = 0
    @State private var cachedTodaysTotalReps: Int = 0
    @State private var cachedSessionDuration: Int? = nil
    @State private var cachedIsWeightedExercise: Bool = true
    @State private var cachedLastSessionVolume: Double = 0
    @State private var cachedBestSessionVolume: Double = 0
    @State private var cachedLastSessionReps: Int = 0
    @State private var cachedBestSessionReps: Int = 0

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
                    if !exercise.tags.isEmpty {
                        TagPillsRow(tags: exercise.tags)
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
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Inline Progress Chart - conditional based on toggle
            if showChart && !sets.isEmpty {
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
                    hasSetsBelow: !todaySets.isEmpty
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                if !todaySets.isEmpty {
                    // Set rows with card positions
                    ForEach(todaySets.indices, id: \.self) { index in
                        let set = todaySets[index]
                        let isLast = index == todaySets.count - 1
                        SetRowView(
                            set: set,
                            setNumber: todaySets.count - index,
                            isFirst: false,
                            isLast: isLast,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            allSets: (set.isWarmUp || set.isBonus) ? nil : Array(sets),
                            showTimer: index == 0,
                            cardPosition: isLast ? .bottom : .middle,
                            isFirstInCard: index == 0
                        )
                    }
                }
            }

            // History label (only show if there are historic days)
            if !historicDayGroups.isEmpty {
                Section {
                    Text("History")
                        .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
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

                    ForEach(dayGroup.sets.indices, id: \.self) { index in
                        let set = dayGroup.sets[index]
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
                        HStack {
                            Spacer()
                            Text("See older sessions (\(remainingCount) more)")
                                .font(themeManager.effectiveTheme.subheadlineFont)
                                .foregroundStyle(themeManager.effectiveTheme.primary)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }

        }
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
                let lastWorkingSet = sets.first(where: { !$0.isWarmUp && !$0.isBonus })
                addSetConfig = .previous(
                    exercise: exercise,
                    weight: lastWorkingSet?.weight,
                    reps: lastWorkingSet?.reps
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
                Button(action: { showNotes.toggle() }) {
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
                    Image(systemName: "pencil")
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
        }
        .onChange(of: sets) { _, _ in
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
    }

    private func deleteSet(_ set: ExerciseSet) {
        withAnimation {
            do {
                try ExerciseSetService.deleteSet(set, context: context)
            } catch {
                print("Error deleting set: \(error)")
            }
        }
    }

    private func updateNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        exercise.note = trimmed.isEmpty ? nil : trimmed
        exercise.bumpUpdated()

        do {
            try context.save()
        } catch {
            print("Error updating note: \(error)")
        }
    }

    /// Delete the exercise and all its associated sets (cascade delete)
    private func deleteExercise() {
        context.delete(exercise)
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to delete exercise: \(error)")
        }
    }

}
