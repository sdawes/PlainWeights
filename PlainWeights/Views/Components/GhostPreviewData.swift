import Foundation

/// Hardcoded sample data for ghost preview empty states.
/// Shows an upward-trending realistic progression to give
/// first-session users a preview of what their data will look like.
enum GhostPreviewData {

    /// Sample chart data points modelled on real Shoulder Press Machine data.
    /// Weight: 37.5 → 37.5 → 43 (PB) → 37.5 → 37.5 — realistic plateau with a spike.
    /// Normalized values pre-computed.
    static let chartDataPoints: [ChartDataPoint] = {
        let now = Date()
        let calendar = Calendar.current
        func weeksAgo(_ weeks: Int) -> Date {
            calendar.date(byAdding: .weekOfYear, value: -weeks, to: now) ?? now
        }

        // Based on real session pattern: plateau → spike (PB) → back down → slight reps improvement
        // Weight range 37.5–43 kg, reps range 8–11
        return [
            ChartDataPoint(
                index: 0, date: weeksAgo(4),
                maxWeight: 37.5, maxReps: 8,
                normalizedWeight: 0.20, normalizedReps: 0.30,
                isPB: false,
                totalVolume: 860, totalReps: 28,
                normalizedVolume: 0.30, normalizedTotalReps: 0.40
            ),
            ChartDataPoint(
                index: 1, date: weeksAgo(3),
                maxWeight: 37.5, maxReps: 9,
                normalizedWeight: 0.20, normalizedReps: 0.45,
                isPB: false,
                totalVolume: 940, totalReps: 25,
                normalizedVolume: 0.45, normalizedTotalReps: 0.30
            ),
            ChartDataPoint(
                index: 2, date: weeksAgo(2),
                maxWeight: 43.0, maxReps: 8,
                normalizedWeight: 0.85, normalizedReps: 0.30,
                isPB: true,
                totalVolume: 1080, totalReps: 31,
                normalizedVolume: 0.85, normalizedTotalReps: 0.55
            ),
            ChartDataPoint(
                index: 3, date: weeksAgo(1),
                maxWeight: 37.5, maxReps: 9,
                normalizedWeight: 0.20, normalizedReps: 0.45,
                isPB: false,
                totalVolume: 920, totalReps: 32,
                normalizedVolume: 0.40, normalizedTotalReps: 0.60
            ),
            ChartDataPoint(
                index: 4, date: now,
                maxWeight: 37.5, maxReps: 11,
                normalizedWeight: 0.20, normalizedReps: 0.75,
                isPB: false,
                totalVolume: 990, totalReps: 35,
                normalizedVolume: 0.55, normalizedTotalReps: 0.75
            ),
        ]
    }()
}
