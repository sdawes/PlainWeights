//
//  ExerciseMetricsView.swift
//  PlainWeights
//
//  Displays exercise metrics with Last/Best mode toggle
//  Contains: picker, metric cards, progress bar, add set button
//

import SwiftUI
import SwiftData

// MARK: - MetricCard Component

struct MetricCard: View {
    let label: String
    let value: String
    let unit: String
    let changeAmount: String?
    let changeDirection: ProgressTracker.PRDirection?

    var body: some View {
        VStack(spacing: 0) {
            // Section 1: Label (30pt)
            Text(label.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(height: 30, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Section 2: Value (35pt)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 35, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Section 3: Progress indicator (35pt)
            if let changeAmount = changeAmount, let direction = changeDirection {
                HStack(spacing: 4) {
                    Image(systemName: direction.iconName)
                        .font(.caption2)
                        .foregroundStyle(direction.color)
                    Text(changeAmount)
                        .font(.caption)
                        .foregroundStyle(direction.color)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(height: 35, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer()
                    .frame(height: 35)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Metric Mode Enum

enum MetricMode: String, CaseIterable {
    case last = "Last"
    case best = "Best"
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

    // Volume direction indicator
    private var volumeDirection: ProgressTracker.PRDirection {
        guard let state = progressState else { return .same }
        return ProgressTracker.volumeComparisonDirection(
            today: state.todayVolume,
            last: state.lastCompletedDayInfo?.volume ?? 0
        )
    }

    // Volume difference calculation
    private var volumeDifference: (amount: Double, label: String)? {
        guard let state = progressState, state.todayVolume > 0 else { return nil }

        let lastVolume = state.lastCompletedDayInfo?.volume ?? 0
        let diff = state.todayVolume - lastVolume

        if diff > 0 {
            return (diff, "more")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
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

    /// Get the weight and reps values from the last working (non-warm-up) set
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

    // MARK: - Best Mode Format Functions

    private func formatBestWeight() -> String {
        guard let best = bestDayMetrics else { return "0" }
        return Formatters.formatWeight(best.maxWeight)
    }

    private func formatBestReps() -> String {
        guard let best = bestDayMetrics else { return "0" }
        return "\(best.repsAtMaxWeight)"
    }

    private func formatBestVolume() -> String {
        guard let best = bestDayMetrics else { return "0" }
        return Formatters.formatVolume(best.totalVolume)
    }

    private func formatBestWeightChange() -> String? {
        guard let indicators = bestModeIndicators else { return nil }
        return "\(Formatters.formatWeight(abs(indicators.weightImprovement))) kg"
    }

    private func formatBestRepsChange() -> String? {
        guard let indicators = bestModeIndicators else { return nil }
        let amount = abs(indicators.repsImprovement)
        return "\(amount) rep\(amount == 1 ? "" : "s")"
    }

    private func formatBestVolumeChange() -> String? {
        guard let indicators = bestModeIndicators else { return nil }
        return "\(Formatters.formatVolume(abs(indicators.volumeImprovement))) kg"
    }

    // MARK: - Last Mode Format Functions

    private func formatWeight() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatWeight(lastInfo.maxWeight)
    }

    private func formatReps() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return "\(lastInfo.maxWeightReps)"
    }

    private func formatVolume() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatVolume(lastInfo.volume)
    }

    private func formatWeightChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        return "\(Formatters.formatWeight(abs(pr.weightImprovement))) kg"
    }

    private func formatRepsChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        let amount = abs(pr.repsImprovement)
        let repsText = amount == 1 ? "rep" : "reps"
        return "\(amount) \(repsText)"
    }

    private func formatVolumeChange() -> String? {
        guard let diff = volumeDifference else {
            // When equal (no difference), show "0 kg"
            guard let state = progressState, state.todayVolume > 0 else {
                return nil
            }
            let lastVolume = state.lastCompletedDayInfo?.volume ?? 0
            if state.todayVolume == lastVolume {
                return "0 kg"
            }
            return nil
        }
        return "\(Formatters.formatVolume(diff.amount)) kg"
    }

    private func formatTodayVolume() -> String {
        guard let state = progressState else { return "0" }
        return Formatters.formatVolume(state.todayVolume)
    }

    private func formatLastVolume() -> String {
        guard let lastVolume = progressState?.lastCompletedDayInfo?.volume else {
            return "0"
        }
        return Formatters.formatVolume(lastVolume)
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

            // Three metric cards
            HStack(spacing: 12) {
                // Card 1: Weight
                MetricCard(
                    label: "Weight",
                    value: selectedMode == .last ? formatWeight() : formatBestWeight(),
                    unit: "kg",
                    changeAmount: selectedMode == .last ? formatWeightChange() : formatBestWeightChange(),
                    changeDirection: selectedMode == .last ? progressState?.personalRecords?.weightDirection : bestModeIndicators?.weightDirection
                )

                // Card 2: Reps
                MetricCard(
                    label: "Reps",
                    value: selectedMode == .last ? formatReps() : formatBestReps(),
                    unit: "",
                    changeAmount: selectedMode == .last ? formatRepsChange() : formatBestRepsChange(),
                    changeDirection: selectedMode == .last ? progressState?.personalRecords?.repsDirection : bestModeIndicators?.repsDirection
                )

                // Card 3: Volume
                MetricCard(
                    label: "Volume",
                    value: selectedMode == .last ? formatVolume() : formatBestVolume(),
                    unit: "kg",
                    changeAmount: selectedMode == .last ? formatVolumeChange() : formatBestVolumeChange(),
                    changeDirection: selectedMode == .last ? volumeDirection : bestModeIndicators?.volumeDirection
                )
            }

            // Progress bar
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

                // Label: "Today X/Y kg"
                Text("Today \(formatTodayVolume())/\(formatLastVolume()) kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Action button
            HStack(spacing: 8) {
                Spacer()

                // Add Set button (with previous values pre-filled)
                Button(action: {
                    addSetConfig = .previous(
                        exercise: exercise,
                        weight: lastWorkingSetValues.weight,
                        reps: lastWorkingSetValues.reps
                    )
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.tint)
                    }
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
    }
}
