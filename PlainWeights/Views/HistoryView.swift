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

    // Cached previous session metrics to avoid O(n*m) recomputation per exercise
    @State private var cachedPreviousMetrics: [PersistentIdentifier: PreviousSessionMetrics] = [:]

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
            .padding(.vertical, 12)

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
        .onChange(of: dataChangeToken) { _, _ in
            // Refresh when set properties change while view is visible
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

    // MARK: - Data Change Detection

    /// Lightweight fingerprint that changes when any set property affecting calculations changes
    /// This triggers cache refresh when sets are edited (not just added/removed)
    private var dataChangeToken: Int {
        var token = allSets.count
        for set in allSets {
            // Combine properties that affect volume, PB counts, and filtering
            // Using &+ for wrapping addition to avoid overflow
            token = token &+ set.timestamp.hashValue
            token = token &+ Int(set.weight * 10)  // Keep 1 decimal precision
            token = token &+ set.reps
            token = token &+ (set.isWarmUp ? 0x1000 : 0)
            token = token &+ (set.isBonus ? 0x2000 : 0)
            token = token &+ (set.isPB ? 0x4000 : 0)
        }
        return token
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
                    .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    // Tag distribution chart (only if setting enabled and there are tagged exercises)
                    if themeManager.tagBreakdownVisible {
                        let daySets = day.exercises.flatMap { $0.sets }
                        let tagDistribution = ExerciseService.tagDistribution(from: daySets)
                        if !tagDistribution.isEmpty {
                            Section {
                                Text("Tag Breakdown")
                                    .font(themeManager.effectiveTheme.interFont(size: 17, weight: .medium))
                                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                                    .padding(.top, 20)
                                    .padding(.bottom, 4)
                                    .padding(.leading, 8)

                                TagDistributionBar(data: tagDistribution)
                                    .frame(maxWidth: .infinity)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Exercises section
                    Section {
                        exercisesHeader
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, exercise in
                            compactExerciseRow(for: exercise, displayedDay: day.date, isFirst: index == 0)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
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
                .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                // Tag distribution chart (only if setting enabled and there are tagged exercises)
                if themeManager.tagBreakdownVisible && !cachedPeriodTagDistribution.isEmpty {
                    Section {
                        Text("Tag Breakdown")
                            .font(themeManager.effectiveTheme.interFont(size: 17, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .padding(.top, 20)
                            .padding(.bottom, 4)
                            .padding(.leading, 8)

                        TagDistributionBar(data: cachedPeriodTagDistribution)
                            .frame(maxWidth: .infinity)
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
                        .font(themeManager.effectiveTheme.interFont(size: 17, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .padding(.top, 16)
                        .padding(.bottom, 10)
                        .padding(.leading, 8)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                ForEach(visibleDays) { daySummary in
                    Section {
                        periodDayHeader(for: daySummary.date)

                        ForEach(Array(daySummary.exercises.enumerated()), id: \.element.id) { index, exercise in
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
                            HStack {
                                Spacer()
                                Text("See more days (\(remainingCount) more)")
                                    .font(themeManager.effectiveTheme.subheadlineFont)
                                    .foregroundStyle(themeManager.effectiveTheme.primary)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
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
            // Header with period description
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(periodDescription)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
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
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
        .padding(.leading, 8)
    }

    @ViewBuilder
    private func periodExerciseRow(number: Int, name: String, hasPB: Bool, isFirst: Bool) -> some View {
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

                        // Exercise name (regular weight, not bold)
                        Text(name)
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .regular))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)

                        Spacer()

                        if hasPB {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
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

    // MARK: - Cache Management

    /// Update all cached values - called on appear and when data/period changes
    private func updateCaches() {
        if selectedPeriod == .lastSession {
            // Compute display day for detailed view
            let day = Self.computeDisplayDay(from: allSets)
            cachedDisplayDay = day

            // Then compute previous metrics using the cached day
            guard let day else {
                cachedPreviousMetrics = [:]
                return
            }
            cachedPreviousMetrics = Self.computeAllPreviousSessionMetrics(
                for: day.exercises,
                from: allSets,
                before: day.date
            )
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
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
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

            // Row 1: Exercises, Sets, Volume
            HStack(spacing: 0) {
                metricCell(label: "Exercises", value: "\(day.exerciseCount)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Sets", value: "\(day.totalSets)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(themeManager.displayWeight(day.totalVolume))) \(themeManager.weightUnit.displayName)")
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Duration, Avg Rest, PBs
            HStack(spacing: 0) {
                metricCell(
                    label: "Duration",
                    value: formatDuration(sessionDuration)
                )
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(
                    label: "Avg Rest",
                    value: sessionAvgRest.map { formatRestTime($0) } ?? "—"
                )
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                pbMetricCell(pbCount: pbCount)
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
            // Left spacer
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
                .font(themeManager.effectiveTheme.interFont(size: 17, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            InfoButton(text: "Delta values show the difference compared to your last session for each exercise.")
        }
        .padding(.top, 16)
        .padding(.bottom, 10)
        .padding(.leading, 8)
    }

    @ViewBuilder
    private func exerciseCard(for workoutExercise: ExerciseDataGrouper.WorkoutExercise, displayedDay: Date) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let workingSets = workoutExercise.sets.workingSets
        let exerciseDuration = SessionStatsCalculator.getExerciseDurationMinutes(from: workoutExercise.sets)
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

        // Current session values
        // Find max weight first
        let currentMaxWeight = workingSets.map { $0.weight }.max() ?? 0
        // For weighted exercises: max reps at the max weight
        // For reps-only exercises: actual max reps across all sets
        let currentMaxReps = currentMaxWeight > 0
            ? (workingSets.filter { $0.weight == currentMaxWeight }.map { $0.reps }.max() ?? 0)
            : (workingSets.map { $0.reps }.max() ?? 0)
        let currentVolume = workoutExercise.volume

        // Get previous session data for comparison (O(1) lookup from pre-computed cache)
        let previousSession = cachedPreviousMetrics[workoutExercise.exercise.persistentModelID]

        // Calculate deltas
        let weightDelta: Double? = previousSession.map { currentMaxWeight - $0.maxWeight }
        let repsDelta: Int? = previousSession.map { currentMaxReps - $0.maxReps }
        let volumeDelta: Double? = previousSession.map { currentVolume - $0.volume }

        VStack(alignment: .leading, spacing: 0) {
            // Header with exercise name and duration
            HStack(spacing: 8) {
                Text(workoutExercise.exercise.name)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(formatDuration(exerciseDuration))
                    .font(themeManager.effectiveTheme.dataFont(size: 14))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider below header
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 1: Sets, Max
            HStack(spacing: 0) {
                metricCell(label: "Sets", value: "\(workoutExercise.setCount)")

                // Vertical divider
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)

                if currentMaxWeight > 0 {
                    maxMetricCellWithDelta(
                        weight: currentMaxWeight,
                        reps: currentMaxReps,
                        weightDelta: weightDelta,
                        repsDelta: repsDelta,
                        hasPB: hasPB
                    )
                } else {
                    // Reps-only exercise
                    repsOnlyMetricCellWithDelta(
                        reps: currentMaxReps,
                        repsDelta: repsDelta,
                        hasPB: hasPB
                    )
                }
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, Avg Rest
            HStack(spacing: 0) {
                volumeMetricCellWithDelta(
                    volume: currentVolume,
                    volumeDelta: volumeDelta
                )

                // Vertical divider
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)

                metricCell(label: "Avg Rest", value: formatRestTime(exerciseAvgRest))
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

    /// Compact two-line exercise row for Last session view
    @ViewBuilder
    private func compactExerciseRow(for workoutExercise: ExerciseDataGrouper.WorkoutExercise, displayedDay: Date, isFirst: Bool) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let workingSets = workoutExercise.sets.workingSets
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

        // Current session values
        let currentMaxWeight = workingSets.map { $0.weight }.max() ?? 0
        let currentMaxReps = currentMaxWeight > 0
            ? (workingSets.filter { $0.weight == currentMaxWeight }.map { $0.reps }.max() ?? 0)
            : (workingSets.map { $0.reps }.max() ?? 0)
        let currentVolume = workoutExercise.volume

        // Get previous session data for comparison
        let previousSession = cachedPreviousMetrics[workoutExercise.exercise.persistentModelID]

        // Calculate deltas
        let weightDelta: Double? = previousSession.map { currentMaxWeight - $0.maxWeight }
        let repsDelta: Int? = previousSession.map { currentMaxReps - $0.maxReps }
        let volumeDelta: Double? = previousSession.map { currentVolume - $0.volume }

        // Determine accent color: PB takes priority (gold), then delta direction
        let accentColor: Color? = hasPB
            ? themeManager.effectiveTheme.pbColor
            : deltaAccentColor(weightDelta: weightDelta, repsDelta: repsDelta)

        VStack(spacing: 0) {
            // Divider at top (not for first row)
            if !isFirst {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
            }

            HStack(spacing: 0) {
                // Accent bar (3px)
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Line 1: Name + Rest Time + PB
                    HStack(spacing: 6) {
                        Text(workoutExercise.exercise.name)
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                            .lineLimit(1)

                        Spacer()

                        Text("Avg rest: \(formatRestTime(exerciseAvgRest))")
                            .font(themeManager.effectiveTheme.interFont(size: 12, weight: .regular))
                            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)

                        if hasPB {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
                    }

                    // Line 2: Sets + Weight × Reps (with inline deltas) + Volume
                    HStack(spacing: 0) {
                        // Sets count
                        Text("\(workoutExercise.setCount) sets")
                            .font(themeManager.effectiveTheme.interFont(size: 12, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                            .monospacedDigit()

                        Text("  ·  ")
                            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)

                        // Weight with delta
                        if currentMaxWeight > 0 {
                            (
                                Text("\(Formatters.formatWeight(themeManager.displayWeight(currentMaxWeight)))")
                                    .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .semibold))
                                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                                + Text(" \(themeManager.weightUnit.displayName)")
                                    .font(themeManager.effectiveTheme.dataFont(size: 11))
                                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                                + Text(weightDelta.flatMap { $0 != 0 ? " \(formatWeightDelta($0))" : nil } ?? "")
                                    .font(themeManager.effectiveTheme.dataFont(size: 12))
                                    .foregroundStyle(deltaColor(weightDelta ?? 0))
                                + Text("  ×  ")
                                    .font(themeManager.effectiveTheme.dataFont(size: 14))
                                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                                + Text("\(currentMaxReps)")
                                    .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .semibold))
                                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                                + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                                    .font(themeManager.effectiveTheme.dataFont(size: 12))
                                    .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                            )
                        } else {
                            // Reps-only exercise
                            (
                                Text("\(currentMaxReps) reps")
                                    .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .semibold))
                                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                                + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                                    .font(themeManager.effectiveTheme.dataFont(size: 12))
                                    .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                            )
                        }

                        Spacer()

                        // Total volume (right side)
                        Text("Vol: \(Formatters.formatVolume(themeManager.displayWeight(currentVolume)))")
                            .font(themeManager.effectiveTheme.interFont(size: 12, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                            .monospacedDigit()
                    }
                    .monospacedDigit()
                }
                .padding(.leading, 10)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
            }
            .background {
                if let color = accentColor {
                    color.opacity(themeManager.currentTheme == .dark ? 0.12 : 0.06)
                } else {
                    Color.clear
                }
            }
        }
    }

    // MARK: - Previous Session Comparison

    private struct PreviousSessionMetrics {
        let maxWeight: Double
        let maxReps: Int
        let volume: Double
    }

    /// Compute all previous session metrics in a single pass - O(n) instead of O(n*e)
    private static func computeAllPreviousSessionMetrics(
        for exercises: [ExerciseDataGrouper.WorkoutExercise],
        from allSets: [ExerciseSet],
        before displayedDay: Date
    ) -> [PersistentIdentifier: PreviousSessionMetrics] {
        let calendar = Calendar.current
        let displayedDayStart = calendar.startOfDay(for: displayedDay)

        // Get exercise IDs we care about
        let exerciseIDs = Set(exercises.map { $0.exercise.persistentModelID })

        // Single pass: filter and group by exercise ID
        var setsByExercise: [PersistentIdentifier: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseID = set.exercise?.persistentModelID,
                  exerciseIDs.contains(exerciseID),
                  calendar.startOfDay(for: set.timestamp) < displayedDayStart,
                  !set.isWarmUp && !set.isBonus else {
                continue
            }
            setsByExercise[exerciseID, default: []].append(set)
        }

        // For each exercise, find most recent day and compute metrics
        var result: [PersistentIdentifier: PreviousSessionMetrics] = [:]
        for (exerciseID, exerciseSets) in setsByExercise {
            // Group by day
            let grouped = Dictionary(grouping: exerciseSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }

            guard let mostRecentDay = grouped.keys.max(),
                  let previousDaySets = grouped[mostRecentDay] else {
                continue
            }

            // Calculate metrics
            // Find max weight first
            let maxWeight = previousDaySets.map { $0.weight }.max() ?? 0
            // For weighted exercises: max reps at the max weight
            // For reps-only exercises: actual max reps across all sets
            let maxReps = maxWeight > 0
                ? (previousDaySets.filter { $0.weight == maxWeight }.map { $0.reps }.max() ?? 0)
                : (previousDaySets.map { $0.reps }.max() ?? 0)
            let volume = previousDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

            result[exerciseID] = PreviousSessionMetrics(maxWeight: maxWeight, maxReps: maxReps, volume: volume)
        }

        return result
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

    /// Max weight metric cell with inline deltas and accent bar
    @ViewBuilder
    private func maxMetricCellWithDelta(
        weight: Double,
        reps: Int,
        weightDelta: Double?,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: weightDelta, repsDelta: repsDelta)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Label row with PB
                    HStack {
                        Text("Max Weight")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        if hasPB {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
                    }

                    // Value with inline deltas: "45 kg -5.5 × 10 +2"
                    (
                        Text(Formatters.formatWeight(themeManager.displayWeight(weight)))
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(" \(themeManager.weightUnit.displayName)")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text(weightDelta.flatMap { $0 != 0 ? " \(formatWeightDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(weightDelta ?? 0))
                        + Text(" × ")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text("\(reps)")
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    /// Reps-only metric cell with inline delta and accent bar
    @ViewBuilder
    private func repsOnlyMetricCellWithDelta(
        reps: Int,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: nil, repsDelta: repsDelta)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Max Reps")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        if hasPB {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
                    }
                    // Value with inline delta: "12 +2"
                    (
                        Text("\(reps)")
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    /// Volume metric cell with inline delta and accent bar
    @ViewBuilder
    private func volumeMetricCellWithDelta(
        volume: Double,
        volumeDelta: Double?
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: volumeDelta, repsDelta: nil)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Volume")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    // Value with inline delta: "1,250 kg +150"
                    (
                        Text(Formatters.formatVolume(themeManager.displayWeight(volume)))
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(" \(themeManager.weightUnit.displayName)")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text(volumeDelta.flatMap { $0 != 0 ? " \(formatVolumeDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(volumeDelta ?? 0))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    // MARK: - Delta Formatting Helpers

    private func formatWeightDelta(_ delta: Double) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(Formatters.formatWeight(themeManager.displayWeight(delta)))"
    }

    private func formatRepsDelta(_ delta: Int) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(delta)"
    }

    private func formatVolumeDelta(_ delta: Double) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(Formatters.formatVolume(themeManager.displayWeight(delta)))"
    }

    private func deltaColor(_ value: Double) -> Color {
        if value > 0 { return .green }
        if value < 0 { return .red }
        return .secondary
    }

    /// Determine accent bar color based on deltas
    /// Green if any positive, red if any negative (green takes priority if both)
    private func deltaAccentColor(weightDelta: Double?, repsDelta: Int?) -> Color? {
        let hasPositive = (weightDelta ?? 0) > 0 || (repsDelta ?? 0) > 0
        let hasNegative = (weightDelta ?? 0) < 0 || (repsDelta ?? 0) < 0

        if hasPositive { return .green }
        if hasNegative { return .red }
        return nil
    }
}
