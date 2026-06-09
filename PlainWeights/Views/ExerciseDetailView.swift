//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Exercise detail view with metrics and sets history
//

import SwiftUI
import SwiftData

/// Snapshot of the current PB set used to detect transitions across updates.
private struct PBSignature: Equatable {
    let id: PersistentIdentifier
    let weight: Double
    let reps: Int
}

// MARK: - ExerciseDetailView

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    /// Non-nil when navigated to from a GroupCard. Passed through to
    /// AddSetView so new sets are tagged to this group.
    var sourceGroup: ExerciseGroup? = nil
    @Query private var sets: [ExerciseSet]
    @State private var addSetConfig: AddSetConfig?

    // Form state
    @State private var noteText: String = ""
    @State private var showingDeleteAlert = false
    @State private var showError = false
    @State private var showNotes: Bool = false
    @State private var showingEditSheet = false
    // Comparison mode persists across exercise visits and app launches via
    // @AppStorage, so picking PB once makes it the default everywhere until
    // the user picks Last Session again. On fresh install the key is absent
    // and falls back to .lastSession.
    @AppStorage("exerciseComparisonMode") private var comparisonMode: ComparisonMode = .lastSession
    @State private var showChart: Bool = true  // Will be set in onAppear from setting
    @State private var pbFlashOpacity: Double = 0  // PB-flash border opacity
    @State private var previousPBSignature: PBSignature? = nil  // For detecting PB changes
    @State private var hasInitializedPBTracking: Bool = false  // Suppresses flash on first load

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

    @State private var cachedLastSetWeight: Double? = nil
    @State private var cachedAllSets: [ExerciseSet] = []
    @State private var cachedLastSessionDeltas: ExerciseDeltas = .empty
    @State private var cachedBestEverDeltas: ExerciseDeltas = .empty

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

    // Rest timer: most recent today set that hasn't captured rest yet
    private var restTimerSet: ExerciseSet? {
        guard let mostRecent = todaySets.first,
              mostRecent.restSeconds == nil else { return nil }
        return mostRecent
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

    init(exercise: Exercise, sourceGroup: ExerciseGroup? = nil) {
        self.exercise = exercise
        self.sourceGroup = sourceGroup
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
                    InlineProgressChart(sets: cachedAllSets)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Comparison card with built-in mode picker in its header
            Section {
                ComparisonMetricsCard(
                    comparisonMode: $comparisonMode,
                    sets: cachedAllSets,
                    todayDeltas: comparisonMode == .lastSession ? cachedLastSessionDeltas : cachedBestEverDeltas
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .id("comparisonButtons")

            // Today's Sets Section (unified card appearance)
            Section {
                // TODAY card header
                TodaySessionCard(
                    volume: todaysVolume,
                    durationMinutes: sessionDurationMinutes,
                    isWeightedExercise: isWeightedExercise,
                    totalReps: todaysTotalReps,
                    setCount: todaySets.count,
                    hasSetsBelow: !todaySets.isEmpty,
                    pbFlashOpacity: pbFlashOpacity
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
                            allSets: cachedAllSets,
                            showTimer: index == 0,
                            cardPosition: isLast ? .bottom : .middle,
                            isFirstInCard: index == 0,
                            isToday: true,
                            pbFlashOpacity: pbFlashOpacity
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
                            ChevronDisclosureButton(isExpanded: false)
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
        .alert("Something Went Wrong", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The operation couldn't be completed. Please try again.")
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
                    Image(systemName: "pencil.line")
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
                NavigationLink(value: HistoryDestination.history) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.effectiveTheme.textColor)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.effectiveTheme.textColor)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
                setToEdit: config.setToEdit,
                sourceGroup: sourceGroup
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExerciseView(exerciseToEdit: exercise)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .onAppear {
            showChart = themeManager.chartVisibleByDefault
            showNotes = false
            updateCachedData()
            previousTodaySetsCount = todaySets.count
        }
        .onChange(of: sets) { _, newSets in
            let oldCount = previousTodaySetsCount
            updateCachedData()
            // Auto-scroll on set add temporarily disabled — trialling no-scroll behaviour.
            // PB-flash detection lives in updateCachedData so it still fires on edits.
            // if todaySets.count > oldCount {
            //     Task {
            //         try? await Task.sleep(for: .milliseconds(150))
            //         withAnimation(.easeInOut(duration: 0.3)) {
            //             scrollProxy.scrollTo("comparisonButtons", anchor: .top)
            //         }
            //     }
            // }
            _ = oldCount
            previousTodaySetsCount = todaySets.count
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDataChanged)) { _ in
            // Refresh when set properties change (warm-up, set type, etc.)
            // @Query doesn't always detect property changes within objects
            updateCachedData()
        }
        } // ScrollViewReader
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
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
            .frame(width: 55, height: 55)
            .background(themeManager.effectiveTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .padding(.trailing, 20)
            .padding(.bottom, 41)
        }
        .overlay(alignment: .bottom) {
            if let timerSet = restTimerSet {
                FloatingRestTimerPill(set: timerSet)
                    .padding(.bottom, 33)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    // MARK: - PB Flash

    /// Briefly outline the today's-sets card in gold to celebrate a new PB:
    /// fade in over 1s, hold for 3s, fade out over 1s.
    private func triggerPBFlash() {
        withAnimation(.easeInOut(duration: 1.0)) {
            pbFlashOpacity = 1.0
        } completion: {
            Task {
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 1.0)) {
                    pbFlashOpacity = 0
                }
            }
        }
    }

    // MARK: - Data Management

    /// Update cached expensive calculations when sets change
    private func updateCachedData() {
        let allSets = Array(sets)
        cachedAllSets = allSets
        let (todaysData, historicData) = ExerciseDataGrouper.separateTodayFromHistoric(sets: allSets)
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

        // Last set weight for reps remaining hint (derive from already-computed todaySets)
        cachedLastSetWeight = todaySets.first?.weight

        // Delta indicators comparing today vs last session and best ever
        let lastIsRepsOnly = !cachedIsWeightedExercise
        cachedLastSessionDeltas = ExerciseDeltaCalculator.computeSingleExerciseDeltas(
            todaySets: todaysData,
            refMaxWeight: LastSessionCalculator.getLastSessionMaxWeight(from: allSets),
            refMaxReps: LastSessionCalculator.getLastSessionMaxReps(from: allSets),
            refTotalVolume: cachedLastSessionVolume,
            isRepsOnly: lastIsRepsOnly
        )

        // Build best-ever reference
        let bestMetrics = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)
        cachedBestEverDeltas = ExerciseDeltaCalculator.computeSingleExerciseDeltas(
            todaySets: todaysData,
            refMaxWeight: bestMetrics?.maxWeight ?? 0,
            refMaxReps: bestMetrics?.repsAtMaxWeight ?? 0,
            refTotalVolume: bestMetrics?.totalVolume ?? 0,
            isRepsOnly: bestMetrics?.isBodyweight ?? lastIsRepsOnly
        )

        // Flash the today's card if the PB signature changed AND the new PB is one of
        // today's sets. Signature = (id, weight, reps) so we catch every PB transition:
        //   - a new set is added that beats the PB (id changes)
        //   - a non-PB set is edited so it becomes the PB (id changes)
        //   - the current PB set itself is edited to a higher weight/reps (id same, w/r change)
        // Suppressed on first load via hasInitializedPBTracking.
        let currentPBSig = allSets.first(where: { $0.isPB }).map {
            PBSignature(id: $0.persistentModelID, weight: $0.weight, reps: $0.reps)
        }
        if hasInitializedPBTracking,
           let newSig = currentPBSig,
           newSig != previousPBSignature,
           todaysData.contains(where: { $0.persistentModelID == newSig.id }) {
            triggerPBFlash()
        }
        previousPBSignature = currentPBSig
        hasInitializedPBTracking = true
    }

    private func deleteSet(_ set: ExerciseSet) {
        withAnimation {
            do {
                try ExerciseSetService.deleteSet(set, context: context)
            } catch {
                showError = true
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
            showError = true
        }
    }

    /// Delete the exercise and all its associated sets (cascade delete)
    private func deleteExercise() {
        context.delete(exercise)
        do {
            try context.save()
            dismiss()
        } catch {
            showError = true
        }
    }

}
