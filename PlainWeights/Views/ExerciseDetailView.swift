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

    // Sets excluding today (for metrics calculation)
    private var setsExcludingToday: [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) < today }
    }

    // Today's sets
    private var todaysSets: [ExerciseSet] {
        TodaySessionCalculator.getTodaysSets(from: sets)
    }

    // Last session metrics
    private var lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double)? {
        let progressState = ProgressTracker.createProgressState(from: sets)
        guard let lastInfo = progressState.lastCompletedDayInfo else { return nil }
        return (lastInfo.date, lastInfo.maxWeight, lastInfo.maxWeightReps, lastInfo.volume)
    }

    // Best ever metrics
    private var bestMetrics: BestSessionCalculator.BestDayMetrics? {
        BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)
    }

    // Current metrics based on mode
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

    // Progress indicators for Last Session mode
    private var lastModeIndicators: ProgressTracker.LastModeIndicators? {
        guard comparisonMode == .lastSession,
              let lastMetrics = lastSessionMetrics,
              !todaysSets.isEmpty else { return nil }

        let todaysMaxWeight = TodaySessionCalculator.getTodaysMaxWeight(from: sets)
        let todaysMaxReps = TodaySessionCalculator.getTodaysMaxReps(from: sets)
        let todaysVolume = TodaySessionCalculator.getTodaysVolume(from: sets)
        let exerciseType = ExerciseMetricsType.determine(from: sets)

        return ProgressTracker.LastModeIndicators.compare(
            todaysMaxWeight: todaysMaxWeight,
            todaysMaxReps: todaysMaxReps,
            todaysVolume: todaysVolume,
            lastSessionMaxWeight: lastMetrics.maxWeight,
            lastSessionMaxReps: lastMetrics.maxReps,
            lastSessionVolume: lastMetrics.totalVolume,
            exerciseType: exerciseType
        )
    }

    // Progress indicators for Best mode
    private var bestModeIndicators: ProgressTracker.BestModeIndicators? {
        guard comparisonMode == .allTimeBest else { return nil }
        return ProgressTracker.calculateBestModeIndicators(
            todaySets: todaysSets,
            bestMetrics: bestMetrics
        )
    }

    // Header text with date
    private var headerText: String {
        guard let metrics = currentMetrics, let date = metrics.date else {
            return comparisonMode == .lastSession ? "Last Session" : "All-Time Best"
        }
        let dateStr = date.formatted(.dateTime.month(.abbreviated).day())
        return comparisonMode == .lastSession ? "Last Session (\(dateStr))" : "All-Time Best (\(dateStr))"
    }

    // Delta values for comparison row
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

    // Check if today has sets (to show comparison row)
    private var hasTodaySets: Bool {
        !todaysSets.isEmpty
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

                // Comparison row - colored background cells (left-aligned)
                HStack(spacing: 1) {
                    comparisonCell(direction: weightDirection, value: weightDelta)
                    comparisonCell(direction: repsDirection, value: repsDelta, isReps: true)
                    comparisonCell(direction: totalDirection, value: totalDelta)
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
                // Colored background with white text - LEFT ALIGNED
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
                // No change or no data - show dash - LEFT ALIGNED
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
    @State private var showingNotesSheet = false
    @State private var showingEditSheet = false
    @State private var comparisonMode: ComparisonMode = .lastSession
    @State private var showChart: Bool = false
    @State private var showPBConfetti: Bool = false

    // Cached data for performance
    @State private var todaySets: [ExerciseSet] = []
    @State private var historicDayGroups: [ExerciseDataGrouper.DayGroup] = []

    // Today's volume for running total
    private var todaysVolume: Double {
        TodaySessionCalculator.getTodaysVolume(from: Array(sets))
    }

    // Today's cumulative reps (sum of all sets today)
    private var todaysTotalReps: Int {
        TodaySessionCalculator.getTodaysTotalReps(from: Array(sets))
    }

    // Session duration in minutes
    private var sessionDurationMinutes: Int? {
        TodaySessionCalculator.getSessionDurationMinutes(from: Array(sets))
    }

    // Check if this is a weighted exercise (any working set has weight > 0)
    private var isWeightedExercise: Bool {
        let workingSets = todaySets.filter { !$0.isWarmUp && !$0.isBonus }
        return workingSets.contains { $0.weight > 0 }
    }

    // Last session volume (baseline) - returns 0 if no data
    private var lastSessionVolume: Double {
        LastSessionCalculator.getLastSessionVolume(from: Array(sets))
    }

    // Best ever volume (upper target) - exclude today
    private var bestSessionVolume: Double {
        let setsExcludingToday = Array(sets).filter {
            Calendar.current.startOfDay(for: $0.timestamp) < Calendar.current.startOfDay(for: Date())
        }
        return BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)?.totalVolume ?? 0
    }

    // Percentage of baseline (treat 0 as 1 to always show percentage)
    private var percentOfBaseline: Int {
        let divisor = max(lastSessionVolume, 1)
        return Int(round((todaysVolume / divisor) * 100))
    }

    // Percentage of upper target (treat 0 as 1 to always show percentage)
    private var percentOfTarget: Int {
        let divisor = max(bestSessionVolume, 1)
        return Int(round((todaysVolume / divisor) * 100))
    }

    // Color for baseline comparison
    private var baselineColor: Color {
        .primary
    }

    // Color for target comparison
    private var targetColor: Color {
        .primary
    }

    // Comparison volume based on selected mode
    private var comparisonVolume: Double {
        comparisonMode == .lastSession ? lastSessionVolume : bestSessionVolume
    }

    // Label for progress bar based on selected mode
    private var comparisonLabel: String {
        comparisonMode == .lastSession ? "Last" : "Best"
    }

    // Calculate session duration in minutes for a set of sets
    private func calculateSessionDuration(for sets: [ExerciseSet]) -> Int? {
        guard sets.count >= 2 else { return nil }
        let sortedSets = sets.sorted { $0.timestamp < $1.timestamp }
        guard let first = sortedSets.first, let last = sortedSets.last else { return nil }
        let duration = last.timestamp.timeIntervalSince(first.timestamp)
        let minutes = Int(duration / 60)
        return minutes > 0 ? minutes : nil
    }

    // MARK: - Section Headers (for flattened List structure)

    /// Header for Today's Sets section - prominent styling
    @ViewBuilder
    private var todaysSetsHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("TODAY")
                    .font(themeManager.currentTheme.interFont(size: 13, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.accent)
                    .tracking(1.2)
                Spacer()
                if let mins = sessionDurationMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("\(mins) min")
                            .font(themeManager.currentTheme.dataFont(size: 13, weight: .medium))
                    }
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
            }
            if !todaySets.isEmpty {
                HStack(spacing: 8) {
                    if isWeightedExercise {
                        HStack(spacing: 4) {
                            Text(Formatters.formatVolume(todaysVolume))
                                .font(themeManager.currentTheme.dataFont(size: 15, weight: .semibold))
                            Text("kg volume")
                                .font(themeManager.currentTheme.interFont(size: 13))
                        }
                    } else {
                        HStack(spacing: 4) {
                            Text("\(todaysTotalReps)")
                                .font(themeManager.currentTheme.dataFont(size: 15, weight: .semibold))
                            Text("total reps")
                                .font(themeManager.currentTheme.interFont(size: 13))
                        }
                    }
                    Text("•")
                        .font(themeManager.currentTheme.interFont(size: 13))
                    Text("\(todaySets.count) sets")
                        .font(themeManager.currentTheme.interFont(size: 13))
                }
                .foregroundStyle(themeManager.currentTheme.secondaryText)
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Header for historic day sections - subtle styling
    @ViewBuilder
    private func historicDayHeader(dayGroup: ExerciseDataGrouper.DayGroup) -> some View {
        let isWeightedDay = dayGroup.sets.filter { !$0.isWarmUp && !$0.isBonus }.contains { $0.weight > 0 }
        let volume = ExerciseVolumeCalculator.calculateVolume(for: dayGroup.sets)
        let totalReps = dayGroup.sets.reduce(0) { $0 + $1.reps }

        HStack(alignment: .firstTextBaseline) {
            Text(Formatters.formatFullDayHeader(dayGroup.date))
                .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.secondaryText)

            Spacer()

            HStack(spacing: 6) {
                if isWeightedDay {
                    Text("\(Formatters.formatVolume(volume)) kg")
                        .font(themeManager.currentTheme.dataFont(size: 13))
                } else {
                    Text("\(totalReps) reps")
                        .font(themeManager.currentTheme.dataFont(size: 13))
                }

                if let duration = calculateSessionDuration(for: dayGroup.sets) {
                    Text("•")
                    Text("\(duration) min")
                        .font(themeManager.currentTheme.dataFont(size: 13))
                }
            }
            .font(themeManager.currentTheme.interFont(size: 13))
            .foregroundStyle(themeManager.currentTheme.tertiaryText)
        }
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
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
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Inline Progress Chart (toggled) - above segmentation picker
            if showChart && !sets.isEmpty {
                Section {
                    InlineProgressChart(sets: Array(sets))
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
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
                .padding(.leading, 8)
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.muted)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Comparison metrics card (responds to toggle)
            Section {
                ComparisonMetricsCard(
                    comparisonMode: comparisonMode,
                    sets: Array(sets)
                )
                .padding(.leading, 8)
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            // Today's Sets Section (flat - no nested List)
            Section {
                // Header as a row for consistent margins
                todaysSetsHeader
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                if todaySets.isEmpty {
                    Text("No sets logged yet")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.leading, 8)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    // Progress bar if applicable
                    if isWeightedExercise && comparisonVolume > 0 {
                        VolumeProgressBar(
                            currentVolume: todaysVolume,
                            targetVolume: comparisonVolume,
                            targetLabel: comparisonLabel
                        )
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                    }

                    // Set rows directly in outer List
                    ForEach(todaySets.indices, id: \.self) { index in
                        let set = todaySets[index]
                        SetRowView(
                            set: set,
                            setNumber: todaySets.count - index,
                            isFirst: index == 0,
                            isLast: index == todaySets.count - 1,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) },
                            allSets: (set.isWarmUp || set.isBonus) ? nil : Array(sets),
                            showTimer: index == 0
                        )
                    }
                }
            }

            // History label (only show if there are historic days)
            if !historicDayGroups.isEmpty {
                Section {
                    Text("HISTORY")
                        .font(themeManager.currentTheme.interFont(size: 12, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                        .tracking(1.0)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }

            // Historic sets: one Section per day (flat - no nested Lists)
            ForEach(historicDayGroups.indices, id: \.self) { groupIndex in
                let dayGroup = historicDayGroups[groupIndex]
                Section {
                    // Header as a row for consistent margins
                    historicDayHeader(dayGroup: dayGroup)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    ForEach(dayGroup.sets.indices, id: \.self) { index in
                        let set = dayGroup.sets[index]
                        SetRowView(
                            set: set,
                            setNumber: dayGroup.sets.count - index,
                            isFirst: index == 0,
                            isLast: index == dayGroup.sets.count - 1,
                            onTap: { addSetConfig = .edit(set: set, exercise: exercise) },
                            onDelete: { deleteSet(set) }
                        )
                    }
                }
            }

        }
        .listStyle(.plain)
        .listSectionSpacing(16)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showChart.toggle()
                    }
                }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(showChart
                            ? themeManager.currentTheme.accent
                            : themeManager.currentTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNotesSheet = true }) {
                    Image(systemName: "doc.text")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.currentTheme.textColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.callout)
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
        .toolbarBackground(themeManager.currentTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 0.5)
        }
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
        .sheet(isPresented: $showingNotesSheet) {
            ExerciseNotesSheet(
                exercise: exercise,
                noteText: $noteText,
                onSave: updateNote
            )
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExerciseView(exerciseToEdit: exercise)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .onAppear {
            updateCachedData()
        }
        .onChange(of: sets) { _, _ in
            updateCachedData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pbAchieved)) { _ in
            showPBConfetti = true
        }
        .overlay {
            PBCelebrationOverlay(isShowing: $showPBConfetti)
        }
    }

    // MARK: - Data Management

    /// Update cached expensive calculations when sets change
    private func updateCachedData() {
        let (todaysData, historicData) = ExerciseDataGrouper.separateTodayFromHistoric(sets: sets)
        todaySets = todaysData
        historicDayGroups = historicData
    }

    private func deleteSet(_ set: ExerciseSet) {
        do {
            try ExerciseSetService.deleteSet(set, context: context)
        } catch {
            print("Error deleting set: \(error)")
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
