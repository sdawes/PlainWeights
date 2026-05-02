//
//  ComparisonMetricsCard.swift
//  PlainWeights
//
//  Session Comparison Card — shows how the current workout compares to a
//  reference session (Last Session or All-Time Best). The user toggles between
//  these two modes via buttons above this card in ExerciseDetailView.
//
//  Layout (top to bottom):
//    ┌─────────────────────────────────────────────┐
//    │  Card Header — mode icon, title, date, unit  │
//    │  ─────────────────────────────────────────── │
//    │  Reference Metrics — Max Weight, Reps, Vol   │
//    │  Gauges + Deltas + Footer (VerticalBarComp.) │
//    └─────────────────────────────────────────────┘
//

import SwiftUI

// MARK: - Comparison Mode

enum ComparisonMode: String, CaseIterable {
    case lastSession = "Last Session"
    case allTimeBest = "All-Time Best"
}

// MARK: - Comparison Metrics Card

struct ComparisonMetricsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var comparisonMode: ComparisonMode
    let sets: [ExerciseSet]
    var todayDeltas: ExerciseDeltas = .empty

    // Cached metrics - computed in init to prevent layout shift and improve scroll performance
    @State private var cachedTodaysSets: [ExerciseSet]
    @State private var cachedSetsExcludingToday: [ExerciseSet]
    @State private var cachedLastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)?
    @State private var cachedBestMetrics: BestSessionCalculator.BestDayMetrics?
    @State private var cachedLastModeIndicators: ProgressTracker.LastModeIndicators?
    @State private var cachedBestModeIndicators: ProgressTracker.BestModeIndicators?
    @State private var cachedTodaysVolume: Double
    @State private var cachedTodaysTotalReps: Int
    @State private var cachedLastSetWeight: Double?
    @State private var cachedTodaysBestWeight: Double
    @State private var cachedTodaysBestReps: Int

    init(comparisonMode: Binding<ComparisonMode>, sets: [ExerciseSet], todayDeltas: ExerciseDeltas = .empty) {
        self._comparisonMode = comparisonMode
        self.sets = sets
        self.todayDeltas = todayDeltas

        // Pre-compute all metrics during init
        let computed = Self.computeAllMetrics(sets: sets, comparisonMode: comparisonMode.wrappedValue)
        _cachedTodaysSets = State(initialValue: computed.todaysSets)
        _cachedSetsExcludingToday = State(initialValue: computed.setsExcludingToday)
        _cachedLastSessionMetrics = State(initialValue: computed.lastSessionMetrics)
        _cachedBestMetrics = State(initialValue: computed.bestMetrics)
        _cachedLastModeIndicators = State(initialValue: computed.lastModeIndicators)
        _cachedBestModeIndicators = State(initialValue: computed.bestModeIndicators)
        _cachedTodaysVolume = State(initialValue: computed.todaysVolume)
        _cachedTodaysTotalReps = State(initialValue: computed.todaysTotalReps)
        _cachedLastSetWeight = State(initialValue: computed.lastSetWeight)
        _cachedTodaysBestWeight = State(initialValue: computed.todaysBestWeight)
        _cachedTodaysBestReps = State(initialValue: computed.todaysBestReps)
    }

    // MARK: - Static Computation

    private struct ComputedMetrics {
        let todaysSets: [ExerciseSet]
        let setsExcludingToday: [ExerciseSet]
        let lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)?
        let bestMetrics: BestSessionCalculator.BestDayMetrics?
        let lastModeIndicators: ProgressTracker.LastModeIndicators?
        let bestModeIndicators: ProgressTracker.BestModeIndicators?
        let todaysVolume: Double
        let todaysTotalReps: Int
        let lastSetWeight: Double?
        let todaysBestWeight: Double
        let todaysBestReps: Int
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
        let lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)?
        if let lastInfo = progressState.lastCompletedDayInfo {
            // Calculate total reps from last session
            let lastSessionTotalReps = LastSessionCalculator.getLastSessionTotalReps(from: sets)
            lastSessionMetrics = (lastInfo.date, lastInfo.maxWeight, lastInfo.maxWeightReps, lastInfo.volume, lastSessionTotalReps)
        } else {
            lastSessionMetrics = nil
        }

        // Best metrics
        let bestMetrics = BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)

        // Last mode indicators
        var lastModeIndicators: ProgressTracker.LastModeIndicators? = nil
        if comparisonMode == .lastSession, let lastMetrics = lastSessionMetrics, !todaysSets.isEmpty {
            // Detect exercise type transition (e.g., bodyweight → weighted)
            let todayType = ExerciseMetricsType.determine(from: todaysSets)
            let lastSessionSets = ExerciseDataHelper.getLastCompletedDaySets(from: sets) ?? []
            let lastType = ExerciseMetricsType.determine(from: lastSessionSets)

            // Skip delta comparison when exercise type changed (misleading numbers)
            if todayType == lastType {
                let todaysMaxWeight = TodaySessionCalculator.getTodaysMaxWeight(from: sets)
                let todaysMaxReps = TodaySessionCalculator.getTodaysMaxReps(from: sets)
                let todaysVolume = TodaySessionCalculator.getTodaysVolume(from: sets)
                let todaysTotalReps = todaysSets.reduce(0) { $0 + $1.reps }

                lastModeIndicators = ProgressTracker.LastModeIndicators.compare(
                    todaysMaxWeight: todaysMaxWeight,
                    todaysMaxReps: todaysMaxReps,
                    todaysVolume: todaysVolume,
                    todaysTotalReps: todaysTotalReps,
                    lastSessionMaxWeight: lastMetrics.maxWeight,
                    lastSessionMaxReps: lastMetrics.maxReps,
                    lastSessionVolume: lastMetrics.totalVolume,
                    lastSessionTotalReps: lastMetrics.totalReps,
                    exerciseType: todayType
                )
            }
        }

        // Best mode indicators
        var bestModeIndicators: ProgressTracker.BestModeIndicators? = nil
        if comparisonMode == .allTimeBest, !todaysSets.isEmpty {
            // Detect exercise type transition for best mode too
            let todayType = ExerciseMetricsType.determine(from: todaysSets)
            let bestIsBodyweight = bestMetrics?.isBodyweight ?? false
            let bestType: ExerciseMetricsType = bestIsBodyweight ? .repsOnly : .combined

            // Skip delta comparison when exercise type changed
            if todayType == bestType {
                bestModeIndicators = ProgressTracker.calculateBestModeIndicators(
                    todaySets: todaysSets,
                    bestMetrics: bestMetrics
                )
            }
        }

        return ComputedMetrics(
            todaysSets: todaysSets,
            setsExcludingToday: setsExcludingToday,
            lastSessionMetrics: lastSessionMetrics,
            bestMetrics: bestMetrics,
            lastModeIndicators: lastModeIndicators,
            bestModeIndicators: bestModeIndicators,
            todaysVolume: TodaySessionCalculator.getTodaysVolume(from: sets),
            todaysTotalReps: todaysSets.reduce(0) { $0 + $1.reps },
            lastSetWeight: todaysSets.first?.weight,
            todaysBestWeight: TodaySessionCalculator.getTodaysMaxWeight(from: sets),
            todaysBestReps: TodaySessionCalculator.getTodaysHighestReps(from: sets)
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
        cachedTodaysVolume = computed.todaysVolume
        cachedTodaysTotalReps = computed.todaysTotalReps
        cachedLastSetWeight = computed.lastSetWeight
        cachedTodaysBestWeight = computed.todaysBestWeight
        cachedTodaysBestReps = computed.todaysBestReps
    }

    // MARK: - Simple Getters for Cached Values

    private var todaysSets: [ExerciseSet] { cachedTodaysSets }
    private var setsExcludingToday: [ExerciseSet] { cachedSetsExcludingToday }
    private var lastSessionMetrics: (date: Date, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)? { cachedLastSessionMetrics }
    private var bestMetrics: BestSessionCalculator.BestDayMetrics? { cachedBestMetrics }
    private var lastModeIndicators: ProgressTracker.LastModeIndicators? { cachedLastModeIndicators }
    private var bestModeIndicators: ProgressTracker.BestModeIndicators? { cachedBestModeIndicators }

    // Current metrics based on mode (derived from cached values - cheap)
    private var currentMetrics: (date: Date?, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)? {
        switch comparisonMode {
        case .lastSession:
            guard let last = lastSessionMetrics else { return nil }
            return (last.date, last.maxWeight, last.maxReps, last.totalVolume, last.totalReps)
        case .allTimeBest:
            guard let best = bestMetrics else { return nil }
            return (best.date, best.maxWeight, best.repsAtMaxWeight, best.totalVolume, best.totalReps)
        }
    }

    // Header text — mode label with date in brackets
    private var headerText: String {
        guard let metrics = currentMetrics, let date = metrics.date else {
            return comparisonMode == .lastSession ? "Last Session" : "PB"
        }
        let dateStr = date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return comparisonMode == .lastSession ? "Last Session (\(dateStr))" : "PB (\(dateStr))"
    }

    // Whether the reference session was reps-only (bodyweight exercise)
    private var isRepsOnlyComparison: Bool {
        guard let metrics = currentMetrics else { return false }
        return metrics.maxWeight == 0
    }

    // Most recent set from today (sets are sorted most-recent-first)
    private var mostRecentWorkingSet: ExerciseSet? {
        todaysSets.first
    }

    // Check if today has any sets
    private var hasWorkingSets: Bool {
        !todaysSets.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Header — icon + "Last Session (date)" / "PB (date)" on left, mode picker on right
            HStack(spacing: 8) {
                Image(systemName: comparisonMode == .lastSession ? "calendar.badge.clock" : "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(comparisonMode == .lastSession
                        ? themeManager.effectiveTheme.chartColor2
                        : themeManager.effectiveTheme.pbColor)
                    .frame(width: 20)
                Text(headerText)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 8)

                Picker("Comparison Mode", selection: $comparisonMode) {
                    ForEach(ComparisonMode.allCases, id: \.self) { mode in
                        Text(mode == .lastSession ? "Last" : "PB").tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 120)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if let metrics = currentMetrics {
                // Reference Metrics — the big values (Max Weight, Reps, Total Volume)
                referenceValuesRow(metrics: metrics)

                // Gauges + Deltas + Footer Hint (see VerticalBarComparison.swift)
                VerticalBarComparison(
                    columns: buildBarColumns(from: metrics)
                )
            } else {
                // Empty state — no previous session data to compare against
                Text(comparisonMode == .lastSession
                    ? "Next session will compare weight, reps, and volume vs today"
                    : "Next session will compare weight, reps, and volume vs best ever")
                    .font(themeManager.effectiveTheme.interFont(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: comparisonMode)
        .onChange(of: sets) { _, _ in
            updateCache()
        }
        .onChange(of: comparisonMode) { _, _ in
            updateCache()
        }
        .onReceive(NotificationCenter.default.publisher(for: .setDataChanged)) { _ in
            updateCache()
        }
    }

    // MARK: - Reference Values Row

    /// Large display of the reference session's key metrics (sits above the bar chart)
    @ViewBuilder
    private func referenceValuesRow(metrics: (date: Date?, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)) -> some View {
        let isLastSession = comparisonMode == .lastSession
        let unit = themeManager.weightUnit == .kg ? "kg" : "lbs"

        HStack(spacing: 0) {
            if !isRepsOnlyComparison {
                referenceMetric(
                    label: "\(isLastSession ? "Max Weight" : "Weight") (\(unit))",
                    value: Formatters.formatWeight(themeManager.displayWeight(metrics.maxWeight))
                )
            }

            referenceMetric(
                label: isRepsOnlyComparison ? "Max Reps" : "Reps",
                value: "\(metrics.maxReps)"
            )

            referenceMetric(
                label: isRepsOnlyComparison
                    ? "Total Reps"
                    : "Total Volume (\(unit))",
                value: isRepsOnlyComparison
                    ? "\(metrics.totalReps)"
                    : Formatters.formatVolume(themeManager.displayWeight(metrics.totalVolume))
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func referenceMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.effectiveTheme.captionFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(themeManager.effectiveTheme.dataFont(size: 30, weight: .bold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Bar Chart Data Builder

    /// Label for the session best legend entry (e.g. "Best today (Set 2)")
    /// Build the bar column data from cached metrics for the VerticalBarComparison
    private func buildBarColumns(from metrics: (date: Date?, maxWeight: Double, maxReps: Int, totalVolume: Double, totalReps: Int)) -> [BarColumnData] {
        let lastSet = mostRecentWorkingSet
        let workingSetCount = todaysSets.count
        let isLastSession = comparisonMode == .lastSession
        let tol = ProgressTracker.weightTolerance

        if isRepsOnlyComparison {
            let lastSetReps = lastSet.map { Double($0.reps) }
            let repsDelta = lastSetReps.map { $0 - Double(metrics.maxReps) } ?? 0
            let repsIsSame = lastSetReps != nil && Int(repsDelta) == 0

            // Don't show session best if it matches the last set
            let bestReps = Double(cachedTodaysBestReps)
            let showBestReps = workingSetCount >= 2 && lastSetReps != bestReps

            let totalRepsDelta = Double(cachedTodaysTotalReps - metrics.totalReps)
            let totalIsSame = hasWorkingSets && Int(totalRepsDelta) == 0

            // Reps remaining hint for total reps
            let repsHint: String? = {
                guard hasWorkingSets else { return nil }
                if Int(totalRepsDelta) == 0 {
                    return "Total reps matched"
                } else if totalRepsDelta > 0 {
                    let count = Int(totalRepsDelta)
                    return "\(count) \(count == 1 ? "rep" : "reps") over total reps"
                } else {
                    let count = Int(abs(totalRepsDelta)) + 1
                    return "\(count) \(count == 1 ? "rep" : "reps") to beat total reps"
                }
            }()

            return [
                BarColumnData(
                    label: "Max Reps",
                    referenceValue: Double(metrics.maxReps),
                    sessionBestValue: showBestReps ? bestReps : nil,
                    lastSetValue: lastSetReps,
                    delta: repsDelta,
                    isUp: repsDelta > 0,
                    isSame: repsIsSame,
                    showSessionBest: showBestReps,
                    formatAsWeight: false
                ),
                BarColumnData(
                    label: "Total Reps",
                    referenceValue: Double(metrics.totalReps),
                    sessionBestValue: nil,
                    lastSetValue: hasWorkingSets ? Double(cachedTodaysTotalReps) : nil,
                    delta: totalRepsDelta,
                    isUp: totalRepsDelta > 0,
                    isSame: totalIsSame,
                    showSessionBest: false,
                    formatAsWeight: false,
                    volumeHint: repsHint
                )
            ]
        }

        // Weighted exercise: Weight, Reps, Total Volume
        let refWeight = themeManager.displayWeight(metrics.maxWeight)
        let bestWeight = themeManager.displayWeight(cachedTodaysBestWeight)
        let lastWeight = lastSet.map { themeManager.displayWeight($0.weight) }
        let weightDelta = lastWeight.map { $0 - refWeight } ?? 0
        let weightIsSame = lastWeight != nil && abs(weightDelta) < tol

        // Don't show session best bar if it matches the last set value
        let showBestWeight = workingSetCount >= 2
            && (lastWeight == nil || abs(bestWeight - (lastWeight ?? 0)) > tol)

        let lastSetReps = lastSet.map { Double($0.reps) }
        let repsDelta = lastSetReps.map { $0 - Double(metrics.maxReps) } ?? 0
        let repsIsSame = lastSetReps != nil && Int(repsDelta) == 0

        let bestReps = Double(cachedTodaysBestReps)
        let showBestReps = workingSetCount >= 2
            && (lastSetReps == nil || lastSetReps != bestReps)

        let refVolume = themeManager.displayWeight(metrics.totalVolume)
        let todayVolume = themeManager.displayWeight(cachedTodaysVolume)
        let volumeDelta = todayVolume - refVolume
        let volumeIsSame = hasWorkingSets && abs(volumeDelta) < tol

        // Calculate volume hint — how many reps to beat or exceed total volume
        let volumeHint: String? = {
            guard hasWorkingSets else { return nil }
            if abs(volumeDelta) < tol {
                return "Total volume matched"
            }
            if let weight = cachedLastSetWeight, weight > 0 {
                let displayWeight = themeManager.displayWeight(weight)
                if volumeDelta > tol {
                    let repsOver = Int(volumeDelta / displayWeight)
                    if repsOver > 0 {
                        return "\(repsOver) \(repsOver == 1 ? "rep" : "reps") over total volume"
                    }
                } else if volumeDelta < -tol {
                    let repsNeeded = Int(abs(volumeDelta) / displayWeight) + 1
                    return "\(repsNeeded) \(repsNeeded == 1 ? "rep" : "reps") to beat total volume"
                }
            }
            return nil
        }()

        return [
            BarColumnData(
                label: isLastSession ? "Max Weight" : "Weight",
                referenceValue: refWeight,
                sessionBestValue: showBestWeight ? bestWeight : nil,
                lastSetValue: lastWeight,
                delta: weightDelta,
                isUp: weightDelta > tol,
                isSame: weightIsSame,
                showSessionBest: showBestWeight,
                formatAsWeight: true
            ),
            BarColumnData(
                label: "Reps",
                referenceValue: Double(metrics.maxReps),
                sessionBestValue: showBestReps ? bestReps : nil,
                lastSetValue: lastSetReps,
                delta: repsDelta,
                isUp: repsDelta > 0,
                isSame: repsIsSame,
                showSessionBest: showBestReps,
                formatAsWeight: false
            ),
            BarColumnData(
                label: "Total Volume",
                referenceValue: refVolume,
                sessionBestValue: nil,
                lastSetValue: hasWorkingSets ? todayVolume : nil,
                delta: volumeDelta,
                isUp: volumeDelta > tol,
                isSame: volumeIsSame,
                showSessionBest: false,
                formatAsWeight: false,
                volumeHint: volumeHint
            )
        ]
    }

}
