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
            // Header section
            HStack(spacing: 8) {
                Image(systemName: comparisonMode == .lastSession ? "calendar.badge.clock" : "star.fill")
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(headerText)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
            }
            .foregroundStyle(themeManager.effectiveTheme.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider below header
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
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
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)

                // Comparison row - colored background cells (show '-' when no working sets)
                HStack(spacing: 1) {
                    comparisonCell(direction: hasWorkingSets ? weightDirection : nil, value: hasWorkingSets ? weightDelta : nil)
                    comparisonCell(direction: hasWorkingSets ? repsDirection : nil, value: hasWorkingSets ? repsDelta : nil, isReps: true)
                    comparisonCell(direction: hasWorkingSets ? totalDirection : nil, value: hasWorkingSets ? totalDelta : nil)
                }
                .background(themeManager.effectiveTheme.borderColor)
            } else {
                // Empty state
                Text("No data yet")
                    .font(themeManager.effectiveTheme.subheadlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .center)
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
    }

    // MARK: - Metric Column Helper

    @ViewBuilder
    private func metricColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.effectiveTheme.captionFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            Text(value)
                .font(themeManager.effectiveTheme.dataFont(size: 22, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
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
                        .font(themeManager.effectiveTheme.dataFont(size: 14, weight: .bold))
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
