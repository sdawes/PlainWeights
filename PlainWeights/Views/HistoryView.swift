//
//  HistoryView.swift
//  PlainWeights
//
//  History view showing workout stats and exercises
//

import SwiftUI
import SwiftData

enum HistoryTimePeriod: String, CaseIterable {
    case lastSession = "Last"
    case week = "Week"          // Rolling 7 days
    case month = "Month"        // Rolling 30 days
    case year = "Year"          // Rolling 365 days
}

enum HistoryViewTab: String, CaseIterable {
    case summary = "Summary"
    case muscle = "Muscle"
    case exercises = "Exercises"
}

/// Aggregate metrics for a time period summary
private struct PeriodMetrics {
    let dayCount: Int           // Unique workout days
    let exerciseCount: Int      // Unique exercises worked
    let setCount: Int           // Working sets only
    let totalVolume: Double     // Sum of weight × reps
    let pbCount: Int            // Sets where isPB == true
    let avgRestSeconds: Double? // Average rest time across sets with rest data

    static let empty = PeriodMetrics(dayCount: 0, exerciseCount: 0, setCount: 0, totalVolume: 0, pbCount: 0, avgRestSeconds: nil)
}

/// Lightweight exercise summary for period view
private struct PeriodExerciseSummary: Identifiable {
    let id: PersistentIdentifier
    let name: String
    let exercise: Exercise
    let hasPB: Bool
    let deltas: ExerciseDeltas?

    init(from workoutExercise: ExerciseDataGrouper.WorkoutExercise, deltas: ExerciseDeltas? = nil) {
        self.id = workoutExercise.id
        self.name = workoutExercise.exercise.name
        self.exercise = workoutExercise.exercise
        self.hasPB = workoutExercise.sets.workingSets.contains { $0.isPB }
        self.deltas = deltas
    }
}

/// Day summary for period view
private struct PeriodDaySummary: Identifiable {
    let id: Date
    let date: Date
    let exercises: [PeriodExerciseSummary]

