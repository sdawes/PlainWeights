//
//  ExerciseDetailView.swift
//  PlainWeights
//
//  Exercise detail view with metrics and sets history
//

import SwiftUI
import SwiftData

// MARK: - Comparison Mode

enum ComparisonMode: String, CaseIterable {
    case lastSession = "Last Session"
    case allTimeBest = "All-Time Best"
}

// MARK: - Comparison Metrics Card

struct ComparisonMetricsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let comparisonMode: ComparisonMode
    let sets: [ExerciseSet]

    // Cached metrics - computed in init to prevent layout shift and improve scroll performance
    @State private var cachedTodaysSets: [ExerciseSet]
    @State private var cachedSetsExcludingToday: [ExerciseSet]
    @State private var cachedLastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double)?
    @State private var cachedBestMetrics: BestSessionCalculator.BestDayMetrics?
    @State private var cachedLastModeIndicators: ProgressTracker.LastModeIndicators?
    @State private var cachedBestModeIndicators: ProgressTracker.BestModeIndicators?

    init(comparisonMode: ComparisonMode, sets: [ExerciseSet]) {
        self.comparisonMode = comparisonMode
        self.sets = sets

        // Pre-compute all metrics during init
        let computed = Self.computeAllMetrics(sets: sets, comparisonMode: comparisonMode)
        _cachedTodaysSets = State(initialValue: computed.todaysSets)
        _cachedSetsExcludingToday = State(initialValue: computed.setsExcludingToday)
        _cachedLastSessionMetrics = State(initialValue: computed.lastSessionMetrics)
        _cachedBestMetrics = State(initialValue: computed.bestMetrics)
        _cachedLastModeIndicators = State(initialValue: computed.lastModeIndicators)
        _cachedBestModeIndicators = State(initialValue: computed.bestModeIndicators)
    }

    // MARK: - Static Computation

    private struct ComputedMetrics {
        let todaysSets: [ExerciseSet]
        let setsExcludingToday: [ExerciseSet]
        let lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double)?
        let bestMetrics: BestSessionCalculator.BestDayMetrics?
        let lastModeIndicators: ProgressTracker.LastModeIndicators?
        let bestModeIndicators: ProgressTracker.BestModeIndicators?
    }

    private static func computeAllMetrics(sets: [ExerciseSet], comparisonMode: ComparisonMode) -> ComputedMetrics {
        // Today's sets
        let todaysSets = TodaySessionCalculator.getTodaysSets(from: sets)

        // Sets excluding today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let setsExcludingToday = sets.filter { calendar.startOfDay(for: $0.timestamp) < today }

        // Last session metrics
        let progressState = ProgressTracker.createProgressState(from: sets)
        let lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double)?
        if let lastInfo = progressState.lastCompletedDayInfo {
            lastSessionMetrics = (lastInfo.date, lastInfo.maxWeight, lastInfo.maxWeightReps, lastInfo.volume)
        } else {
            lastSessionMetrics = nil
        }

        // Best metrics
        let bestMetrics = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)

        // Last mode indicators
        var lastModeIndicators: ProgressTracker.LastModeIndicators? = nil
        if comparisonMode == .lastSession, let lastMetrics = lastSessionMetrics, !todaysSets.isEmpty {
            let todaysMaxWeight = TodaySessionCalculator.getTodaysMaxWeight(from: sets)
            let todaysMaxReps = TodaySessionCalculator.getTodaysMaxReps(from: sets)
            let todaysVolume = TodaySessionCalculator.getTodaysVolume(from: sets)
            let exerciseType = ExerciseMetricsType.determine(from: sets)

            lastModeIndicators = ProgressTracker.LastModeIndicators.compare(
                todaysMaxWeight: todaysMaxWeight,
                todaysMaxReps: todaysMaxReps,
                todaysVolume: todaysVolume,
                lastSessionMaxWeight: lastMetrics.maxWeight,
                lastSessionMaxReps: lastMetrics.maxReps,
                lastSessionVolume: lastMetrics.totalVolume,
                exerciseType: exerciseType
            )
        }

        // Best mode indicators
        var bestModeIndicators: ProgressTracker.BestModeIndicators? = nil
        if comparisonMode == .allTimeBest {
            bestModeIndicators = ProgressTracker.calculateBestModeIndicators(
                todaySets: todaysSets,
                bestMetrics: bestMetrics
            )
        }

        return ComputedMetrics(
            todaysSets: todaysSets,
            setsExcludingToday: setsExcludingToday,
            lastSessionMetrics: lastSessionMetrics,
            bestMetrics: bestMetrics,
            lastModeIndicators: lastModeIndicators,
            bestModeIndicators: bestModeIndicators
        )
    }

    private func updateCache() {
        let computed = Self.computeAllMetrics(sets: sets, comparisonMode: comparisonMode)
        cachedTodaysSets = computed.todaysSets
        cachedSetsExcludingToday = computed.setsExcludingToday
        cachedLastSessionMetrics = computed.lastSessionMetrics
        cachedBestMetrics = computed.bestMetrics
        cachedLastModeIndicators = computed.lastModeIndicators
        cachedBestModeIndicators = computed.bestModeIndicators
    }

    // MARK: - Simple Getters for Cached Values

    private var todaysSets: [ExerciseSet] { cachedTodaysSets }
    private var setsExcludingToday: [ExerciseSet] { cachedSetsExcludingToday }
    private var lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double)? { cachedLastSessionMetrics }
    private var bestMetrics: BestSessionCalculator.BestDayMetrics? { cachedBestMetrics }
    private var lastModeIndicators: ProgressTracker.LastModeIndicators? { cachedLastModeIndicators }
    private var bestModeIndicators: ProgressTracker.BestModeIndicators? { cachedBestModeIndicators }

    // Current metrics based on mode (derived from cached values - cheap)
    private var currentMetrics: (date: Date?, maxWeight: Double, maxReps: Int, totalVolume: Double)? {
        switch comparisonMode {
        case .lastSession:
            guard let last = lastSessionMetrics else { return nil }
            return (last.date, last.maxWeight, last.maxReps, last.totalVolume)
        case .allTimeBest:
            guard let best = bestMetrics else { return nil }
            return (best.date, best.maxWeight, best.repsAtMaxWeight, best.totalVolume)
        }
    }

    // Header text with date (derived - cheap)
    private var headerText: String {
        guard let metrics = currentMetrics, let date = metrics.date else {
            return comparisonMode == .lastSession ? "Last Session" : "All-Time Best"
        }
        let dateStr = date.formatted(.dateTime.month(.abbreviated).day())
        return comparisonMode == .lastSession ? "Last Session (\(dateStr))" : "All-Time Best (\(dateStr))"
    }

    // Delta values for comparison row (derived from cached indicators - cheap)
    private var weightDirection: ProgressTracker.PRDirection? {
        if let indicators = lastModeIndicators { return indicators.weightDirection }
        if let indicators = bestModeIndicators { return indicators.weightDirection }
        return nil
    }

    private var weightDelta: Double? {
        if let indicators = lastModeIndicators { return indicators.weightImprovement }
        if let indicators = bestModeIndicators { return indicators.weightImprovement }
        return nil
    }

    private var repsDirection: ProgressTracker.PRDirection? {
        if let indicators = lastModeIndicators { return indicators.repsDirection }
        if let indicators = bestModeIndicators { return indicators.repsDirection }
        return nil
    }

    private var repsDelta: Double? {
        if let indicators = lastModeIndicators { return Double(indicators.repsImprovement) }
        if let indicators = bestModeIndicators { return Double(indicators.repsImprovement) }
        return nil
    }

    private var totalDirection: ProgressTracker.PRDirection? {
        if let indicators = lastModeIndicators { return indicators.volumeDirection }
        if let indicators = bestModeIndicators { return indicators.volumeDirection }
        return nil
    }

    private var totalDelta: Double? {
        if let indicators = lastModeIndicators { return indicators.volumeImprovement }
        if let indicators = bestModeIndicators { return indicators.volumeImprovement }
        return nil
    }

    // Check if today has sets (derived - cheap)
    private var hasTodaySets: Bool {
        !todaysSets.isEmpty
    }

    // Check if today has working sets (derived - cheap)
    private var hasWorkingSets: Bool {
        todaysSets.contains { !$0.isWarmUp && !$0.isBonus }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Separate header section with muted background
            Text(headerText)
                .font(themeManager.currentTheme.interFont(size: 13, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(themeManager.currentTheme.muted.opacity(0.3))

            // Divider below header
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            if let metrics = currentMetrics {
                // Metrics row (no deltas here)
                HStack(spacing: 0) {
                    metricColumn(
                        label: comparisonMode == .lastSession ? "Max Weight" : "Weight",
                        value: Formatters.formatWeight(metrics.maxWeight)
                    )
                    metricColumn(
                        label: "Reps",
                        value: "\(metrics.maxReps)"
                    )
                    metricColumn(
                        label: "Total",
                        value: Formatters.formatVolume(metrics.totalVolume)
                    )
                }
                .padding(.vertical, 12)

                // Divider above comparison row
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(height: 1)

                // Comparison row - colored background cells (show '-' when no working sets)
                HStack(spacing: 1) {
                    comparisonCell(direction: hasWorkingSets ? weightDirection : nil, value: hasWorkingSets ? weightDelta : nil)
                    comparisonCell(direction: hasWorkingSets ? repsDirection : nil, value: hasWorkingSets ? repsDelta : nil, isReps: true)
                    comparisonCell(direction: hasWorkingSets ? totalDirection : nil, value: hasWorkingSets ? totalDelta : nil)
                }
                .background(themeManager.currentTheme.borderColor)
            } else {
                // Empty state
                Text("No data yet")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: comparisonMode)
        .onChange(of: sets) { _, _ in
            updateCache()
        }
        .onChange(of: comparisonMode) { _, _ in
            updateCache()
        }
    }

    // MARK: - Metric Column Helper

    @ViewBuilder
    private func metricColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            Text(value)
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .foregroundStyle(themeManager.currentTheme.primaryText)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Comparison Cell Helper

    @ViewBuilder
    private func comparisonCell(direction: ProgressTracker.PRDirection?, value: Double?, isReps: Bool = false) -> some View {
        Group {
            if hasTodaySets, let direction = direction, let value = value, direction != .same {
                // Up or down - colored background with white text
                let displayValue = isReps ? "\(Int(value))" : Formatters.formatWeight(value)
                let prefix = direction == .up ? "+" : ""
                HStack {
                    Text("\(prefix)\(displayValue)")
                        .font(themeManager.currentTheme.dataFont(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(direction == .up ? Color.green : Color.red)
            } else {
                // No data - show dash
                HStack {
                    Text("—")
                        .font(themeManager.currentTheme.interFont(size: 14))
                        .foregroundStyle(themeManager.currentTheme.mutedForeground.opacity(0.3))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(themeManager.currentTheme.cardBackgroundColor)
            }
        }
    }
}

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

    // Active timer set (most recent set that is still timing)
    private var activeTimerSet: ExerciseSet? {
        guard let mostRecent = todaySets.first,
              mostRecent.restSeconds == nil,
              Date().timeIntervalSince(mostRecent.timestamp) < 180 else {
            return nil
        }
        return mostRecent
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
                        .font(themeManager.currentTheme.title2Font)
                        .foregroundStyle(themeManager.currentTheme.primaryText)
                    if !exercise.tags.isEmpty {
                        TagPillsRow(tags: exercise.tags)
                    }
                }
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id("top")
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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

            // Comparison mode toggle
            Section {
                HStack(spacing: 4) {
                    ForEach(ComparisonMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                comparisonMode = mode
                            }
                        } label: {
                            Text(mode.rawValue)
                                .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                                .foregroundStyle(
                                    comparisonMode == mode
                                        ? themeManager.currentTheme.primaryText
                                        : themeManager.currentTheme.mutedForeground
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    comparisonMode == mode
                                        ? themeManager.currentTheme.background
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(
                                    color: comparisonMode == mode ? .black.opacity(0.08) : .clear,
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.muted)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                        .font(themeManager.currentTheme.interFont(size: 14, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Historic sets: one Section per day (unified card appearance)
            ForEach(historicDayGroups.indices, id: \.self) { groupIndex in
                let dayGroup = historicDayGroups[groupIndex]
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
                    .foregroundStyle(themeManager.currentTheme.background)
            }
            .frame(width: 48, height: 48)
            .background(themeManager.currentTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .overlay(alignment: .bottom) {
            if let activeSet = activeTimerSet {
                FloatingRestTimer(setTimestamp: activeSet.timestamp)
                    .offset(y: 6)  // Center aligned with FAB (48pt button + 20pt padding)
                    .transition(.scale.combined(with: .opacity))
            }
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
                            ? themeManager.currentTheme.accent
                            : themeManager.currentTheme.textColor)
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
                            ? themeManager.currentTheme.accent
                            : themeManager.currentTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.currentTheme.textColor)
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
        let workingSets = todaysData.filter { !$0.isWarmUp && !$0.isBonus }
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
