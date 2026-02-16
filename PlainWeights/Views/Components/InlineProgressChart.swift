//
//  InlineProgressChart.swift
//  PlainWeights
//
//  Inline progress chart component that shows weight and reps trends
//  over time with dual Y-axis visualization.
//

import SwiftUI
import Charts

// MARK: - Chart Time Range

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case sixMonths = "6M"
    case oneYear = "1Y"
    case threeYears = "3Y"
    case max = "Max"

    var id: String { rawValue }

    /// Returns cutoff date for filtering, or nil for max (all data)
    var cutoffDate: Date? {
        let calendar = Calendar.current
        switch self {
        case .sixMonths: return calendar.date(byAdding: .month, value: -6, to: Date())
        case .oneYear: return calendar.date(byAdding: .year, value: -1, to: Date())
        case .threeYears: return calendar.date(byAdding: .year, value: -3, to: Date())
        case .max: return nil
        }
    }

    /// Grouping granularity for downsampling
    enum Granularity {
        case daily, weekly, monthly
    }

    var granularity: Granularity {
        switch self {
        case .sixMonths: return .daily
        case .oneYear: return .weekly
        case .threeYears, .max: return .monthly
        }
    }
}

// MARK: - Chart Mode

enum ChartMode: String, CaseIterable {
    case max = "Max"
    case volume = "Volume"
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let date: Date
    let dateLabel: String
    let maxWeight: Double
    let maxReps: Int
    let normalizedWeight: Double
    let normalizedReps: Double
    let isPB: Bool
    // Volume mode data
    let totalVolume: Double        // sum of (weight × reps) for session
    let totalReps: Int             // sum of reps for session
    let normalizedVolume: Double
    let normalizedTotalReps: Double
}

// MARK: - Cached Chart State (Performance Optimization)

/// Caches all computed values to avoid redundant iterations during render
struct CachedChartState {
    let dataPoints: [ChartDataPoint]
    let isRepsOnly: Bool
    let weightRange: (min: Double, max: Double)
    let repsRange: (min: Int, max: Int)
    let volumeRange: (min: Double, max: Double)
    let totalRepsRange: (min: Int, max: Int)
    // Linear regression for weight trend line
    let regressionSlope: Double?
    let regressionIntercept: Double?
    // Linear regression for volume trend line
    let volumeRegressionSlope: Double?
    let volumeRegressionIntercept: Double?
    // Linear regression for max reps trend line (reps-only exercises)
    let repsRegressionSlope: Double?
    let repsRegressionIntercept: Double?
    // Linear regression for total reps trend line (reps-only exercises in volume mode)
    let totalRepsRegressionSlope: Double?
    let totalRepsRegressionIntercept: Double?

    static let empty = CachedChartState(
        dataPoints: [],
        isRepsOnly: true,
        weightRange: (min: 0, max: 100),
        repsRange: (min: 0, max: 10),
        volumeRange: (min: 0, max: 100),
        totalRepsRange: (min: 0, max: 10),
        regressionSlope: nil,
        regressionIntercept: nil,
        volumeRegressionSlope: nil,
        volumeRegressionIntercept: nil,
        repsRegressionSlope: nil,
        repsRegressionIntercept: nil,
        totalRepsRegressionSlope: nil,
        totalRepsRegressionIntercept: nil
    )
}

// MARK: - Inline Progress Chart

struct InlineProgressChart: View {
    @Environment(ThemeManager.self) private var themeManager
    let sets: [ExerciseSet]

    // Animation state - start true so chart appears immediately with container
    @State private var isAnimating = true

    // Time range selection - default to 6 months for daily granularity
    @State private var selectedTimeRange: ChartTimeRange = .sixMonths

    // Chart mode selection - Max (default) shows max weight/reps, Volume shows total
    @State private var chartMode: ChartMode = .max

    // Trend line toggle - reads persisted default from settings
    @State private var showTrendLine: Bool = UserDefaults.standard.bool(forKey: "showTrendLineByDefault")