    init(from workoutDay: ExerciseDataGrouper.WorkoutDay, deltas: [PersistentIdentifier: ExerciseDeltas] = [:]) {
        self.id = workoutDay.date
        self.date = workoutDay.date
        self.exercises = workoutDay.exercises.map { exercise in
            PeriodExerciseSummary(from: exercise, deltas: deltas[exercise.exercise.persistentModelID])
        }
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Query private var allSets: [ExerciseSet]
    @Binding var navigationPath: NavigationPath
    // Selected time period
    @State private var selectedPeriod: HistoryTimePeriod = .lastSession

    // Cached display day - prevents expensive recomputation on every render
    @State private var cachedDisplayDay: ExerciseDataGrouper.WorkoutDay?

    // Cached period metrics for summary view (Week/Month/Year/12 Mo)
    @State private var cachedPeriodMetrics: PeriodMetrics = .empty

    // Cached workout days for period summary exercise list
    @State private var cachedPeriodDays: [PeriodDaySummary] = []

    // Pagination for period summary exercise list
    @State private var visiblePeriodDaysCount: Int = 5

    // Cached tag distribution for period summary
    @State private var cachedPeriodTagDistribution: [(tag: String, percentage: Double)] = []

    // Cached exercise deltas for last session (keyed by exercise persistent ID)
    @State private var cachedExerciseDeltas: [PersistentIdentifier: ExerciseDeltas] = [:]
    @State private var cachedExercisePBFlags: [PersistentIdentifier: Bool] = [:]

    // Selected content view tab (Summary / Muscle / Exercises)
    @State private var selectedView: HistoryViewTab = .summary

    // Delta legend popover visibility
    @State private var showingDeltaInfo = false

    private var hasTodaySets: Bool {
        allSets.contains { Calendar.current.isDateInToday($0.timestamp) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Time period picker
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(HistoryTimePeriod.allCases, id: \.self) { period in
                    Text(period == .lastSession && hasTodaySets ? "Today" : period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // View tab bar (Summary / Muscle / Exercises)
            underlinedTabBar

            // Content for the selected tab
            Group {
                switch selectedView {
                case .summary: summaryTabContent
                case .muscle: muscleTabContent
                case .exercises: exercisesTabContent
                }
            }
        }
        .background(AnimatedGradientBackground())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .onAppear {
            updateCaches()
        }
        .onChange(of: allSets.count) { _, _ in
            // Refresh when sets are added/removed
            updateCaches()
        }
        .onChange(of: selectedPeriod) { _, _ in
            visiblePeriodDaysCount = 5  // Reset pagination when switching periods
            updateCaches()
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDataChanged)) { _ in
            // Refresh caches when sets are edited from any view
            updateCaches()
        }
    }

    // MARK: - View Tab Bar

    private var underlinedTabBar: some View {
        HStack(spacing: 0) {
            ForEach(HistoryViewTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedView = tab
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(themeManager.effectiveTheme.interFont(
                                size: 13,
                                weight: selectedView == tab ? .semibold : .medium
                            ))
                            .foregroundStyle(
                                selectedView == tab
                                    ? themeManager.effectiveTheme.primaryText
                                    : themeManager.effectiveTheme.mutedForeground
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)

                        Rectangle()
                            .fill(selectedView == tab
                                ? themeManager.effectiveTheme.primaryText
                                : themeManager.effectiveTheme.dividerColor)
                            .frame(height: 2)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var summaryTabContent: some View {
        ScrollView {
            if selectedPeriod == .lastSession {
                if let day = cachedDisplayDay {
                    sessionInfoCard(for: day)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                } else {
                    emptyState("Complete your first workout to see a summary here.")
                }
            } else {
                if cachedPeriodMetrics.dayCount > 0 {
                    periodSummaryCard
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                } else {
                    emptyState("No workouts recorded for \(periodDescription.lowercased()).")
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var muscleTabContent: some View {
        let tagDist = currentTagDistribution
        ScrollView {
            if !tagDist.isEmpty {
                TagDistributionBar(data: tagDist)
                    .frame(maxWidth: .infinity)
                    .background(themeManager.effectiveTheme.cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            } else {
                emptyState("No muscle breakdown data available.")
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var exercisesTabContent: some View {
        if selectedPeriod == .lastSession {
            if let day = cachedDisplayDay {
                List {
                    Section { deltaLegendHeader }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Section {
                        VStack(spacing: 0) {
                            ForEach(day.exercises.enumerated(), id: \.element.id) { index, exercise in
                                let hasPB = cachedExercisePBFlags[exercise.exercise.persistentModelID] ?? false
                                let deltas = cachedExerciseDeltas[exercise.exercise.persistentModelID]
                                Button {
                                    var newPath = NavigationPath()
                                    newPath.append(exercise.exercise)
                                    navigationPath = newPath
                                } label: {
                                    periodExerciseRow(number: index + 1, name: exercise.exercise.name, hasPB: hasPB, isFirst: index == 0, deltas: deltas)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(themeManager.effectiveTheme.cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .id("lastSession-\(themeManager.systemColorScheme)")
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 4, for: .scrollContent)
            } else {
                emptyState("Complete your first workout to see exercises here.")
            }
        } else {
            if cachedPeriodMetrics.dayCount > 0 {
                List {
                    let visibleDays = Array(cachedPeriodDays.prefix(visiblePeriodDaysCount))
                    let hasMoreDays = cachedPeriodDays.count > visiblePeriodDaysCount
                    let remainingCount = cachedPeriodDays.count - visiblePeriodDaysCount

                    Section { deltaLegendHeader }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    ForEach(visibleDays) { daySummary in
                        Section {
                            periodDayHeader(for: daySummary.date)

                            VStack(spacing: 0) {
                                ForEach(daySummary.exercises.enumerated(), id: \.element.id) { index, exercise in
                                    Button {
                                        var newPath = NavigationPath()
                                        newPath.append(exercise.exercise)
                                        navigationPath = newPath
                                    } label: {
                                        periodExerciseRow(number: index + 1, name: exercise.name, hasPB: exercise.hasPB, isFirst: index == 0, deltas: exercise.deltas)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .background(themeManager.effectiveTheme.cardBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }

                    if hasMoreDays {
                        Section {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    visiblePeriodDaysCount += 10
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("See \(remainingCount) more days")
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
                }
                .id("\(selectedPeriod.rawValue)-\(themeManager.systemColorScheme)")
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 4, for: .scrollContent)
            } else {
                emptyState("No workouts recorded for \(periodDescription.lowercased()).")
            }
        }
    }

    @ViewBuilder
    private var deltaLegendHeader: some View {
        HStack(spacing: 0) {
            Button {
                showingDeltaInfo = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                    Text("Legend")
                        .font(themeManager.effectiveTheme.interFont(size: 11, weight: .medium))
                }
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingDeltaInfo) {
                DeltaInfoPopover()
            }

            Spacer()

            HStack(spacing: 0) {
                Text("W").frame(width: 20)
                Text("R").frame(width: 20)
                Text("V").frame(width: 20)
            }
            .font(themeManager.effectiveTheme.interFont(size: 10, weight: .semibold))
            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
        }
        .padding(.horizontal, 12)
    }

    private var currentTagDistribution: [(tag: String, percentage: Double)] {
        if selectedPeriod == .lastSession {
            guard let day = cachedDisplayDay else { return [] }
            return ExerciseService.tagDistribution(from: day.exercises.flatMap { $0.sets })
        }
        return cachedPeriodTagDistribution
    }

    @ViewBuilder
    private func emptyState(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(themeManager.effectiveTheme.subheadlineFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            Spacer()
        }
    }

    @ViewBuilder
    private var periodSummaryCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                Text(periodDescription)
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(periodDateRange)
                    .font(themeManager.effectiveTheme.interFont(size: 12, weight: .regular).italic())
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(themeManager.effectiveTheme.muted.opacity(0.3))

            Rectangle()
                .fill(themeManager.effectiveTheme.dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 5)

            scoreboardGrid(
                workoutDays: cachedPeriodMetrics.dayCount,
                exercises: cachedPeriodMetrics.exerciseCount,
                sets: cachedPeriodMetrics.setCount,
                volume: cachedPeriodMetrics.totalVolume,
                pbs: cachedPeriodMetrics.pbCount,
                avgRest: cachedPeriodMetrics.avgRestSeconds
            )

            if selectedPeriod != .lastSession {
                Rectangle()
                    .fill(themeManager.effectiveTheme.dividerColor)
                    .frame(height: 1)
                    .padding(.horizontal, 5)
                workoutFrequencyBar
            }
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// Description of the current time period
    /// Total days in the selected period
    private var totalDaysInPeriod: Int {
        switch selectedPeriod {
        case .lastSession: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }

    /// Progress bar showing workout days as a percentage of the period
    private var workoutFrequencyBar: some View {
        let days = cachedPeriodMetrics.dayCount
        let total = totalDaysInPeriod
        let percentage = min(Double(days) / Double(total), 1.0)

        return VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.effectiveTheme.muted)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.effectiveTheme.chartColor1)
                        .frame(width: CGFloat(percentage) * geometry.size.width, height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Trained \(days) of \(total) available days")
                    .font(themeManager.effectiveTheme.interFont(size: 11))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Spacer()
                Text("\(Int(percentage * 100))%")
                    .font(themeManager.effectiveTheme.dataFont(size: 11, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var periodDescription: String {
        switch selectedPeriod {
        case .lastSession:
            return "" // Not used for last session
        case .week:
            return "Past 7 Days"
        case .month:
            return "Past 30 Days"
        case .year:
            return "Past 365 Days"
        }
    }

    /// Date range string for rolling period headers
    private var periodDateRange: String {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .lastSession:
            return ""
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let startStr = start.formatted(.dateTime.weekday(.abbreviated).day())
            let endStr = now.formatted(.dateTime.weekday(.abbreviated).day())
            return "\(startStr) – \(endStr)"
        case .month:
            let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            let startStr = start.formatted(.dateTime.day().month(.abbreviated))
            let endStr = now.formatted(.dateTime.day().month(.abbreviated))
            return "\(startStr) – \(endStr)"
        case .year:
            let start = calendar.date(byAdding: .day, value: -365, to: now) ?? now
            let startStr = start.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
            let endStr = now.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
            return "\(startStr) – \(endStr)"
        }
    }

    @ViewBuilder
    private func periodDayHeader(for date: Date) -> some View {
        HStack {
            Text(date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.8)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
        .padding(.leading, 4)
    }

    @ViewBuilder
    private func periodExerciseRow(number: Int, name: String, hasPB: Bool, isFirst: Bool, deltas: ExerciseDeltas? = nil) -> some View {
        VStack(spacing: 0) {
            // Divider at top (not for first row)
            if !isFirst {
                Rectangle()
                    .fill(themeManager.effectiveTheme.dividerColor)
                    .frame(height: 1)
                    .padding(.horizontal, 5)
            }

            HStack(alignment: .top, spacing: 0) {
                // Column 1: Exercise number
                Text("\(number)")
                    .font(themeManager.effectiveTheme.dataFont(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .frame(width: 28, alignment: .center)

                // Column 2: PB star
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(hasPB ? themeManager.effectiveTheme.pbColor : .clear)
                    .frame(width: 20, alignment: .leading)
                    .offset(x: -3)

                // Column 3: Exercise name
                Text(name)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)

                Spacer()

                // Column 4: Delta indicators
                if let deltas = deltas {
                    DeltaIndicatorsView(deltas: deltas)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
        }
    }

    // MARK: - Cache Management

    /// Update all cached values - called on appear and when data/period changes
    private func updateCaches() {
        if selectedPeriod == .lastSession {
            // Compute display day for detailed view
            let day = Self.computeDisplayDay(from: allSets)
            cachedDisplayDay = day

            // Compute exercise deltas for summary card
            if let day = day {
                cachedExerciseDeltas = ExerciseDeltaCalculator.computeExerciseDeltas(for: day, from: allSets)
                // Pre-compute PB flags to avoid linear scan per exercise per render
                var pbFlags: [PersistentIdentifier: Bool] = [:]
                for exercise in day.exercises {
                    pbFlags[exercise.exercise.persistentModelID] = exercise.sets.workingSets.contains { $0.isPB }
                }
                cachedExercisePBFlags = pbFlags
            } else {
                cachedExerciseDeltas = [:]
                cachedExercisePBFlags = [:]
            }
        } else {
            // Compute period summary metrics
            let filteredSets = Self.filterSets(allSets, for: selectedPeriod)
            cachedPeriodMetrics = Self.computePeriodMetrics(from: filteredSets)

            // Compute workout days for exercise list (pass all sets for delta comparison)
            cachedPeriodDays = Self.computePeriodDays(from: filteredSets, allSets: Array(allSets))

            // Compute tag distribution for the period
            cachedPeriodTagDistribution = ExerciseService.tagDistribution(from: filteredSets)
        }
    }

    // MARK: - Static Computation Functions

    /// Filter sets by time period (rolling windows)
    private static func filterSets(_ sets: [ExerciseSet], for period: HistoryTimePeriod) -> [ExerciseSet] {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .lastSession:
            return sets // Not used - handled by computeDisplayDay
        case .week:
            let cutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return sets.filter { $0.timestamp >= cutoff }
        case .month:
            let cutoff = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return sets.filter { $0.timestamp >= cutoff }
        case .year:
            let cutoff = calendar.date(byAdding: .day, value: -365, to: now) ?? now
            return sets.filter { $0.timestamp >= cutoff }
        }
    }

    /// Compute aggregate metrics for a collection of sets
    private static func computePeriodMetrics(from sets: [ExerciseSet]) -> PeriodMetrics {
        let workingSets = sets.workingSets
        let calendar = Calendar.current

        let uniqueDays = Set(workingSets.map { calendar.startOfDay(for: $0.timestamp) })
        let uniqueExercises = Set(workingSets.compactMap { $0.exercise?.persistentModelID })
        let volume = workingSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        let pbs = workingSets.filter { $0.isPB }.count

        let restValues = sets.compactMap { $0.restSeconds }.map { Double($0) }
        let avgRest: Double? = restValues.isEmpty ? nil : restValues.reduce(0, +) / Double(restValues.count)

        return PeriodMetrics(
            dayCount: uniqueDays.count,
            exerciseCount: uniqueExercises.count,
            setCount: workingSets.count,
            totalVolume: volume,
            pbCount: pbs,
            avgRestSeconds: avgRest
        )
    }

    /// Compute display day from sets - expensive operation, should only be called when data changes
    private static func computeDisplayDay(from allSets: [ExerciseSet]) -> ExerciseDataGrouper.WorkoutDay? {
        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: allSets)
        let todaySets = TodaySessionCalculator.getTodaysSets(from: allSets)

        if todaySets.isEmpty {
            return workoutDays.first
        } else {
            return workoutDays.first { Calendar.current.isDateInToday($0.date) }
        }
    }

    /// Compute workout days from filtered sets for period summary
    /// Returns days in reverse chronological order (most recent first)
    /// Uses allSets (unfiltered) to compute deltas against previous sessions outside the period
    /// Pre-indexes allSets once for O(1) exercise lookup across all days
    private static func computePeriodDays(from sets: [ExerciseSet], allSets: [ExerciseSet]) -> [PeriodDaySummary] {
        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: sets)
        // Build index once, reuse across all days — avoids O(D × N) repeated scans
        let index = ExerciseDeltaCalculator.buildWorkingSetIndex(from: allSets)
        return workoutDays.map { day in
            let deltas = ExerciseDeltaCalculator.computeExerciseDeltas(for: day, from: allSets, setsByExercise: index)
            return PeriodDaySummary(from: day, deltas: deltas)
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private func sessionInfoCard(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        let allSetsForDay = day.exercises.flatMap { $0.sets }
        let pbCount = allSetsForDay.filter { $0.isPB }.count
        let sessionDuration = SessionStatsCalculator.getSessionDurationMinutes(from: allSetsForDay)
        let sessionAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: allSetsForDay)

        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Text(day.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(formatDuration(sessionDuration))
                    .font(themeManager.effectiveTheme.dataFont(size: 12))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(themeManager.effectiveTheme.muted.opacity(0.3))

            Rectangle()
                .fill(themeManager.effectiveTheme.dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 5)

            scoreboardGrid(
                workoutDays: 1,
                exercises: day.exerciseCount,
                sets: day.totalSets,
                volume: day.totalVolume,
                pbs: pbCount,
                avgRest: sessionAvgRest.map(Double.init)
            )
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func scoreboardGrid(workoutDays: Int, exercises: Int, sets: Int, volume: Double, pbs: Int, avgRest: Double?) -> some View {
        VStack(spacing: 0) {
            scoreCell(value: "\(workoutDays)", label: "Workout Days", isFirst: true)
            scoreCell(value: "\(exercises) / \(sets)", label: "Exercises / Sets")
            scoreCell(
                value: Formatters.formatVolume(themeManager.displayWeight(volume)),
                unit: themeManager.weightUnit.displayName,
                label: "Volume"
            )
            scorePBCell(count: pbs)
            scoreCell(value: avgRest.map { formatRestTime($0) } ?? "—", label: "Avg Rest")
        }
    }

    @ViewBuilder
    private func scoreCell(value: String, unit: String? = nil, label: String, isFirst: Bool = false) -> some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(themeManager.effectiveTheme.dividerColor)
                    .frame(height: 1)
                    .padding(.horizontal, 5)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(themeManager.effectiveTheme.interFont(size: 13))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value)
                        .font(themeManager.effectiveTheme.dataFont(size: 17, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    if let unit {
                        Text(unit)
                            .font(themeManager.effectiveTheme.interFont(size: 13))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    @ViewBuilder
    private func scorePBCell(count: Int) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(themeManager.effectiveTheme.dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 5)
            HStack(alignment: .firstTextBaseline) {
                Text("PBs")
                    .font(themeManager.effectiveTheme.interFont(size: 13))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(count)")
                        .font(themeManager.effectiveTheme.dataFont(size: 17, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(themeManager.effectiveTheme.pbColor)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    /// Format rest time from Double: converts to Int and delegates
    private func formatRestTime(_ seconds: Double?) -> String {
        guard let seconds else { return "—" }
        return formatRestTime(Int(seconds))
    }

    /// Format rest time: "45s" if under 1 min, "1m 30s" if over
    private func formatRestTime(_ seconds: Int?) -> String {
        guard let seconds = seconds else { return "—" }
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let mins = seconds / 60
            let secs = seconds % 60
            if secs == 0 {
                return "\(mins)m"
            } else {
                return "\(mins)m \(secs)s"
            }
        }
    }

    /// Format session/exercise duration: "45 min" if under 1 hr, "1 hr 2 min" if over
    private func formatDuration(_ minutes: Int?) -> String {
        guard let minutes = minutes else { return "—" }
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hrs = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hrs) hr"
            } else {
                return "\(hrs) hr \(mins) min"
            }
        }
    }

}
