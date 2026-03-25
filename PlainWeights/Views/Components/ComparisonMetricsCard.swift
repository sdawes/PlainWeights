//
//  ComparisonMetricsCard.swift
//  PlainWeights
//
//  Comparison metrics card component showing last session or all-time best metrics.
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
    let comparisonMode: ComparisonMode
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

    init(comparisonMode: ComparisonMode, sets: [ExerciseSet], todayDeltas: ExerciseDeltas = .empty) {
        self.comparisonMode = comparisonMode
        self.sets = sets
        self.todayDeltas = todayDeltas

        // Pre-compute all metrics during init
        let computed = Self.computeAllMetrics(sets: sets, comparisonMode: comparisonMode)
        _cachedTodaysSets = State(initialValue: computed.todaysSets)
        _cachedSetsExcludingToday = State(initialValue: computed.setsExcludingToday)
        _cachedLastSessionMetrics = State(initialValue: computed.lastSessionMetrics)
        _cachedBestMetrics = State(initialValue: computed.bestMetrics)
        _cachedLastModeIndicators = State(initialValue: computed.lastModeIndicators)
        _cachedBestModeIndicators = State(initialValue: computed.bestModeIndicators)
        _cachedTodaysVolume = State(initialValue: computed.todaysVolume)
        _cachedTodaysTotalReps = State(initialValue: computed.todaysTotalReps)
        _cachedLastSetWeight = State(initialValue: computed.lastSetWeight)
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
                let todaysTotalReps = todaysSets.workingSets.reduce(0) { $0 + $1.reps }

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
            todaysTotalReps: todaysSets.workingSets.reduce(0) { $0 + $1.reps },
            lastSetWeight: todaysSets.first(where: { !$0.isWarmUp })?.weight
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

    // Conditional total: use totalReps for reps-only, volume for weighted
    private var isRepsOnlyComparison: Bool {
        // Check if comparison session was reps-only
        guard let metrics = currentMetrics else { return false }
        return metrics.maxWeight == 0
    }

    private var totalDirection: ProgressTracker.PRDirection? {
        if isRepsOnlyComparison {
            // Use total reps direction
            if let indicators = lastModeIndicators { return indicators.totalRepsDirection }
            if let indicators = bestModeIndicators { return indicators.totalRepsDirection }
        } else {
            // Use volume direction
            if let indicators = lastModeIndicators { return indicators.volumeDirection }
            if let indicators = bestModeIndicators { return indicators.volumeDirection }
        }
        return nil
    }

    private var totalDelta: Double? {
        if isRepsOnlyComparison {
            // Use total reps delta
            if let indicators = lastModeIndicators { return Double(indicators.totalRepsImprovement) }
            if let indicators = bestModeIndicators { return Double(indicators.totalRepsImprovement) }
        } else {
            // Use volume delta
            if let indicators = lastModeIndicators { return indicators.volumeImprovement }
            if let indicators = bestModeIndicators { return indicators.volumeImprovement }
        }
        return nil
    }

    // MARK: - Cell-Specific Deltas (most recent set vs reference)

    // Most recent working set from today (sets are sorted most-recent-first)
    private var mostRecentWorkingSet: ExerciseSet? {
        todaysSets.first(where: { !$0.isWarmUp })
    }

    // Cell weight: most recent set's weight vs reference max weight
    private var cellWeightDirection: ProgressTracker.PRDirection? {
        guard lastModeIndicators != nil || bestModeIndicators != nil else { return nil }
        guard let set = mostRecentWorkingSet, let metrics = currentMetrics else { return nil }
        let diff = set.weight - metrics.maxWeight
        let t = ProgressTracker.weightTolerance
        if diff > t { return .up }
        if diff < -t { return .down }
        return .same
    }

    private var cellWeightDelta: Double? {
        guard lastModeIndicators != nil || bestModeIndicators != nil else { return nil }
        guard let set = mostRecentWorkingSet, let metrics = currentMetrics else { return nil }
        let diff = set.weight - metrics.maxWeight
        return abs(diff) < ProgressTracker.weightTolerance ? 0 : diff
    }

    // Cell reps: most recent set's reps vs reference reps at max weight
    private var cellRepsDirection: ProgressTracker.PRDirection? {
        guard lastModeIndicators != nil || bestModeIndicators != nil else { return nil }
        guard let set = mostRecentWorkingSet, let metrics = currentMetrics else { return nil }
        let diff = set.reps - metrics.maxReps
        if diff > 0 { return .up }
        if diff < 0 { return .down }
        return .same
    }

    private var cellRepsDelta: Double? {
        guard lastModeIndicators != nil || bestModeIndicators != nil else { return nil }
        guard let set = mostRecentWorkingSet, let metrics = currentMetrics else { return nil }
        return Double(set.reps - metrics.maxReps)
    }

    // Check if today has sets (derived - cheap)
    private var hasTodaySets: Bool {
        !todaysSets.isEmpty
    }

    // Check if today has working sets (derived - cheap)
    private var hasWorkingSets: Bool {
        todaysSets.contains { !$0.isWarmUp }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            HStack(spacing: 8) {
                Image(systemName: comparisonMode == .lastSession ? "calendar.badge.clock" : "star.fill")
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(headerText)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))

                Spacer()

                Text(themeManager.weightUnit == .kg ? "kgs" : "lbs")
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
            .foregroundStyle(themeManager.effectiveTheme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider below header
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            if let metrics = currentMetrics {
                // Metrics row with labels
                HStack(spacing: 0) {
                    metricColumn(
                        label: comparisonMode == .lastSession ? "Max Weight" : "Weight",
                        value: Formatters.formatWeight(themeManager.displayWeight(metrics.maxWeight)),
                        beaten: hasWorkingSets ? todayDeltas.weight : nil
                    )
                    metricColumn(
                        label: "Reps",
                        value: "\(metrics.maxReps)",
                        beaten: hasWorkingSets ? todayDeltas.reps : nil
                    )
                    metricColumn(
                        label: isRepsOnlyComparison ? "Total Reps" : "Total Volume",
                        value: isRepsOnlyComparison ? "\(metrics.totalReps)" : Formatters.formatVolume(themeManager.displayWeight(metrics.totalVolume)),
                        beaten: hasWorkingSets ? todayDeltas.volume : nil
                    )
                }
                .padding(.vertical, 12)

                // Divider above last-set comparison row
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)

                // Last-set comparison row (show '-' when no working sets)
                HStack(spacing: 1) {
                    comparisonCell(direction: hasWorkingSets ? cellWeightDirection : nil, value: hasWorkingSets ? cellWeightDelta : nil)
                    comparisonCell(direction: hasWorkingSets ? cellRepsDirection : nil, value: hasWorkingSets ? cellRepsDelta : nil, isReps: true)
                    // Conditional: show reps delta for reps-only, volume delta for weighted
                    comparisonCell(direction: hasWorkingSets ? totalDirection : nil, value: hasWorkingSets ? totalDelta : nil, isReps: isRepsOnlyComparison)
                }
                .background(themeManager.effectiveTheme.borderColor)

                // Volume progress bar
                if hasTodaySets {
                    Rectangle()
                        .fill(themeManager.effectiveTheme.borderColor)
                        .frame(height: 1)

                    if isRepsOnlyComparison && metrics.totalReps > 0 {
                        VolumeProgressBar(
                            currentVolume: Double(cachedTodaysTotalReps),
                            targetVolume: Double(metrics.totalReps),
                            targetLabel: comparisonMode == .lastSession ? "Last" : "Best",
                            isRepsOnly: true
                        )
                        .padding(16)
                    } else if !isRepsOnlyComparison && metrics.totalVolume > 0 {
                        VolumeProgressBar(
                            currentVolume: cachedTodaysVolume,
                            targetVolume: metrics.totalVolume,
                            targetLabel: comparisonMode == .lastSession ? "Last" : "Best",
                            isRepsOnly: false,
                            lastSetWeight: cachedLastSetWeight
                        )
                        .padding(16)
                    }
                }
            } else {
                // First session empty state
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
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

    // MARK: - Metric Column Helper

    @ViewBuilder
    private func metricColumn(label: String, value: String, beaten: DeltaDirection? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                Text(label)
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Spacer()
                if let beaten {
                    Image(systemName: beaten == .up ? "checkmark.circle.fill" : beaten == .down ? "xmark.circle" : "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(beaten == .up ? .green : beaten == .down ? .red : themeManager.effectiveTheme.mutedForeground.opacity(0.4))
                }
            }
            .lineLimit(1)
            Text(value)
                .font(themeManager.effectiveTheme.dataFont(size: 24, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Comparison Cell Helper

    @ViewBuilder
    private func comparisonCell(direction: ProgressTracker.PRDirection?, value: Double?, isReps: Bool = false) -> some View {
        Group {
            if hasTodaySets, let direction = direction, let value = value, direction != .same {
                // Up or down - colored background with white text
                let displayValue = isReps ? "\(Int(value))" : Formatters.formatWeight(themeManager.displayWeight(value))
                let prefix = direction == .up ? "+" : ""
                HStack {
                    Text("\(prefix)\(displayValue)")
                        .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(direction == .up ? Color.green : Color.red)
            } else {
                // No data - show dash
                HStack {
                    Text("—")
                        .font(themeManager.effectiveTheme.interFont(size: 14))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground.opacity(0.3))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(themeManager.effectiveTheme.cardBackgroundColor)
            }
        }
    }

}