    // Cached chart state - computed on init to prevent layout shift
    @State private var cachedState: CachedChartState

    init(sets: [ExerciseSet]) {
        self.sets = sets
        // Compute chart state during init to prevent layout shift on appear
        _cachedState = State(initialValue: Self.computeChartState(from: sets, timeRange: .sixMonths))
    }

    // MARK: - Linear Regression

    /// Calculate linear regression for normalized weight values
    /// Returns (slope, intercept) for y = slope * x + intercept
    private static func calculateLinearRegression(points: [ChartDataPoint]) -> (slope: Double, intercept: Double)? {
        guard points.count >= 2 else { return nil }

        let n = Double(points.count)
        let sumX = points.enumerated().reduce(0.0) { $0 + Double($1.offset) }
        let sumY = points.reduce(0.0) { $0 + $1.normalizedWeight }
        let sumXY = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element.normalizedWeight }
        let sumX2 = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * Double($1.offset) }

        let denominator = n * sumX2 - sumX * sumX
        guard denominator != 0 else { return nil }

        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n

        return (slope, intercept)
    }

    /// Calculate linear regression for normalized volume values
    private static func calculateVolumeRegression(points: [ChartDataPoint]) -> (slope: Double, intercept: Double)? {
        guard points.count >= 2 else { return nil }

        let n = Double(points.count)
        let sumX = points.enumerated().reduce(0.0) { $0 + Double($1.offset) }
        let sumY = points.reduce(0.0) { $0 + $1.normalizedVolume }
        let sumXY = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element.normalizedVolume }
        let sumX2 = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * Double($1.offset) }

        let denominator = n * sumX2 - sumX * sumX
        guard denominator != 0 else { return nil }

        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n

        return (slope, intercept)
    }

    /// Calculate linear regression for normalized reps values (reps-only exercises)
    private static func calculateRepsRegression(points: [ChartDataPoint]) -> (slope: Double, intercept: Double)? {
        guard points.count >= 2 else { return nil }

        let n = Double(points.count)
        let sumX = points.enumerated().reduce(0.0) { $0 + Double($1.offset) }
        let sumY = points.reduce(0.0) { $0 + $1.normalizedReps }
        let sumXY = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element.normalizedReps }
        let sumX2 = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * Double($1.offset) }

        let denominator = n * sumX2 - sumX * sumX
        guard denominator != 0 else { return nil }

        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n

        return (slope, intercept)
    }

    /// Calculate linear regression for normalized total reps values (reps-only exercises in volume mode)
    private static func calculateTotalRepsRegression(points: [ChartDataPoint]) -> (slope: Double, intercept: Double)? {
        guard points.count >= 2 else { return nil }

        let n = Double(points.count)
        let sumX = points.enumerated().reduce(0.0) { $0 + Double($1.offset) }
        let sumY = points.reduce(0.0) { $0 + $1.normalizedTotalReps }
        let sumXY = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element.normalizedTotalReps }
        let sumX2 = points.enumerated().reduce(0.0) { $0 + Double($1.offset) * Double($1.offset) }

        let denominator = n * sumX2 - sumX * sumX
        guard denominator != 0 else { return nil }

        let slope = (n * sumXY - sumX * sumY) / denominator
        let intercept = (sumY - slope * sumX) / n

        return (slope, intercept)
    }

    // MARK: - Data Transformation

    private static func computeChartState(from sets: [ExerciseSet], timeRange: ChartTimeRange) -> CachedChartState {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        // Filter out warm-up and bonus sets
        var workingSets = sets.workingSets

        // Compute isRepsOnly once here (all working sets have weight == 0)
        let isRepsOnly = workingSets.allSatisfy { $0.weight == 0 }

        // Apply time range filter
        if let cutoff = timeRange.cutoffDate {
            workingSets = workingSets.filter { $0.timestamp >= cutoff }
        }

        // Calculate actual data span to determine appropriate granularity
        let sortedDates = workingSets.map { $0.timestamp }.sorted()
        guard let firstDate = sortedDates.first, let lastDate = sortedDates.last else {
            return CachedChartState.empty
        }
        let dataSpanDays = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0

        // Choose granularity based on ACTUAL data span
        // Small datasets always show daily, larger datasets use coarser granularity
        let granularity: ChartTimeRange.Granularity
        if dataSpanDays < 180 {
            // Under 6 months - always show daily points for all views
            granularity = .daily
        } else if dataSpanDays < 365 {
            // 6-12 months - daily for 6M, weekly for others
            granularity = timeRange == .sixMonths ? .daily : .weekly
        } else if dataSpanDays < 730 {
            // 1-2 years - daily for 6M, weekly for 1Y, monthly for 3Y/Max
            switch timeRange {
            case .sixMonths: granularity = .daily
            case .oneYear: granularity = .weekly
            case .threeYears, .max: granularity = .monthly
            }
        } else {
            // 2+ years - daily for 6M, weekly for 1Y, monthly for 3Y/Max
            switch timeRange {
            case .sixMonths: granularity = .daily
            case .oneYear: granularity = .weekly
            case .threeYears, .max: granularity = .monthly
            }
        }

        // Group sets based on granularity (daily, weekly, or monthly)
        let grouped: [Date: [ExerciseSet]]
        switch granularity {
        case .daily:
            grouped = Dictionary(grouping: workingSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }
        case .weekly:
            grouped = Dictionary(grouping: workingSets) { set in
                // Group by start of week
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: set.timestamp)
                return calendar.date(from: components) ?? set.timestamp
            }
        case .monthly:
            grouped = Dictionary(grouping: workingSets) { set in
                // Group by start of month
                let components = calendar.dateComponents([.year, .month], from: set.timestamp)
                return calendar.date(from: components) ?? set.timestamp
            }
        }

        // Calculate max weight and reps per period, total volume/reps, and check for PB
        var rawDataPoints: [(date: Date, maxWeight: Double, maxReps: Int, isPB: Bool, totalVolume: Double, totalReps: Int)] = []
        for (date, periodSets) in grouped {
            let maxWeight = periodSets.map { $0.weight }.max() ?? 0
            let maxReps = periodSets.map { $0.reps }.max() ?? 0
            let hasPB = periodSets.contains { $0.isPB }
            // Calculate total volume (sum of weight × reps) and total reps
            let totalVolume = periodSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            let totalReps = periodSets.reduce(0) { $0 + $1.reps }
            rawDataPoints.append((date, maxWeight, maxReps, hasPB, totalVolume, totalReps))
        }

        // Sort by date ascending
        rawDataPoints.sort { $0.date < $1.date }

        // Calculate normalization ranges (with padding for visual clarity)
        let weightMax = rawDataPoints.map { $0.maxWeight }.max() ?? 1
        let weightMin = rawDataPoints.map { $0.maxWeight }.min() ?? 0
        let repsMax = Double(rawDataPoints.map { $0.maxReps }.max() ?? 1)
        let repsMin = Double(rawDataPoints.map { $0.maxReps }.min() ?? 0)

        // Add 10% padding to ranges
        let weightPadding = max((weightMax - weightMin) * 0.1, 1)
        let repsPadding = max((repsMax - repsMin) * 0.1, 1)

        let weightNormRange = max(weightMax - weightMin + weightPadding * 2, 1)
        let repsNormRange = max(repsMax - repsMin + repsPadding * 2, 1)

        let adjustedWeightMin = weightMin - weightPadding
        let adjustedRepsMin = repsMin - repsPadding

        // Volume normalization
        let volumeMax = rawDataPoints.map { $0.totalVolume }.max() ?? 1
        let volumeMin = rawDataPoints.map { $0.totalVolume }.min() ?? 0
        let volumePadding = max((volumeMax - volumeMin) * 0.1, 1)
        let volumeNormRange = max(volumeMax - volumeMin + volumePadding * 2, 1)
        let adjustedVolumeMin = volumeMin - volumePadding

        // Total reps normalization
        let totalRepsMax = Double(rawDataPoints.map { $0.totalReps }.max() ?? 1)
        let totalRepsMin = Double(rawDataPoints.map { $0.totalReps }.min() ?? 0)
        let totalRepsPadding = max((totalRepsMax - totalRepsMin) * 0.1, 1)
        let totalRepsNormRange = max(totalRepsMax - totalRepsMin + totalRepsPadding * 2, 1)
        let adjustedTotalRepsMin = totalRepsMin - totalRepsPadding

        // Create chart data points with normalized values and index
        let dataPoints = rawDataPoints.enumerated().map { index, point in
            ChartDataPoint(
                index: index,
                date: point.date,
                dateLabel: dateFormatter.string(from: point.date),
                maxWeight: point.maxWeight,
                maxReps: point.maxReps,
                normalizedWeight: (point.maxWeight - adjustedWeightMin) / weightNormRange,
                normalizedReps: (Double(point.maxReps) - adjustedRepsMin) / repsNormRange,
                isPB: point.isPB,
                totalVolume: point.totalVolume,
                totalReps: point.totalReps,
                normalizedVolume: (point.totalVolume - adjustedVolumeMin) / volumeNormRange,
                normalizedTotalReps: (Double(point.totalReps) - adjustedTotalRepsMin) / totalRepsNormRange
            )
        }

        // Calculate Y-axis ranges with padding for display
        let displayWeightRange = (min: weightMin - weightPadding, max: weightMax + weightPadding)
        let displayRepsRange = (min: max(0, Int(repsMin) - Int(repsPadding)), max: Int(repsMax) + Int(repsPadding))
        let displayVolumeRange = (min: max(0, volumeMin - volumePadding), max: volumeMax + volumePadding)
        let displayTotalRepsRange = (min: max(0, Int(totalRepsMin) - Int(totalRepsPadding)), max: Int(totalRepsMax) + Int(totalRepsPadding))

        // Calculate linear regression for weight trend line (only if not reps-only)
        let regression = isRepsOnly ? nil : calculateLinearRegression(points: dataPoints)
        // Calculate linear regression for volume trend line (only if not reps-only)
        let volumeRegression = isRepsOnly ? nil : calculateVolumeRegression(points: dataPoints)
        // Calculate linear regression for reps trend line (only if reps-only)
        let repsRegression = isRepsOnly ? calculateRepsRegression(points: dataPoints) : nil
        // Calculate linear regression for total reps trend line (only if reps-only)
        let totalRepsRegression = isRepsOnly ? calculateTotalRepsRegression(points: dataPoints) : nil

        return CachedChartState(
            dataPoints: dataPoints,
            isRepsOnly: isRepsOnly,
            weightRange: displayWeightRange,
            repsRange: displayRepsRange,
            volumeRange: displayVolumeRange,
            totalRepsRange: displayTotalRepsRange,
            regressionSlope: regression?.slope,
            regressionIntercept: regression?.intercept,
            volumeRegressionSlope: volumeRegression?.slope,
            volumeRegressionIntercept: volumeRegression?.intercept,
            repsRegressionSlope: repsRegression?.slope,
            repsRegressionIntercept: repsRegression?.intercept,
            totalRepsRegressionSlope: totalRepsRegression?.slope,
            totalRepsRegressionIntercept: totalRepsRegression?.intercept
        )
    }

    // Determine if data spans multiple years
    private var spansMultipleYears: Bool {
        guard let first = cachedState.dataPoints.first?.date,
              let last = cachedState.dataPoints.last?.date else { return false }
        let calendar = Calendar.current
        return calendar.component(.year, from: first) != calendar.component(.year, from: last)
    }

    // Format date based on data span and granularity - ultra compact
    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedTimeRange.granularity {
        case .daily:
            if spansMultipleYears {
                formatter.dateFormat = "M/yy"   // "1/25" - month/year
            } else {
                formatter.dateFormat = "d/M"    // "27/1" - day/month
            }
        case .weekly:
            formatter.dateFormat = "d/M"    // "27/1" - week start date
        case .monthly:
            formatter.dateFormat = "M/yy"   // "1/25" - month/year
        }
        return formatter.string(from: date)
    }

    // Calculate evenly-spaced indices for X-axis labels (max 5)
    private var xAxisIndices: [Int] {
        let count = cachedState.dataPoints.count
        guard count > 1 else { return count == 1 ? [0] : [] }

        let maxLabels = min(5, count)
        if count <= maxLabels {
            return Array(0..<count)
        }

        // Evenly spaced indices including first and last
        var indices: [Int] = []
        let step = Double(count - 1) / Double(maxLabels - 1)
        for i in 0..<maxLabels {
            indices.append(Int(round(Double(i) * step)))
        }
        return indices
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Pickers row (Mode + Trend Toggle + Time Range)
            HStack {
                // Mode toggle (Max vs Volume)
                Picker("Mode", selection: $chartMode) {
                    ForEach(ChartMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)

                Spacer()

                // Trend line toggle button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTrendLine.toggle()
                    }
                } label: {
                    Image(systemName: "line.diagonal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(showTrendLine ? themeManager.effectiveTheme.primaryText : themeManager.effectiveTheme.mutedForeground)
                        .frame(width: 28, height: 28)
                        .background(showTrendLine ? themeManager.effectiveTheme.borderColor : themeManager.effectiveTheme.cardBackgroundColor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 5)

                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(ChartTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            if cachedState.dataPoints.isEmpty {
                emptyState
            } else {
                chartWithAxes
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                legendView
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .padding(16)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
        .onChange(of: sets) { _, _ in
            cachedState = Self.computeChartState(from: sets, timeRange: selectedTimeRange)
        }
        .onChange(of: selectedTimeRange) { _, newRange in
            withAnimation(.easeInOut(duration: 0.2)) {
                cachedState = Self.computeChartState(from: sets, timeRange: newRange)
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        Text("No data yet. Log sets to see progress.")
            .font(themeManager.effectiveTheme.subheadlineFont)
            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Chart with Y-Axes

    @ViewBuilder
    private var chartWithAxes: some View {
        if chartMode == .max {
            maxModeChartWithAxes
        } else {
            volumeModeChartWithAxes
        }
    }

    @ViewBuilder
    private var maxModeChartWithAxes: some View {
        HStack(alignment: .center, spacing: 4) {
            if cachedState.isRepsOnly {
                // Reps-only: single Y-axis on left for reps (green/teal)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(cachedState.repsRange.max)")
                    Spacer()
                    Text("\((cachedState.repsRange.min + cachedState.repsRange.max) / 2)")
                    Spacer()
                    Text("\(cachedState.repsRange.min)")
                }
                .font(themeManager.effectiveTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 25, height: 130)

                // Main chart
                maxModeChartView
                    .frame(height: 150)
            } else {
                // Dual Y-axes: reps on left, weight on right
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(cachedState.repsRange.max)")
                    Spacer()
                    Text("\((cachedState.repsRange.min + cachedState.repsRange.max) / 2)")
                    Spacer()
                    Text("\(cachedState.repsRange.min)")
                }
                .font(themeManager.effectiveTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 25, height: 130)

                // Main chart
                maxModeChartView
                    .frame(height: 150)

                // Right Y-axis labels (Weight) - converted to user's preferred unit
                VStack(alignment: .leading, spacing: 0) {
                    Text(Formatters.formatWeight(themeManager.displayWeight(cachedState.weightRange.max)))
                    Spacer()
                    Text(Formatters.formatWeight(themeManager.displayWeight((cachedState.weightRange.min + cachedState.weightRange.max) / 2)))
                    Spacer()
                    Text(Formatters.formatWeight(themeManager.displayWeight(cachedState.weightRange.min)))
                }
                .font(themeManager.effectiveTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.effectiveTheme.chartColor1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 35, height: 130)
            }
        }
    }

    @ViewBuilder
    private var volumeModeChartWithAxes: some View {
        HStack(alignment: .center, spacing: 4) {
            if cachedState.isRepsOnly {
                // Reps-only: Y-axis shows total reps (golden yellow)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(cachedState.totalRepsRange.max)")
                    Spacer()
                    Text("\((cachedState.totalRepsRange.min + cachedState.totalRepsRange.max) / 2)")
                    Spacer()
                    Text("\(cachedState.totalRepsRange.min)")
                }
                .font(themeManager.effectiveTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.effectiveTheme.chartColor4)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 35, height: 130)

                // Line chart
                volumeModeChartView
                    .frame(height: 150)
            } else {
                // Weighted: Y-axis shows total volume - converted to user's preferred unit
                VStack(alignment: .trailing, spacing: 0) {
                    Text(Formatters.formatVolume(themeManager.displayWeight(cachedState.volumeRange.max)))
                    Spacer()
                    Text(Formatters.formatVolume(themeManager.displayWeight((cachedState.volumeRange.min + cachedState.volumeRange.max) / 2)))
                    Spacer()
                    Text(Formatters.formatVolume(themeManager.displayWeight(cachedState.volumeRange.min)))
                }
                .font(themeManager.effectiveTheme.dataFont(size: 10))
                .foregroundStyle(themeManager.effectiveTheme.chartColor3)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 45, height: 130)

                // Line chart
                volumeModeChartView
                    .frame(height: 150)
            }
        }
    }

    // MARK: - Max Mode Chart View

    @ViewBuilder
    private var maxModeChartView: some View {
        Chart(cachedState.dataPoints) { point in
            if cachedState.isRepsOnly {
                // Reps-only: show reps as solid line with gradient (no weight line)
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "RepsArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.effectiveTheme.chartColor2.opacity(0.3),
                                 themeManager.effectiveTheme.chartColor2.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "Reps")
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)

                // Endpoint dots: first and last data points
                if point.index == 0 || point.index == cachedState.dataPoints.count - 1 {
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Reps", point.normalizedReps)
                    )
                    .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                    .symbolSize(20)
                }

                // Linear regression trend line for reps-only (only draw at first and last points)
                if showTrendLine,
                   let slope = cachedState.repsRegressionSlope,
                   let intercept = cachedState.repsRegressionIntercept,
                   cachedState.dataPoints.count >= 2 {
                    let lastIndex = cachedState.dataPoints.count - 1
                    if point.index == 0 || point.index == lastIndex {
                        let trendY = slope * Double(point.index) + intercept
                        // Clamp to chart bounds
                        let clampedY = max(0, min(1, trendY))
                        LineMark(
                            x: .value("Index", point.index),
                            y: .value("RepsTrend", clampedY),
                            series: .value("Type", "RepsTrend")
                        )
                        .foregroundStyle(themeManager.effectiveTheme.chartColor2.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                }
            } else {
                // Weight and reps: show both lines

                // Weight area gradient
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Weight", point.normalizedWeight),
                    series: .value("Type", "WeightArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.effectiveTheme.chartColor1.opacity(0.3),
                                 themeManager.effectiveTheme.chartColor1.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                // Weight line (solid)
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Weight", point.normalizedWeight),
                    series: .value("Type", "Weight")
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor1)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)

                // Reps line (dashed, no gradient, thinner)
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Reps", point.normalizedReps),
                    series: .value("Type", "Reps")
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                .lineStyle(StrokeStyle(lineWidth: 1.0, dash: [5, 3]))
                .interpolationMethod(.monotone)

                // Endpoint dots: first and last data points
                if point.index == 0 || point.index == cachedState.dataPoints.count - 1 {
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Weight", point.normalizedWeight)
                    )
                    .foregroundStyle(themeManager.effectiveTheme.chartColor1)
                    .symbolSize(20)

                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Reps", point.normalizedReps)
                    )
                    .foregroundStyle(themeManager.effectiveTheme.chartColor2)
                    .symbolSize(16)
                }

                // Linear regression trend line (only draw at first and last points)
                if showTrendLine,
                   let slope = cachedState.regressionSlope,
                   let intercept = cachedState.regressionIntercept,
                   cachedState.dataPoints.count >= 2 {
                    let lastIndex = cachedState.dataPoints.count - 1
                    if point.index == 0 || point.index == lastIndex {
                        let trendY = slope * Double(point.index) + intercept
                        // Clamp to chart bounds
                        let clampedY = max(0, min(1, trendY))
                        LineMark(
                            x: .value("Index", point.index),
                            y: .value("Trend", clampedY),
                            series: .value("Type", "Trend")
                        )
                        .foregroundStyle(themeManager.effectiveTheme.chartColor1.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                }
            }

            // PB indicator: vertical line through the point + star at top
            if point.isPB {
                RuleMark(x: .value("Index", point.index))
                    .foregroundStyle(themeManager.effectiveTheme.pbColor.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                PointMark(
                    x: .value("Index", point.index),
                    y: .value("PB", 1.0)
                )
                .symbol {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(themeManager.effectiveTheme.pbColor)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...(max(cachedState.dataPoints.count - 1, 1)))
        .chartYAxis {
            AxisMarks(values: [0.0, 0.25, 0.5, 0.75, 1.0]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(themeManager.effectiveTheme.borderColor)
            }
        }
        .chartYScale(domain: 0...1)
    }

    // MARK: - Volume Mode Chart View

    @ViewBuilder
    private var volumeModeChartView: some View {
        Chart(cachedState.dataPoints) { point in
            if cachedState.isRepsOnly {
                // Reps-only: show total reps as line with gradient (golden yellow)
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Total Reps", point.normalizedTotalReps),
                    series: .value("Type", "TotalRepsArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.effectiveTheme.chartColor4.opacity(0.3),
                                 themeManager.effectiveTheme.chartColor4.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Total Reps", point.normalizedTotalReps),
                    series: .value("Type", "TotalReps")
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor4)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)

                // Endpoint dots: first and last data points
                if point.index == 0 || point.index == cachedState.dataPoints.count - 1 {
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Total Reps", point.normalizedTotalReps)
                    )
                    .foregroundStyle(themeManager.effectiveTheme.chartColor4)
                    .symbolSize(20)
                }

                // Linear regression trend line for total reps (only draw at first and last points)
                if showTrendLine,
                   let slope = cachedState.totalRepsRegressionSlope,
                   let intercept = cachedState.totalRepsRegressionIntercept,
                   cachedState.dataPoints.count >= 2 {
                    let lastIndex = cachedState.dataPoints.count - 1
                    if point.index == 0 || point.index == lastIndex {
                        let trendY = slope * Double(point.index) + intercept
                        // Clamp to chart bounds
                        let clampedY = max(0, min(1, trendY))
                        LineMark(
                            x: .value("Index", point.index),
                            y: .value("TotalRepsTrend", clampedY),
                            series: .value("Type", "TotalRepsTrend")
                        )
                        .foregroundStyle(themeManager.effectiveTheme.chartColor4.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                }
            } else {
                // Weighted: show total volume as line with gradient
                AreaMark(
                    x: .value("Index", point.index),
                    y: .value("Volume", point.normalizedVolume),
                    series: .value("Type", "VolumeArea")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeManager.effectiveTheme.chartColor3.opacity(0.3),
                                 themeManager.effectiveTheme.chartColor3.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Volume", point.normalizedVolume),
                    series: .value("Type", "Volume")
                )
                .foregroundStyle(themeManager.effectiveTheme.chartColor3)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)

                // Endpoint dots: first and last data points
                if point.index == 0 || point.index == cachedState.dataPoints.count - 1 {
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Volume", point.normalizedVolume)
                    )
                    .foregroundStyle(themeManager.effectiveTheme.chartColor3)
                    .symbolSize(20)
                }

                // Linear regression trend line for volume (only draw at first and last points)
                if showTrendLine,
                   let slope = cachedState.volumeRegressionSlope,
                   let intercept = cachedState.volumeRegressionIntercept,
                   cachedState.dataPoints.count >= 2 {
                    let lastIndex = cachedState.dataPoints.count - 1
                    if point.index == 0 || point.index == lastIndex {
                        let trendY = slope * Double(point.index) + intercept
                        // Clamp to chart bounds
                        let clampedY = max(0, min(1, trendY))
                        LineMark(
                            x: .value("Index", point.index),
                            y: .value("VolumeTrend", clampedY),
                            series: .value("Type", "VolumeTrend")
                        )
                        .foregroundStyle(themeManager.effectiveTheme.chartColor3.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                }
            }
            // Note: PB indicator intentionally omitted in Volume mode
            // PB is based on max weight/reps per set, not total session volume
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...(max(cachedState.dataPoints.count - 1, 1)))
        .chartYAxis {
            AxisMarks(values: [0.0, 0.25, 0.5, 0.75, 1.0]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(themeManager.effectiveTheme.borderColor)
            }
        }
        .chartYScale(domain: 0...1)
    }

    // MARK: - Legend View

    @ViewBuilder
    private var legendView: some View {
        HStack(spacing: 16) {
            if chartMode == .max {
                // Max mode legend (line chart)
                if cachedState.isRepsOnly {
                    lineLegendItem(color: themeManager.effectiveTheme.chartColor2, label: "Max Reps", isDashed: false)
                    if showTrendLine, cachedState.repsRegressionSlope != nil {
                        lineLegendItem(color: themeManager.effectiveTheme.chartColor2.opacity(0.6), label: "Trend", isDashed: false)
                    }
                } else {
                    lineLegendItem(color: themeManager.effectiveTheme.chartColor1, label: "Max Weight (\(themeManager.weightUnit.displayName))", isDashed: false)
                    lineLegendItem(color: themeManager.effectiveTheme.chartColor2, label: "Max Reps", isDashed: true)
                    if showTrendLine, cachedState.regressionSlope != nil {
                        lineLegendItem(color: themeManager.effectiveTheme.chartColor1.opacity(0.6), label: "Trend", isDashed: false)
                    }
                }
            } else {
                // Volume mode legend (line chart)
                if cachedState.isRepsOnly {
                    lineLegendItem(color: themeManager.effectiveTheme.chartColor4, label: "Total Reps", isDashed: false)
                    if showTrendLine, cachedState.totalRepsRegressionSlope != nil {
                        lineLegendItem(color: themeManager.effectiveTheme.chartColor4.opacity(0.6), label: "Trend", isDashed: false)
                    }
                } else {
                    lineLegendItem(color: themeManager.effectiveTheme.chartColor3, label: "Volume (\(themeManager.weightUnit.displayName))", isDashed: false)
                    if showTrendLine, cachedState.volumeRegressionSlope != nil {
                        lineLegendItem(color: themeManager.effectiveTheme.chartColor3.opacity(0.6), label: "Trend", isDashed: false)
                    }
                }
            }
        }
        .font(themeManager.effectiveTheme.captionFont)
        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
    }

    @ViewBuilder
    private func lineLegendItem(color: Color, label: String, isDashed: Bool) -> some View {
        HStack(spacing: 4) {
            if isDashed {
                // Dashed line indicator
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(color)
                            .frame(width: 4, height: 2)
                    }
                }
            } else {
                // Solid line indicator
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
            }
            Text(label)
        }
    }
}

// MARK: - Preview

#Preview {
    InlineProgressChart(sets: [])
        .padding()
        .environment(ThemeManager())
}
