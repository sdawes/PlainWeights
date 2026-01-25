//
//  ExerciseMetricsView.swift
//  PlainWeights
//
//  Displays exercise metrics with Last/Best mode toggle
//  Contains: picker, metric cards, progress bar, add set button
//

import SwiftUI
import SwiftData

// MARK: - Custom Alignment for Target Metrics

extension VerticalAlignment {
    private struct MainValueBaseline: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.firstTextBaseline]
        }
    }
    static let mainValueBaseline = VerticalAlignment(MainValueBaseline.self)
}

// MARK: - Dashed Line Shapes

/// Horizontal dashed line shape
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

/// Vertical dashed line shape
struct DashedVerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

// MARK: - Hero Metric Component

struct HeroMetricView: View {
    @Environment(ThemeManager.self) private var themeManager
    let weight: Double
    let reps: Int
    let totalVolume: Double
    let headerLabel: String
    let date: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: "LAST MAX WEIGHT" / "BEST EVER" label + date
            HStack {
                Text(headerLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                if let date = date {
                    Text(Formatters.formatAbbreviatedDayHeader(date))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Hero metric: Weight (large) × Reps (smaller, lighter)
            HStack(alignment: .center, spacing: 4) {
                Text("\(Formatters.formatWeight(weight)) kg")
                    .font(themeManager.currentTheme.dataFont(size: 34))
                    .foregroundStyle(.primary)
                Text("× \(reps) reps")
                    .font(themeManager.currentTheme.dataFont(size: 22))
                    .foregroundStyle(.secondary)
            }

            // Total weight (medium, secondary)
            HStack(spacing: 4) {
                Text("\(Formatters.formatVolume(totalVolume)) kg")
                    .font(themeManager.currentTheme.dataFont(size: 15))
                Text("total weight")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Progress Pill Component

struct ProgressPillView: View {
    let text: String
    let direction: ProgressTracker.PRDirection

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: direction == .up ? "arrow.up" :
                             direction == .down ? "arrow.down" : "minus")
                .font(.caption2)
                .foregroundStyle(.white)

            Text(text)
                .font(.caption)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(direction.color)
        .clipShape(Capsule())
    }
}

// MARK: - Metric Mode Enum

enum MetricMode: String, CaseIterable {
    case last = "Previous"
    case best = "Best"
}

// MARK: - Data Structures for Section Components

struct TargetMetricsData {
    let headerLabel: String
    let date: Date?
    let weight: Double
    let reps: Int
    let totalVolume: Double
    let isDropSet: Bool
    let isPauseAtTop: Bool
    let isTimedSet: Bool
    let tempoSeconds: Int
    let isPB: Bool
}

struct ThisSetData {
    let weight: String
    let reps: Int
    let isDropSet: Bool
    let isPauseAtTop: Bool
    let isTimedSet: Bool
    let tempoSeconds: Int
    let isPB: Bool
    let comparisonLabel: String
    let weightProgress: (text: String, direction: ProgressTracker.PRDirection)?
    let repsProgress: (text: String, direction: ProgressTracker.PRDirection)?
}

struct ProgressBarData {
    let progressRatio: CGFloat
    let unclampedRatio: CGFloat
    let barFillColor: Color
    let progressText: String
}

// MARK: - TargetMetricsSection Component

struct TargetMetricsSection: View {
    @Environment(ThemeManager.self) private var themeManager
    let data: TargetMetricsData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: "LAST MAX WEIGHT" / "BEST EVER" label + date
            HStack {
                Text(data.headerLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                if let date = data.date {
                    Text(Formatters.formatAbbreviatedDayHeader(date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Metric values: Weight × Reps with set indicator icons
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(Formatters.formatWeight(data.weight)) kg")
                    .font(themeManager.currentTheme.dataFont(size: 38))
                    .foregroundStyle(.primary)
                Text("× \(data.reps) reps")
                    .font(themeManager.currentTheme.dataFont(size: 22))
                    .foregroundStyle(.secondary)

                // Set indicator icons (matching ThisSetSection design)
                if data.isDropSet {
                    Image(systemName: "chevron.down.2")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                }

                if data.isPauseAtTop {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary)
                }

                if data.isTimedSet {
                    if data.tempoSeconds > 0 {
                        Text("\(data.tempoSeconds)")
                            .font(themeManager.currentTheme.dataFont(size: 10))
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                if data.isPB {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary)
                }
            }

            // Total weight (will have picker added by parent)
            HStack(spacing: 4) {
                Text("\(Formatters.formatVolume(data.totalVolume)) kg")
                    .font(themeManager.currentTheme.dataFont(size: 15))
                Text("total weight")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            .padding(.top, 0)
        }
    }
}

// MARK: - TargetMetricsSection with Picker

struct TargetMetricsSectionWithPicker: View {
    @Environment(ThemeManager.self) private var themeManager
    let data: TargetMetricsData
    @Binding var selectedMode: MetricMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: "LAST MAX WEIGHT" / "BEST EVER" label + date
            HStack {
                Text(data.headerLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                if let date = data.date {
                    Text(Formatters.formatAbbreviatedDayHeader(date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 140, alignment: .trailing)  // Match picker width for alignment
                }
            }

            // Metric values: Weight × Reps with set indicator icons
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(Formatters.formatWeight(data.weight)) kg")
                    .font(themeManager.currentTheme.dataFont(size: 38))
                    .foregroundStyle(.primary)
                Text("× \(data.reps) reps")
                    .font(themeManager.currentTheme.dataFont(size: 22))
                    .foregroundStyle(.secondary)

                // Set indicator icons
                if data.isDropSet {
                    Image(systemName: "chevron.down.2")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                }

                if data.isPauseAtTop {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary)
                }

                if data.isTimedSet {
                    if data.tempoSeconds > 0 {
                        Text("\(data.tempoSeconds)")
                            .font(themeManager.currentTheme.dataFont(size: 10))
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                if data.isPB {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary)
                }
            }

            // Total weight with picker in same HStack for baseline alignment
            HStack(alignment: .lastTextBaseline) {
                HStack(spacing: 4) {
                    Text("\(Formatters.formatVolume(data.totalVolume)) kg")
                        .font(themeManager.currentTheme.dataFont(size: 15))
                    Text("total weight")
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)

                Spacer()

                // Mini segmented picker (baseline-aligned with total volume)
                Picker("Mode", selection: $selectedMode) {
                    Text("Previous").tag(MetricMode.last)
                    Text("Best").tag(MetricMode.best)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 140)
                .scaleEffect(0.75, anchor: .trailing)  // Anchor to trailing edge for right alignment
            }
            .padding(.top, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - ThisSetSection Component

struct ThisSetSection: View {
    @Environment(ThemeManager.self) private var themeManager
    let data: ThisSetData
    let lastSetTimestamp: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                // Header row with "THIS SET" and "vs last session"
                HStack {
                    Text("THIS SET")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Spacer()

                    Text(data.comparisonLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Set values
                HStack(alignment: .center, spacing: 6) {
                    Text("\(data.weight) kg")
                        .font(themeManager.currentTheme.dataFont(size: 20))
                        .foregroundStyle(.primary)

                    Text("× \(data.reps) reps")
                        .font(themeManager.currentTheme.dataFont(size: 16))
                        .foregroundStyle(.secondary)

                    if data.isDropSet {
                        Image(systemName: "chevron.down.2")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.primary)
                    }

                    if data.isPauseAtTop {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                    }

                    if data.isTimedSet {
                        if data.tempoSeconds > 0 {
                            Text("\(data.tempoSeconds)")
                                .font(themeManager.currentTheme.dataFont(size: 12))
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "timer")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    if data.isPB {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                    }
                }
            }

            // Progress pills and timer
            HStack(alignment: .bottom, spacing: 8) {
                // Progress pills
                HStack(spacing: 8) {
                    if let progress = data.weightProgress {
                        ProgressPillView(text: progress.text, direction: progress.direction)
                    }

                    if let repsProgress = data.repsProgress {
                        ProgressPillView(text: repsProgress.text, direction: repsProgress.direction)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - ProgressBarSection Component

struct ProgressBarSection: View {
    let data: ProgressBarData

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Thin progress bar
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    // Track (4pt tall), centred within an 8pt area
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                        .frame(maxHeight: .infinity, alignment: .center)

                    // Progress bar fill (uses primary color)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary)
                        .frame(width: g.size.width * data.progressRatio, height: 4)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
                .frame(height: 12)
            }
            .frame(height: 12)
            .frame(maxWidth: .infinity)

            // Progress percentage text (right-aligned)
            Text(data.progressText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - MetricViewStats Wrapper Component

struct MetricViewStats: View {
    let targetMetrics: TargetMetricsData
    let thisSet: ThisSetData?
    let progressBar: ProgressBarData
    let lastSetTimestamp: Date?
    let exercise: Exercise
    let sets: [ExerciseSet]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Target Metrics Section (always visible)
            TargetMetricsSection(data: targetMetrics)

            // 2. Chart Content (always visible)
            ChartContentView(exercise: exercise, sets: sets)
                .padding(.top, 32)

            // 3. Only show remaining sections if sets added today
            if let setData = thisSet {
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                // This Set Section
                ThisSetSection(data: setData, lastSetTimestamp: lastSetTimestamp)
                    .padding(.bottom, 11)

                // Progress Bar Section
                ProgressBarSection(data: progressBar)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Card Components

/// Card 2: Target Metrics - Combined Baseline (Previous) and Upper Target (Best)
struct TargetMetricsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let exercise: Exercise
    let sets: [ExerciseSet]

    // Cached progress state (for previous session)
    private var progressState: ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }

    // Sets excluding today (for Best metrics)
    private var setsExcludingToday: [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) < today }
    }

    // Best day metrics
    private var bestDayMetrics: BestSessionCalculator.BestDayMetrics? {
        BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)
    }

    // Today's most recent working set
    private var todaysLastWorkingSet: ExerciseSet? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.first { set in
            calendar.startOfDay(for: set.timestamp) == today && !set.isWarmUp && !set.isBonus
        }
    }

    // Weight delta (today's last set vs previous session)
    private var weightDelta: Double? {
        guard let todaySet = todaysLastWorkingSet,
              let lastInfo = progressState?.lastCompletedDayInfo else { return nil }
        return todaySet.weight - lastInfo.maxWeight
    }

    // Reps delta (today's last set vs previous session)
    private var repsDelta: Int? {
        guard let todaySet = todaysLastWorkingSet,
              let lastInfo = progressState?.lastCompletedDayInfo else { return nil }
        return todaySet.reps - lastInfo.maxWeightReps
    }

    // Progress color for weight
    private var weightProgressColor: Color {
        guard let delta = weightDelta else { return .clear }
        if delta > 0 { return themeManager.currentTheme.progressUp }
        if delta < 0 { return themeManager.currentTheme.progressDown }
        return themeManager.currentTheme.progressSame
    }

    // Progress color for reps
    private var repsProgressColor: Color {
        guard let delta = repsDelta else { return .clear }
        if delta > 0 { return themeManager.currentTheme.progressUp }
        if delta < 0 { return themeManager.currentTheme.progressDown }
        return themeManager.currentTheme.progressSame
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let lastInfo = progressState?.lastCompletedDayInfo {
                // Row 1: Header (outside Grid for simplicity)
                HStack {
                    Text("PREVIOUS SESSION")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(Formatters.formatRelativeDate(lastInfo.date))
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                }

                // Grid for values (ensures column alignment)
                Grid(alignment: .leading, horizontalSpacing: 4, verticalSpacing: 4) {
                    // Row 2: Main values
                    GridRow(alignment: .lastTextBaseline) {
                        // Col 1: Weight
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(Formatters.formatWeight(lastInfo.maxWeight))
                                .font(themeManager.currentTheme.dataFont(size: 32, weight: .bold))
                                .foregroundStyle(themeManager.currentTheme.primaryText)
                            Text(" kg")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }

                        // Col 2: ×
                        Text("×")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)

                        // Col 3: Reps
                        Text("\(lastInfo.maxWeightReps)")
                            .font(themeManager.currentTheme.dataFont(size: 20, weight: .bold))
                            .foregroundStyle(themeManager.currentTheme.primaryText)

                        // Col 4: Total (right-aligned)
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Spacer()
                            Text(Formatters.formatVolume(lastInfo.volume))
                                .font(themeManager.currentTheme.dataFont(size: 12, weight: .bold))
                                .foregroundStyle(themeManager.currentTheme.primaryText)
                            Text(" total kg")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Row 3: Progress values (only if data exists)
                    if weightDelta != nil || repsDelta != nil {
                        GridRow(alignment: .firstTextBaseline) {
                            // Col 1: Weight progress
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(weightDelta.map { $0 > 0 ? "+\(Int($0))" : "\(Int($0))" } ?? "")
                                    .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                                    .foregroundStyle(weightProgressColor)
                                Text("kg")
                                    .font(.system(size: 14))
                                    .foregroundStyle(weightProgressColor)
                            }

                            // Col 2: × (invisible, maintains column)
                            Text("×")
                                .font(.system(size: 14))
                                .foregroundStyle(.clear)

                            // Col 3: Reps progress
                            Text(repsDelta.map { $0 > 0 ? "+\($0)" : "\($0)" } ?? "")
                                .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                                .foregroundStyle(repsProgressColor)

                            // Col 4: Empty
                            Color.clear
                        }
                    }
                }
            } else {
                Text("Previous session metrics will appear tomorrow")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .foregroundStyle(themeManager.currentTheme.textColor)
    }

    // MARK: - Badge Helper

    @ViewBuilder
    private func badgesView(isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool) -> some View {
        HStack(spacing: 3) {
            if isDropSet {
                Image(systemName: "chevron.down.2")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary)
            }

            if isPauseAtTop {
                Image(systemName: "pause.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
            }

            if isTimedSet {
                if tempoSeconds > 0 {
                    Text("\(tempoSeconds)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "timer")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            if isPB {
                Text("PB")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

/// Card 3: Chart Only
struct ChartCard: View {
    let exercise: Exercise
    let sets: [ExerciseSet]

    var body: some View {
        ChartContentView(exercise: exercise, sets: sets)
    }
}

/// Card 4: This Set Metrics + Progress Bar
struct ThisSetCard: View {
    let exercise: Exercise
    let sets: [ExerciseSet]
    let selectedMode: MetricMode

    // Cached progress state
    private var progressState: ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }

    // Sets excluding today
    private var setsExcludingToday: [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) < today }
    }

    // Today's sets
    private var todaySets: [ExerciseSet] {
        TodaySessionCalculator.getTodaysSets(from: sets)
    }

    // Last set timestamp
    private var lastSetTimestamp: Date? {
        todaySets.first(where: { !$0.isWarmUp && !$0.isBonus })?.timestamp
    }

    // Best day metrics
    private var bestDayMetrics: BestSessionCalculator.BestDayMetrics? {
        BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)
    }

    // Comparison weight
    private var comparisonWeight: Double? {
        if selectedMode == .best {
            return bestDayMetrics?.maxWeight
        } else {
            return progressState?.lastCompletedDayInfo?.maxWeight
        }
    }

    // Comparison reps
    private var comparisonReps: Int? {
        if selectedMode == .best {
            return bestDayMetrics?.repsAtMaxWeight
        } else {
            return progressState?.lastCompletedDayInfo?.maxWeightReps
        }
    }

    // Target volume
    private var targetVolume: Double {
        if selectedMode == .best {
            return bestDayMetrics?.totalVolume ?? 0
        } else {
            return progressState?.lastCompletedDayInfo?.volume ?? 0
        }
    }

    // Progress bar ratio
    private var progressBarRatio: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressBarRatio)
    }

    // Unclamped progress ratio (can exceed 1.0)
    private var progressRatioUnclamped: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressRatioUnclamped)
    }

    // Progress percentage
    private var progressPercentage: Int {
        guard let state = progressState else { return 0 }
        guard targetVolume > 0 else { return 0 }
        return Int(round((state.todayVolume / targetVolume) * 100))
    }

    // Formatted progress text
    private var formattedProgressText: String {
        let percentage = progressPercentage
        if selectedMode == .best {
            return "\(percentage)% of best total volume"
        } else {
            return "\(percentage)% of last total volume"
        }
    }

    private func buildThisSetData() -> ThisSetData? {
        guard let setInfo = formatThisSet() else { return nil }

        return ThisSetData(
            weight: setInfo.weight,
            reps: setInfo.reps,
            isDropSet: setInfo.isDropSet,
            isPauseAtTop: setInfo.isPauseAtTop,
            isTimedSet: setInfo.isTimedSet,
            tempoSeconds: setInfo.tempoSeconds,
            isPB: setInfo.isPB,
            comparisonLabel: selectedMode == .best ? "vs best ever" : "vs last session",
            weightProgress: formatThisSetProgress(),
            repsProgress: formatThisSetRepsProgress()
        )
    }

    private func buildProgressBarData() -> ProgressBarData {
        return ProgressBarData(
            progressRatio: progressBarRatio,
            unclampedRatio: progressRatioUnclamped,
            barFillColor: progressState?.barFillColor ?? .primary,
            progressText: formattedProgressText
        )
    }

    private func formatThisSet() -> (weight: String, reps: Int, isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }) else {
            return nil
        }

        let weight = Formatters.formatWeight(lastWorkingSet.weight)
        let reps = lastWorkingSet.reps

        return (weight, reps, lastWorkingSet.isDropSet, lastWorkingSet.isPauseAtTop, lastWorkingSet.isTimedSet, lastWorkingSet.tempoSeconds, lastWorkingSet.isPB)
    }

    private func formatThisSetProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }),
              let comparison = comparisonWeight else {
            return nil
        }

        let diff = lastWorkingSet.weight - comparison

        let direction: ProgressTracker.PRDirection
        let text: String

        if diff > 0 {
            direction = .up
            text = "+\(Formatters.formatWeight(diff)) kg"
        } else if diff < 0 {
            direction = .down
            text = "\(Formatters.formatWeight(diff)) kg"
        } else {
            direction = .same
            text = "0 kg"
        }

        return (text, direction)
    }

    private func formatThisSetRepsProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }),
              let comparison = comparisonReps else {
            return nil
        }

        let diff = lastWorkingSet.reps - comparison

        let direction: ProgressTracker.PRDirection
        let text: String

        if diff > 0 {
            direction = .up
            text = "+\(diff) reps"
        } else if diff < 0 {
            direction = .down
            text = "\(diff) reps"
        } else {
            direction = .same
            text = "0 reps"
        }

        return (text, direction)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let setData = buildThisSetData() {
                // This Set Section
                ThisSetSection(data: setData, lastSetTimestamp: lastSetTimestamp)
                    .padding(.bottom, 11)

                // Progress Bar Section
                ProgressBarSection(data: buildProgressBarData())
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - ExerciseMetricsView (Legacy - kept for compatibility)

struct ExerciseMetricsView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]
    let selectedMode: MetricMode
    @Binding var addSetConfig: AddSetConfig?

    // MARK: - Computed Properties

    // Cached progress state
    private var progressState: ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }

