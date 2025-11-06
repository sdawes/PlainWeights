//
//  ExerciseMetricsView.swift
//  PlainWeights
//
//  Displays exercise metrics with Last/Best mode toggle
//  Contains: picker, metric cards, progress bar, add set button
//

import SwiftUI
import SwiftData

// MARK: - Hero Metric Component

struct HeroMetricView: View {
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
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
                    .textCase(.uppercase)

                Spacer()

                if let date = date {
                    Text(Formatters.formatAbbreviatedDayHeader(date))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Hero metric: Weight (large) × Reps (smaller, lighter)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Formatters.formatWeight(weight)) kg")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("× \(reps) reps")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Total volume (medium, secondary)
            Text("\(Formatters.formatVolume(totalVolume)) kg total")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
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
    case last = "Last Session"
    case best = "Best Ever"
}

// MARK: - Data Structures for Section Components

struct TargetMetricsData {
    let headerLabel: String
    let date: Date?
    let weight: Double
    let reps: Int
    let totalVolume: Double
}

struct ThisSetData {
    let weight: String
    let reps: Int
    let isDropSet: Bool
    let isPB: Bool
    let comparisonLabel: String
    let weightProgress: (text: String, direction: ProgressTracker.PRDirection)?
    let repsProgress: (text: String, direction: ProgressTracker.PRDirection)?
}

struct ProgressBarData {
    let progressRatio: CGFloat
    let barFillColor: Color
    let progressText: String
}

// MARK: - TargetMetricsSection Component

struct TargetMetricsSection: View {
    let data: TargetMetricsData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: "LAST MAX WEIGHT" / "BEST EVER" label + date
            HStack {
                Text(data.headerLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                if let date = data.date {
                    Text(Formatters.formatAbbreviatedDayHeader(date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Metric values: Weight × Reps
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Formatters.formatWeight(data.weight)) kg")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("× \(data.reps) reps")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            // Total volume
            Text("\(Formatters.formatVolume(data.totalVolume)) kg total")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - ThisSetSection Component

struct ThisSetSection: View {
    let data: ThisSetData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                // Header row with "THIS SET" and "vs last session"
                HStack {
                    Text("THIS SET")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Spacer()

                    Text(data.comparisonLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Set values
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(data.weight) kg")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("× \(data.reps) reps")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if data.isDropSet {
                        Circle()
                            .fill(.teal)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            }
                    }

                    if data.isPB {
                        Circle()
                            .fill(.purple)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Text("PB")
                                    .font(.system(size: 9))
                                    .italic()
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                    }
                }
            }

            // Progress pills
            HStack(spacing: 8) {
                if let progress = data.weightProgress {
                    ProgressPillView(text: progress.text, direction: progress.direction)
                }

                if let repsProgress = data.repsProgress {
                    ProgressPillView(text: repsProgress.text, direction: repsProgress.direction)
                }
            }
        }
    }
}

// MARK: - ProgressBarSection Component

struct ProgressBarSection: View {
    let data: ProgressBarData

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Thin progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track (grey)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)

                    // Fill (blue/green based on progress)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(data.barFillColor)
                        .frame(width: geometry.size.width * data.progressRatio, height: 4)
                }
            }
            .frame(height: 4)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Target Metrics Section (always visible)
            TargetMetricsSection(data: targetMetrics)

            // 2. Only show remaining sections if sets added today
            if let setData = thisSet {
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                // This Set Section
                ThisSetSection(data: setData)
                    .padding(.bottom, 20)

                // Progress Bar Section
                ProgressBarSection(data: progressBar)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - ExerciseMetricsView

struct ExerciseMetricsView: View {
    let exercise: Exercise
    let sets: [ExerciseSet]
    @Binding var selectedMode: MetricMode
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
        guard let lastWorkingSet = sets.first(where: { !$0.isWarmUp }) else {
            return (nil, nil)
        }
        return (lastWorkingSet.weight, lastWorkingSet.reps)
    }

    // Progress bar ratio
    private var progressBarRatio: CGFloat {
        guard let state = progressState else { return 0 }
        return CGFloat(state.progressBarRatio)
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

    // Formatted progress text: "XX% of last complete"
    private var formattedProgressText: String {
        let percentage = progressPercentage
        return "\(percentage)% of last complete"
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

    private func formatThisSet() -> (weight: String, reps: Int, isDropSet: Bool, isPB: Bool)? {
        // Get the most recent working set from today (skip warm-ups)
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp }) else {
            return nil
        }

        let weight = Formatters.formatWeight(lastWorkingSet.weight)
        let reps = lastWorkingSet.reps

        return (weight, reps, lastWorkingSet.isDropSet, lastWorkingSet.isPB)
    }

    private func formatThisSetProgress() -> (text: String, direction: ProgressTracker.PRDirection)? {
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp }),
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
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp }),
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
                    totalVolume: best.totalVolume
                )
            } else {
                return TargetMetricsData(
                    headerLabel: "BEST EVER",
                    date: nil,
                    weight: 0,
                    reps: 0,
                    totalVolume: 0
                )
            }
        } else {
            if let lastInfo = progressState?.lastCompletedDayInfo {
                return TargetMetricsData(
                    headerLabel: "LAST MAX WEIGHT",
                    date: summary.date,
                    weight: lastInfo.maxWeight,
                    reps: lastInfo.maxWeightReps,
                    totalVolume: lastInfo.volume
                )
            } else {
                return TargetMetricsData(
                    headerLabel: "LAST MAX WEIGHT",
                    date: nil,
                    weight: 0,
                    reps: 0,
                    totalVolume: 0
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
            isPB: setInfo.isPB,
            comparisonLabel: selectedMode == .best ? "vs best ever" : "vs last session",
            weightProgress: formatThisSetProgress(),
            repsProgress: formatThisSetRepsProgress()
        )
    }

    private func buildProgressBarData() -> ProgressBarData {
        return ProgressBarData(
            progressRatio: progressBarRatio,
            barFillColor: progressState?.barFillColor ?? .blue,
            progressText: formattedProgressText
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Segmented Picker (Last Session / Best Ever)
            Picker("Metric Mode", selection: $selectedMode) {
                ForEach(MetricMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 20)

            // Metric View Stats (contains all three sections + divider)
            MetricViewStats(
                targetMetrics: buildTargetMetricsData(),
                thisSet: buildThisSetData(),
                progressBar: buildProgressBarData()
            )
        }
    }
}
