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
    case week = "Week"          // Calendar week (Mon → today)
    case month = "Month"        // Calendar month (1st → today)
    case year = "Year"          // Calendar year (Jan 1 → today)
    case rolling12Months = "12 Mo"  // Rolling 365 days
}

/// Aggregate metrics for a time period summary
private struct PeriodMetrics {
    let dayCount: Int           // Unique workout days
    let setCount: Int           // Working sets only
    let totalVolume: Double     // Sum of weight × reps
    let pbCount: Int            // Sets where isPB == true

    static let empty = PeriodMetrics(dayCount: 0, setCount: 0, totalVolume: 0, pbCount: 0)
}

/// Lightweight exercise summary for period view
private struct PeriodExerciseSummary: Identifiable {
    let id: PersistentIdentifier
    let name: String
    let hasPB: Bool

    init(from workoutExercise: ExerciseDataGrouper.WorkoutExercise) {
        self.id = workoutExercise.id
        self.name = workoutExercise.exercise.name
        self.hasPB = workoutExercise.sets.workingSets.contains { $0.isPB }
    }
}

/// Day summary for period view
private struct PeriodDaySummary: Identifiable {
    let id: Date
    let date: Date
    let exercises: [PeriodExerciseSummary]

    init(from workoutDay: ExerciseDataGrouper.WorkoutDay) {
        self.id = workoutDay.date
        self.date = workoutDay.date
        self.exercises = workoutDay.exercises.map { PeriodExerciseSummary(from: $0) }
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Query private var allSets: [ExerciseSet]

    // Selected time period
    @State private var selectedPeriod: HistoryTimePeriod = .lastSession

    // Cached display day - prevents expensive recomputation on every render
    @State private var cachedDisplayDay: ExerciseDataGrouper.WorkoutDay?

    // Cached session wins for summary card
    @State private var cachedSessionWins: SessionWins = .empty

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

    // Show delta symbols info popover
    @State private var showingDeltaInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Time period picker
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(HistoryTimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            if selectedPeriod == .lastSession {
                // Detailed last session view
                lastSessionDetailView
            } else {
                // Period summary view
                periodSummaryView
            }
        }
        .background(AnimatedGradientBackground())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Always refresh when view becomes visible (handles navigation back)
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

    // MARK: - Last Session Detail View

    @ViewBuilder
    private var lastSessionDetailView: some View {
        if let day = cachedDisplayDay {
            List {
                    // Session info card
                    Section {
                        sessionInfoCard(for: day)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    // Tag distribution chart (only if setting enabled and there are tagged exercises)
                    if themeManager.tagBreakdownVisible {
                        let daySets = day.exercises.flatMap { $0.sets }
                        let tagDistribution = ExerciseService.tagDistribution(from: daySets)
                        if !tagDistribution.isEmpty {
                            Section {
                                Text("Tag Breakdown")
                                    .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                                    .padding(.top, 20)
                                    .padding(.bottom, 4)
                                    .padding(.leading, 8)

                                TagDistributionBar(data: tagDistribution)
                                    .frame(maxWidth: .infinity)
                                    .background(themeManager.effectiveTheme.cardBackgroundColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
                                    )
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Exercises section (simple list matching period views)
                    Section {
                        exercisesHeader
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        ForEach(day.exercises.enumerated(), id: \.element.id) { index, exercise in
                            let hasPB = exercise.sets.contains { $0.isPB }
                            let deltas = cachedExerciseDeltas[exercise.exercise.persistentModelID]
                            periodExerciseRow(number: index + 1, name: exercise.exercise.name, hasPB: hasPB, isFirst: index == 0, deltas: deltas)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .id(themeManager.systemColorScheme) // Force List re-render on theme change
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 12, for: .scrollContent)
                .id(selectedPeriod)  // Force scroll to top when period changes
            } else {
                // Empty state
                Spacer()
                VStack(spacing: 12) {
                    RetroLifterView(pixelSize: 5)

                    Text("No Workouts Yet")
                        .font(themeManager.effectiveTheme.title2Font)

                    Text("Complete your first workout to see a summary here.")
                        .font(themeManager.effectiveTheme.subheadlineFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                Spacer()
            }
        }

    // MARK: - Period Summary View

    @ViewBuilder
    private var periodSummaryView: some View {
        if cachedPeriodMetrics.dayCount > 0 {
            List {
                // Summary card section
                Section {
                    periodSummaryCard
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                // Tag distribution chart (only if setting enabled and there are tagged exercises)
                if themeManager.tagBreakdownVisible && !cachedPeriodTagDistribution.isEmpty {
                    Section {
                        Text("Tag Breakdown")
                            .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .padding(.top, 20)
                            .padding(.bottom, 4)
                            .padding(.leading, 8)

                        TagDistributionBar(data: cachedPeriodTagDistribution)
                            .frame(maxWidth: .infinity)
                            .background(themeManager.effectiveTheme.cardBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
                            )
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                // Exercise list by day (paginated)
                let visibleDays = Array(cachedPeriodDays.prefix(visiblePeriodDaysCount))
                let hasMoreDays = cachedPeriodDays.count > visiblePeriodDaysCount
                let remainingCount = cachedPeriodDays.count - visiblePeriodDaysCount

                // Exercises label (once, above all days)
                Section {
                    Text("Exercises")
                        .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                        .padding(.leading, 8)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                ForEach(visibleDays) { daySummary in
                    Section {
                        periodDayHeader(for: daySummary.date)

                        ForEach(daySummary.exercises.enumerated(), id: \.element.id) { index, exercise in
                            periodExerciseRow(number: index + 1, name: exercise.name, hasPB: exercise.hasPB, isFirst: index == 0)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                // "See more days" button when more history exists
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
            }
            .id("\(selectedPeriod.rawValue)-\(themeManager.systemColorScheme)") // Force scroll to top when period changes & re-render on theme change
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 12, for: .scrollContent)
            .id(selectedPeriod)  // Force scroll to top when period changes
        } else {
            // Empty state for period
            Spacer()
            VStack(spacing: 12) {
                RetroLifterView(pixelSize: 5)

                Text("No Workouts")
                    .font(themeManager.effectiveTheme.title2Font)

                Text("No workouts recorded for this time period.")
                    .font(themeManager.effectiveTheme.subheadlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var periodSummaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with period description and workout count
            HStack(spacing: 0) {
                Text(periodDescription)
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(" · \(cachedPeriodMetrics.dayCount) \(cachedPeriodMetrics.dayCount == 1 ? "workout" : "workouts")")
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .regular))
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 1: Workout Days, Sets
            HStack(spacing: 0) {
                metricCell(label: "Workout Days", value: "\(cachedPeriodMetrics.dayCount)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Sets", value: "\(cachedPeriodMetrics.setCount)")
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, PBs
            HStack(spacing: 0) {
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(themeManager.displayWeight(cachedPeriodMetrics.totalVolume))) \(themeManager.weightUnit.displayName)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                pbMetricCell(pbCount: cachedPeriodMetrics.pbCount)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    /// Description of the current time period
    private var periodDescription: String {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .lastSession:
            return "" // Not used for last session
        case .week:
            // "This Week (Mon - Today)"
            return "This Week"
        case .month:
            // "February 2025"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: now)
        case .year:
            // "2025"
            return "\(calendar.component(.year, from: now))"
        case .rolling12Months:
            // "Past 12 Months"
            return "Past 12 Months"
        }
    }

    @ViewBuilder
    private func periodDayHeader(for date: Date) -> some View {
        HStack {
            Text(date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .padding(.leading, 8)
    }

    @ViewBuilder
    private func periodExerciseRow(number: Int, name: String, hasPB: Bool, isFirst: Bool, deltas: ExerciseDeltas? = nil) -> some View {
        VStack(spacing: 0) {
            // Divider at top (not for first row)
            if !isFirst {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
                    .padding(.leading, 8)
            }

            HStack(spacing: 0) {
                // Left spacer
                Color.clear.frame(width: 8)

                // Accent bar + content area
                HStack(spacing: 0) {
                    // Yellow accent bar for PB rows
                    if hasPB {
                        Rectangle()
                            .fill(themeManager.effectiveTheme.pbColor)
                            .frame(width: 3)
                    } else {
                        Color.clear.frame(width: 3)
                    }

                    HStack(spacing: 0) {
                        // Number (styled like set rows)
                        Text("\(number)")
                            .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .frame(width: 20, alignment: .leading)
                            .padding(.leading, 6)

                        // Exercise name (medium weight for consistency)
                        Text(name)
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)

                        Spacer()

                        // Delta indicators - only show if deltas provided
                        if let deltas = deltas {
                            HStack(spacing: 0) {
                                deltaIndicator("scalemass.fill", direction: deltas.weight)
                                    .frame(width: 20)
                                deltaIndicator("arrow.2.squarepath", direction: deltas.reps)
                                    .frame(width: 20)
                                deltaIndicator("square.stack.3d.up.fill", direction: deltas.volume)
                                    .frame(width: 20)
                            }
                        }

                        // Star icon - always reserve space for alignment
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(hasPB ? themeManager.effectiveTheme.pbColor : .clear)
                            .frame(width: 20)
                    }
                    .padding(.vertical, 6)
                    .padding(.trailing, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if hasPB {
                        themeManager.effectiveTheme.pbColor.opacity(0.08)
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func deltaIndicator(_ symbolName: String, direction: DeltaDirection) -> some View {
        Image(systemName: symbolName)
            .font(.system(size: 10))
            .foregroundStyle(direction.color)
    }

    // MARK: - Cache Management

    /// Update all cached values - called on appear and when data/period changes
    private func updateCaches() {
        if selectedPeriod == .lastSession {
            // Compute display day for detailed view
            let day = Self.computeDisplayDay(from: allSets)
            cachedDisplayDay = day

            // Compute session wins for summary card
            if let day = day {
                cachedSessionWins = Self.computeSessionWins(for: day, from: allSets)
                cachedExerciseDeltas = Self.computeExerciseDeltas(for: day, from: allSets)
            } else {
                cachedSessionWins = .empty
                cachedExerciseDeltas = [:]
            }
        } else {
            // Compute period summary metrics
            let filteredSets = Self.filterSets(allSets, for: selectedPeriod)
            cachedPeriodMetrics = Self.computePeriodMetrics(from: filteredSets)

            // Compute workout days for exercise list
            cachedPeriodDays = Self.computePeriodDays(from: filteredSets)

            // Compute tag distribution for the period
            cachedPeriodTagDistribution = ExerciseService.tagDistribution(from: filteredSets)
        }
    }

    // MARK: - Static Computation Functions

    /// Filter sets by time period (calendar-based for Week/Month/Year, rolling for 12 Mo)
    private static func filterSets(_ sets: [ExerciseSet], for period: HistoryTimePeriod) -> [ExerciseSet] {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .lastSession:
            return sets // Not used - handled by computeDisplayDay
        case .week:
            // Monday of current week (ISO 8601: Monday = 2)
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekday = 2 // Monday
            let monday = calendar.date(from: components) ?? now
            return sets.filter { $0.timestamp >= calendar.startOfDay(for: monday) }
        case .month:
            // 1st of current month
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return sets.filter { $0.timestamp >= firstOfMonth }
        case .year:
            // Jan 1 of current year
            let firstOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return sets.filter { $0.timestamp >= firstOfYear }
        case .rolling12Months:
            // Past 365 days
            let cutoff = calendar.date(byAdding: .day, value: -365, to: now)!
            return sets.filter { $0.timestamp >= cutoff }
        }
    }

    /// Compute aggregate metrics for a collection of sets
    private static func computePeriodMetrics(from sets: [ExerciseSet]) -> PeriodMetrics {
        let workingSets = sets.workingSets
        let calendar = Calendar.current

        let uniqueDays = Set(workingSets.map { calendar.startOfDay(for: $0.timestamp) })
        let volume = workingSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        let pbs = workingSets.filter { $0.isPB }.count

        return PeriodMetrics(
            dayCount: uniqueDays.count,
            setCount: workingSets.count,
            totalVolume: volume,
            pbCount: pbs
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
    private static func computePeriodDays(from sets: [ExerciseSet]) -> [PeriodDaySummary] {
        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: sets)
        return workoutDays.map { PeriodDaySummary(from: $0) }
    }

    // MARK: - View Components

    @ViewBuilder
    private func sessionInfoCard(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        let pbCount = day.exercises.flatMap { $0.sets }.filter { $0.isPB }.count
        let allSetsForDay = day.exercises.flatMap { $0.sets }
        let sessionDuration = SessionStatsCalculator.getSessionDurationMinutes(from: allSetsForDay)
        let sessionAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: allSetsForDay)

        VStack(alignment: .leading, spacing: 0) {
            // Header with date and duration
            HStack(spacing: 8) {
                Text(day.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(formatDuration(sessionDuration))
                    .font(themeManager.effectiveTheme.dataFont(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 1: Exercises, Sets, PBs
            HStack(spacing: 0) {
                metricCell(label: "Exercises", value: "\(day.exerciseCount)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Sets", value: "\(day.totalSets)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                pbMetricCell(pbCount: pbCount)
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, Avg Rest
            HStack(spacing: 0) {
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(themeManager.displayWeight(day.totalVolume))) \(themeManager.weightUnit.displayName)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(
                    label: "Avg Rest",
                    value: sessionAvgRest.map { formatRestTime($0) } ?? "—"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func metricCell(label: String, value: String) -> some View {
        HStack(spacing: 0) {
            // Left spacer (matches delta cells: 8pt spacer + 3pt bar space)
            Color.clear.frame(width: 11)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Text(value)
                    .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    @ViewBuilder
    private func pbMetricCell(pbCount: Int) -> some View {
        HStack(spacing: 0) {
            // Left spacer to inset accent bar
            Color.clear.frame(width: 8)

            // Accent bar + content area
            HStack(spacing: 0) {
                // Yellow accent bar when there are PBs
                if pbCount > 0 {
                    Rectangle()
                        .fill(themeManager.effectiveTheme.pbColor)
                        .frame(width: 3)
                } else {
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("PBs")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    // Value: "3 × ⭐"
                    HStack(alignment: .center, spacing: 0) {
                        Text("\(pbCount)")
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        Text(" × ")
                            .font(themeManager.effectiveTheme.interFont(size: 14))
                            .foregroundStyle(.secondary)
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(themeManager.effectiveTheme.pbColor)
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 16)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if pbCount > 0 {
                    themeManager.effectiveTheme.pbColor.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    private var exercisesHeader: some View {
        HStack(spacing: 6) {
            Text("Exercises")
                .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            Button {
                showingDeltaInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground.opacity(0.6))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingDeltaInfo) {
                deltaInfoPopover
            }

            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 10)
        .padding(.leading, 8)
    }

    private var deltaInfoPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compared to previous session")
                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                deltaInfoRow(symbol: "scalemass.fill", label: "Max weight")
                deltaInfoRow(symbol: "arrow.2.squarepath", label: "Max reps")
                deltaInfoRow(symbol: "square.stack.3d.up.fill", label: "Total volume")
            }

            Divider()

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("Increase")
                        .font(themeManager.effectiveTheme.captionFont)
                }
                HStack(spacing: 4) {
                    Circle().fill(.red).frame(width: 8, height: 8)
                    Text("Decrease")
                        .font(themeManager.effectiveTheme.captionFont)
                }
                HStack(spacing: 4) {
                    Circle().fill(.gray.opacity(0.3)).frame(width: 8, height: 8)
                    Text("No change")
                        .font(themeManager.effectiveTheme.captionFont)
                }
            }
            .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
        .padding(16)
        .presentationCompactAdaptation(.popover)
    }

    private func deltaInfoRow(symbol: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .frame(width: 20)
            Text(label)
                .font(themeManager.effectiveTheme.interFont(size: 13, weight: .regular))
                .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
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

    // MARK: - Session Wins

    /// Summary of achievements in a session
    private struct SessionWins {
        let pbCount: Int
        let weightIncreases: Int
        let repIncreases: Int
        let volumeIncreases: Int

        var hasAnyWins: Bool {
            pbCount > 0 || weightIncreases > 0 || repIncreases > 0 || volumeIncreases > 0
        }

        static let empty = SessionWins(pbCount: 0, weightIncreases: 0, repIncreases: 0, volumeIncreases: 0)
    }

    // MARK: - Exercise Deltas

    /// Change direction for a metric: up, down, or same
    private enum DeltaDirection {
        case up, down, same, noData

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .same, .noData: return .gray.opacity(0.3)
            }
        }
    }

    /// Deltas for an exercise compared to previous session
    private struct ExerciseDeltas {
        let weight: DeltaDirection
        let reps: DeltaDirection
        let volume: DeltaDirection

        static let empty = ExerciseDeltas(weight: .noData, reps: .noData, volume: .noData)
    }

    /// Compute session wins by comparing to previous sessions
    private static func computeSessionWins(
        for day: ExerciseDataGrouper.WorkoutDay,
        from allSets: [ExerciseSet]
    ) -> SessionWins {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day.date)

        // Count PBs
        let pbCount = day.exercises.flatMap { $0.sets }.filter { $0.isPB }.count

        var weightIncreases = 0
        var repIncreases = 0
        var volumeIncreases = 0

        for exercise in day.exercises {
            let exerciseID = exercise.exercise.persistentModelID
            let workingSets = exercise.sets.workingSets

            // Current session values
            let currentMaxWeight = workingSets.map { $0.weight }.max() ?? 0
            let currentMaxReps = currentMaxWeight > 0
                ? (workingSets.filter { $0.weight == currentMaxWeight }.map { $0.reps }.max() ?? 0)
                : (workingSets.map { $0.reps }.max() ?? 0)
            let currentVolume = exercise.volume

            // Find previous session for this exercise
            let previousSets = allSets.filter { set in
                guard let setExerciseID = set.exercise?.persistentModelID,
                      setExerciseID == exerciseID,
                      calendar.startOfDay(for: set.timestamp) < dayStart,
                      !set.isWarmUp && !set.isBonus else {
                    return false
                }
                return true
            }

            guard !previousSets.isEmpty else { continue }

            // Group by day and get most recent
            let grouped = Dictionary(grouping: previousSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }

            guard let mostRecentDay = grouped.keys.max(),
                  let previousDaySets = grouped[mostRecentDay] else {
                continue
            }

            // Previous session values
            let prevMaxWeight = previousDaySets.map { $0.weight }.max() ?? 0
            let prevMaxReps = prevMaxWeight > 0
                ? (previousDaySets.filter { $0.weight == prevMaxWeight }.map { $0.reps }.max() ?? 0)
                : (previousDaySets.map { $0.reps }.max() ?? 0)
            let prevVolume = previousDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

            // Count improvements
            if currentMaxWeight > prevMaxWeight { weightIncreases += 1 }
            if currentMaxReps > prevMaxReps { repIncreases += 1 }
            if currentVolume > prevVolume { volumeIncreases += 1 }
        }

        return SessionWins(
            pbCount: pbCount,
            weightIncreases: weightIncreases,
            repIncreases: repIncreases,
            volumeIncreases: volumeIncreases
        )
    }

    /// Compute deltas for each exercise compared to previous session
    private static func computeExerciseDeltas(
        for day: ExerciseDataGrouper.WorkoutDay,
        from allSets: [ExerciseSet]
    ) -> [PersistentIdentifier: ExerciseDeltas] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day.date)

        var deltas: [PersistentIdentifier: ExerciseDeltas] = [:]

        for exercise in day.exercises {
            let exerciseID = exercise.exercise.persistentModelID
            let workingSets = exercise.sets.workingSets

            // Current session values
            let currentMaxWeight = workingSets.map { $0.weight }.max() ?? 0
            let currentMaxReps = currentMaxWeight > 0
                ? (workingSets.filter { $0.weight == currentMaxWeight }.map { $0.reps }.max() ?? 0)
                : (workingSets.map { $0.reps }.max() ?? 0)
            let currentVolume = exercise.volume

            // Find previous session for this exercise
            let previousSets = allSets.filter { set in
                guard let setExerciseID = set.exercise?.persistentModelID,
                      setExerciseID == exerciseID,
                      calendar.startOfDay(for: set.timestamp) < dayStart,
                      !set.isWarmUp && !set.isBonus else {
                    return false
                }
                return true
            }

            guard !previousSets.isEmpty else {
                deltas[exerciseID] = .empty
                continue
            }

            // Group by day and get most recent
            let grouped = Dictionary(grouping: previousSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }

            guard let mostRecentDay = grouped.keys.max(),
                  let previousDaySets = grouped[mostRecentDay] else {
                deltas[exerciseID] = .empty
                continue
            }

            // Previous session values
            let prevMaxWeight = previousDaySets.map { $0.weight }.max() ?? 0
            let prevMaxReps = prevMaxWeight > 0
                ? (previousDaySets.filter { $0.weight == prevMaxWeight }.map { $0.reps }.max() ?? 0)
                : (previousDaySets.map { $0.reps }.max() ?? 0)
            let prevVolume = previousDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

            // Determine direction for each metric
            let weightDir: DeltaDirection = currentMaxWeight > prevMaxWeight ? .up
                : currentMaxWeight < prevMaxWeight ? .down : .same
            let repsDir: DeltaDirection = currentMaxReps > prevMaxReps ? .up
                : currentMaxReps < prevMaxReps ? .down : .same
            let volumeDir: DeltaDirection = currentVolume > prevVolume ? .up
                : currentVolume < prevVolume ? .down : .same

            deltas[exerciseID] = ExerciseDeltas(weight: weightDir, reps: repsDir, volume: volumeDir)
        }

        return deltas
    }
}