    // Sets excluding today (for Best metrics - should only show PRs from previous days)
    private var setsExcludingToday: [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) < today }
    }

    // Today's sets
    private var todaySets: [ExerciseSet] {
        TodaySessionCalculator.getTodaysSets(from: sets)
    }

    // Last set timestamp (for rest timer)
    private var lastSetTimestamp: Date? {
        todaySets.first(where: { !$0.isWarmUp && !$0.isBonus })?.timestamp
    }

    // Best day metrics (excludes today's sets - only shows all-time PRs from previous days)
    private var bestDayMetrics: BestSessionCalculator.BestDayMetrics? {
        BestSessionCalculator.calculateBestDayMetrics(from: setsExcludingToday)
    }

    // Best mode indicators (today vs all-time best)
    private var bestModeIndicators: ProgressTracker.BestModeIndicators? {
        ProgressTracker.calculateBestModeIndicators(
            todaySets: todaySets,
            bestMetrics: bestDayMetrics
        )
    }

    /// Get the weight and reps values from the last working set (all-time, for pre-filling form)
    private var lastWorkingSetValues: (weight: Double?, reps: Int?) {
        guard let lastWorkingSet = sets.first(where: { !$0.isWarmUp && !$0.isBonus }) else {
            return (nil, nil)
        }
        return (lastWorkingSet.weight, lastWorkingSet.reps)
    }

    // Progress bar ratio
    private var progressBarRatio: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressBarRatio)
    }

    // Unclamped progress ratio (can exceed 1.0)
    private var progressRatioUnclamped: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressRatioUnclamped)
    }

    // Target volume based on selected mode (Last vs Best)
    private var targetVolume: Double {
        if selectedMode == .best {
            return bestDayMetrics?.totalVolume ?? 0
        } else {
            return progressState?.lastCompletedDayInfo?.volume ?? 0
        }
    }

    // Comparison weight based on selected mode (Last vs Best)
    private var comparisonWeight: Double? {
        if selectedMode == .best {
            return bestDayMetrics?.maxWeight
        } else {
            return progressState?.lastCompletedDayInfo?.maxWeight
        }
    }

    // Comparison reps based on selected mode (Last vs Best)
    private var comparisonReps: Int? {
        if selectedMode == .best {
            return bestDayMetrics?.repsAtMaxWeight
        } else {
            return progressState?.lastCompletedDayInfo?.maxWeightReps
        }
    }

    // Progress percentage (0-100+)
    private var progressPercentage: Int {
        guard let state = progressState else { return 0 }
        guard targetVolume > 0 else { return 0 }
        return Int(round((state.todayVolume / targetVolume) * 100))
    }

    // Remaining volume to reach target
    private var remainingVolume: Double {
        guard let state = progressState else { return 0 }
        let remaining = targetVolume - state.todayVolume
        return max(0, remaining) // Don't show negative
    }

    // Formatted progress text: mode-aware
    private var formattedProgressText: String {
        let percentage = progressPercentage
        if selectedMode == .best {
            return "\(percentage)% of best total volume"
        } else {
            return "\(percentage)% of last total volume"
        }
    }

    private func formatLastSessionSummary() -> (text: String, date: Date?) {
        if selectedMode == .best {
            // Best Ever mode
            if let best = bestDayMetrics {
                let weight = Formatters.formatWeight(best.maxWeight)
                let reps = best.repsAtMaxWeight
                let volume = Formatters.formatVolume(best.totalVolume)
                return ("Best: \(weight) kg × \(reps) reps · \(volume) kg total", best.date)
            } else {
                return ("Best: 0 kg × 0 reps · 0 kg total", nil)
            }
        } else {
            // Last Session mode
            if let lastInfo = progressState?.lastCompletedDayInfo {
                let weight = Formatters.formatWeight(lastInfo.maxWeight)
                let reps = lastInfo.maxWeightReps
                let volume = Formatters.formatVolume(lastInfo.volume)
                return ("Last: \(weight) kg × \(reps) reps · \(volume) kg total", lastInfo.date)
            } else {
                return ("Last: 0 kg × 0 reps · 0 kg total", nil)
            }
        }
    }

    private func formatThisSet() -> (weight: String, reps: Int, isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool)? {
        // Get the most recent working set from today (skip warm-ups)
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }) else {
            return nil
        }

        let weight = Formatters.formatWeight(lastWorkingSet.weight)
        let reps = lastWorkingSet.reps

        return (weight, reps, lastWorkingSet.isDropSet, lastWorkingSet.isPauseAtTop, lastWorkingSet.isTimedSet, lastWorkingSet.tempoSeconds, lastWorkingSet.isPB)
    }

    private func formatThisSetProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }),
              let comparison = comparisonWeight else {
            return nil
        }

        let diff = lastWorkingSet.weight - comparison

        let direction: ProgressTracker.PRDirection
        let text: String

        if diff > 0 {
            direction = .up
            text = "+\(Formatters.formatWeight(diff)) kg"
        } else if diff < 0 {
            direction = .down
            text = "\(Formatters.formatWeight(diff)) kg" // formatWeight includes minus sign
        } else {
            direction = .same
            text = "0 kg"
        }

        return (text, direction)
    }

    private func formatThisSetRepsProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp && !$0.isBonus }),
              let comparison = comparisonReps else {
            return nil
        }

        let diff = lastWorkingSet.reps - comparison

        let direction: ProgressTracker.PRDirection
        let text: String

        if diff > 0 {
            direction = .up
            text = "+\(diff) reps"
        } else if diff < 0 {
            direction = .down
            text = "\(diff) reps" // includes minus sign
        } else {
            direction = .same
            text = "0 reps"
        }

        return (text, direction)
    }

    private func formatThisSetVolumeProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let state = progressState else { return nil }

        let todayVolume = state.todayVolume
        let comparisonVolume: Double

        // Switch based on selected mode
        if selectedMode == .best {
            guard let best = bestDayMetrics else { return nil }
            comparisonVolume = best.totalVolume
        } else {
            comparisonVolume = state.lastCompletedDayInfo?.volume ?? 0
        }

        let diff = todayVolume - comparisonVolume

        let direction: ProgressTracker.PRDirection
        if diff > 0 {
            direction = .up
        } else if diff < 0 {
            direction = .down
        } else {
            direction = .same
        }

        let text: String
        if diff > 0 {
            text = "+\(Formatters.formatVolume(diff)) kg total"
        } else if diff < 0 {
            text = "\(Formatters.formatVolume(diff)) kg total" // includes minus sign
        } else {
            text = "0 kg total"
        }

        return (text, direction)
    }

    // MARK: - Data Builders

    private func buildTargetMetricsData() -> TargetMetricsData {
        let summary = formatLastSessionSummary()

        if selectedMode == .best {
            if let best = bestDayMetrics {
                return TargetMetricsData(
                    headerLabel: "BEST EVER",
                    date: summary.date,
                    weight: best.maxWeight,
                    reps: best.repsAtMaxWeight,
                    totalVolume: best.totalVolume,
                    isDropSet: best.isDropSet,
                    isPauseAtTop: best.isPauseAtTop,
                    isTimedSet: best.isTimedSet,
                    tempoSeconds: best.tempoSeconds,
                    isPB: best.isPB
                )
            } else {
                return TargetMetricsData(
                    headerLabel: "BEST EVER",
                    date: nil,
                    weight: 0,
                    reps: 0,
                    totalVolume: 0,
                    isDropSet: false,
                    isPauseAtTop: false,
                    isTimedSet: false,
                    tempoSeconds: 0,
                    isPB: false
                )
            }
        } else {
            if let lastInfo = progressState?.lastCompletedDayInfo {
                return TargetMetricsData(
                    headerLabel: "LAST MAX WEIGHT",
                    date: summary.date,
                    weight: lastInfo.maxWeight,
                    reps: lastInfo.maxWeightReps,
                    totalVolume: lastInfo.volume,
                    isDropSet: lastInfo.isDropSet,
                    isPauseAtTop: lastInfo.isPauseAtTop,
                    isTimedSet: lastInfo.isTimedSet,
                    tempoSeconds: lastInfo.tempoSeconds,
                    isPB: lastInfo.isPB
                )
            } else {
                return TargetMetricsData(
                    headerLabel: "LAST MAX WEIGHT",
                    date: nil,
                    weight: 0,
                    reps: 0,
                    totalVolume: 0,
                    isDropSet: false,
                    isPauseAtTop: false,
                    isTimedSet: false,
                    tempoSeconds: 0,
                    isPB: false
                )
            }
        }
    }

    private func buildThisSetData() -> ThisSetData? {
        guard let setInfo = formatThisSet() else { return nil }

        return ThisSetData(
            weight: setInfo.weight,
            reps: setInfo.reps,
            isDropSet: setInfo.isDropSet,
            isPauseAtTop: setInfo.isPauseAtTop,
            isTimedSet: setInfo.isTimedSet,
            tempoSeconds: setInfo.tempoSeconds,
            isPB: setInfo.isPB,
            comparisonLabel: selectedMode == .best ? "vs best ever" : "vs last session",
            weightProgress: formatThisSetProgress(),
            repsProgress: formatThisSetRepsProgress()
        )
    }

    private func buildProgressBarData() -> ProgressBarData {
        return ProgressBarData(
            progressRatio: progressBarRatio,
            unclampedRatio: progressRatioUnclamped,
            barFillColor: progressState?.barFillColor ?? .primary,
            progressText: formattedProgressText
        )
    }

    // MARK: - Body

    var body: some View {
        // Metric View Stats (contains all three sections + divider)
        MetricViewStats(
            targetMetrics: buildTargetMetricsData(),
            thisSet: buildThisSetData(),
            progressBar: buildProgressBarData(),
            lastSetTimestamp: lastSetTimestamp,
            exercise: exercise,
            sets: sets
        )
    }
}
