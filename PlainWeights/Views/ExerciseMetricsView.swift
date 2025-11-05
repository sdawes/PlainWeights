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
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Formatters.formatWeight(weight)) kg")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("× \(reps) reps")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            // Total volume (medium, secondary)
            Text("\(Formatters.formatVolume(totalVolume)) kg total")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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

    // Formatted progress text: "31% complete 476/1,547 kg (1,071 kg to go)"
    private var formattedProgressText: String {
        let percentage = progressPercentage
        let remaining = remainingVolume
        let todayVol = Formatters.formatVolume(progressState?.todayVolume ?? 0)
        let targetVol = Formatters.formatVolume(targetVolume)

        if remaining > 0 {
            return "\(percentage)% complete \(todayVol)/\(targetVol) kg (\(Formatters.formatVolume(remaining)) kg to go)"
        } else if percentage >= 100 {
            let over = (progressState?.todayVolume ?? 0) - targetVolume
            if over > 0 {
                return "\(percentage)% complete \(todayVol)/\(targetVol) kg (\(Formatters.formatVolume(over)) kg over!)"
            }
            return "100% complete \(todayVol)/\(targetVol) kg"
        }
        return "\(percentage)% complete \(todayVol)/\(targetVol) kg"
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

    private func formatThisSet() -> (weight: String, reps: Int, isDropSet: Bool)? {
        // Get the most recent working set from today (skip warm-ups)
        guard let lastWorkingSet = todaySets.first(where: { !$0.isWarmUp }) else {
            return nil
        }

        let weight = Formatters.formatWeight(lastWorkingSet.weight)
        let reps = lastWorkingSet.reps

        return (weight, reps, lastWorkingSet.isDropSet)
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

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Picker: Last vs Best
            Picker("Metric Mode", selection: $selectedMode) {
                ForEach(MetricMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            // Hero Target Card
            let summary = formatLastSessionSummary()
            if selectedMode == .best {
                if let best = bestDayMetrics {
                    HeroMetricView(
                        weight: best.maxWeight,
                        reps: best.repsAtMaxWeight,
                        totalVolume: best.totalVolume,
                        headerLabel: "BEST EVER",
                        date: summary.date
                    )
                } else {
                    HeroMetricView(
                        weight: 0,
                        reps: 0,
                        totalVolume: 0,
                        headerLabel: "BEST EVER",
                        date: nil
                    )
                }
            } else {
                if let lastInfo = progressState?.lastCompletedDayInfo {
                    HeroMetricView(
                        weight: lastInfo.maxWeight,
                        reps: lastInfo.maxWeightReps,
                        totalVolume: lastInfo.volume,
                        headerLabel: "LAST MAX WEIGHT",
                        date: summary.date
                    )
                } else {
                    HeroMetricView(
                        weight: 0,
                        reps: 0,
                        totalVolume: 0,
                        headerLabel: "LAST MAX WEIGHT",
                        date: nil
                    )
                }
            }

            // This set display (today's most recent working set)
            if let setInfo = formatThisSet() {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Header label (like "LAST MAX WEIGHT")
                        Text("THIS SET")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        // Set values
                        HStack(spacing: 6) {
                            Text("\(setInfo.weight) kg × \(setInfo.reps) reps")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            if setInfo.isDropSet {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.teal)
                            }
                        }
                    }

                    // Progress pills (comparison - solid colors, no volume pill)
                    VStack(alignment: .leading, spacing: 8) {
                        // Row of pills
                        HStack(spacing: 8) {
                            // Weight pill
                            if let progress = formatThisSetProgress() {
                                ProgressPillView(text: progress.text, direction: progress.direction)
                            }

                            // Reps pill
                            if let repsProgress = formatThisSetRepsProgress() {
                                ProgressPillView(text: repsProgress.text, direction: repsProgress.direction)
                            }
                        }

                        // Label underneath pills
                        Text(selectedMode == .best ? "vs best ever" : "vs last session")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 12)
                .padding(.leading, 20)
            }

            // Enhanced Progress Display (Dual Metrics)
            VStack(alignment: .leading, spacing: 8) {
                // Thin progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track (grey)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)

                        // Fill (blue/green based on progress)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(progressState?.barFillColor ?? .blue)
                            .frame(width: geometry.size.width * progressBarRatio, height: 4)
                    }
                }
                .frame(height: 4)

                // Single-line combined progress text
                Text(formattedProgressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)

            // Action button row
            HStack(spacing: 8) {
                Spacer()

                // Add Set button (right side with previous values pre-filled from all-time)
                Button(action: {
                    addSetConfig = .previous(
                        exercise: exercise,
                        weight: lastWorkingSetValues.weight,
                        reps: lastWorkingSetValues.reps
                    )
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundStyle(.blue)
                        Text("Add Set")
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
}
