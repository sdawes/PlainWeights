//
//  WorkoutShareCardView.swift
//  PlainWeights
//
//  Workout summary share card – renders a styled card for social media export
//

import SwiftUI
import SwiftData

struct WorkoutShareCardView: View {
    @Environment(ThemeManager.self) private var themeManager

    let day: ExerciseDataGrouper.WorkoutDay
    let tagDistribution: [(tag: String, percentage: Double)]
    let exerciseDeltas: [PersistentIdentifier: HistoryView.ExerciseDeltas]

    @State private var shareImage: UIImage?

    private var theme: AppTheme {
        themeManager.effectiveTheme
    }

    private var allSetsForDay: [ExerciseSet] {
        day.exercises.flatMap { $0.sets }
    }

    private var pbCount: Int {
        allSetsForDay.filter { $0.isPB }.count
    }

    private var sessionDuration: Int? {
        SessionStatsCalculator.getSessionDurationMinutes(from: allSetsForDay)
    }

    private var deltasSummary: (weightUp: Int, repsUp: Int, volumeUp: Int, total: Int) {
        let total = exerciseDeltas.count
        let weightUp = exerciseDeltas.values.filter { $0.weight == .up }.count
        let repsUp = exerciseDeltas.values.filter { $0.reps == .up }.count
        let volumeUp = exerciseDeltas.values.filter { $0.volume == .up }.count
        return (weightUp, repsUp, volumeUp, total)
    }

    /// Top 5 exercises ranked by achievement: PBs first, then weight beat, reps beat, volume beat
    private var topExercises: [(index: Int, exercise: ExerciseDataGrouper.WorkoutExercise)] {
        let ranked = day.exercises.enumerated().map { index, exercise in
            let hasPB = exercise.sets.workingSets.contains { $0.isPB }
            let delta = exerciseDeltas[exercise.exercise.persistentModelID]
            // Score: PB=1000, weight up=100, reps up=10, volume up=1
            var score = 0
            if hasPB { score += 1000 }
            if delta?.weight == .up { score += 100 }
            if delta?.reps == .up { score += 10 }
            if delta?.volume == .up { score += 1 }
            return (index: index, exercise: exercise, score: score)
        }
        .sorted { $0.score > $1.score }
        .prefix(5)

        return ranked.map { (index: $0.index, exercise: $0.exercise) }
    }

    // Top 5 muscle groups for the donut chart
    private var topMuscleGroups: [(tag: String, percentage: Double)] {
        Array(tagDistribution.prefix(5))
    }

    // Pastel palette for donut chart
    private let muscleColors: [Color] = [
        Color(red: 0.95, green: 0.55, blue: 0.55),  // Pastel red
        Color(red: 0.55, green: 0.65, blue: 0.95),  // Pastel blue
        Color(red: 0.55, green: 0.85, blue: 0.65),  // Pastel green
        Color(red: 0.95, green: 0.78, blue: 0.45),  // Pastel amber
        Color(red: 0.75, green: 0.60, blue: 0.92),  // Pastel purple
    ]

    var body: some View {
        ScrollView {
            shareCard
                .padding(.horizontal, 24)
                .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .background(theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let shareImage {
                    ShareLink(
                        item: Image(uiImage: shareImage),
                        preview: SharePreview("My Workout", image: Image(uiImage: shareImage))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .onAppear { renderShareImage() }
    }

    private func renderShareImage() {
        let cardWidth = UIScreen.main.bounds.width - 48
        let renderer = ImageRenderer(content:
            shareCard
                .frame(width: cardWidth)
                .padding(4)
                .environment(themeManager)
        )
        renderer.scale = UIScreen.main.scale
        shareImage = renderer.uiImage
    }

    // MARK: - Share Card

    @ViewBuilder
    private var shareCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand + date + logo header
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check out my workout, tracked with Plain Weights")
                        .font(theme.interFont(size: 14, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text(day.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                        .font(theme.interFont(size: 13, weight: .regular))
                        .foregroundStyle(theme.mutedForeground)
                }
                .padding(.vertical, 14)
                .padding(.leading, 16)

                Spacer()

                Rectangle()
                    .fill(theme.borderColor)
                    .frame(width: 1)
                    .padding(.vertical, 10)

                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
            }

            cardDivider

            // Donut + legend side by side
            if !topMuscleGroups.isEmpty {
                HStack(alignment: .center, spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Muscles Worked")
                            .font(theme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(theme.mutedForeground)
                        donutChart
                            .frame(width: 80, height: 80)
                    }

                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                        ForEach(topMuscleGroups.indices, id: \.self) { index in
                            let group = topMuscleGroups[index]
                            GridRow {
                                Circle()
                                    .fill(muscleColors[index % muscleColors.count])
                                    .frame(width: 8, height: 8)
                                Text(group.tag)
                                    .font(theme.captionFont)
                                    .foregroundStyle(theme.primaryText)
                                    .gridColumnAlignment(.leading)
                                Text("\(group.percentage, format: .number.precision(.fractionLength(0)))%")
                                    .font(theme.dataFont(size: 12))
                                    .foregroundStyle(theme.mutedForeground)
                                    .gridColumnAlignment(.trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                cardDivider
            }

            // Volume + PBs + Duration – three centred stats
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Formatters.formatVolume(themeManager.displayWeight(day.totalVolume)))")
                            .font(theme.dataFont(size: 24, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                        Text(themeManager.weightUnit.displayName)
                            .font(theme.dataFont(size: 14, weight: .medium))
                            .foregroundStyle(theme.mutedForeground)
                    }
                    Text("Total Volume")
                        .font(theme.caption2Font)
                        .foregroundStyle(theme.mutedForeground)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(theme.borderColor)
                    .frame(width: 1, height: 44)

                VStack(spacing: 4) {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(theme.pbColor)
                        Text("\(pbCount)")
                            .font(theme.dataFont(size: 24, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                    }
                    Text("Personal Bests")
                        .font(theme.caption2Font)
                        .foregroundStyle(theme.mutedForeground)
                }
                .frame(maxWidth: .infinity)

                if let duration = sessionDuration {
                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(width: 1, height: 44)

                    VStack(spacing: 4) {
                        Text(formatDuration(duration))
                            .font(theme.dataFont(size: 24, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                        Text("Duration")
                            .font(theme.caption2Font)
                            .foregroundStyle(theme.mutedForeground)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)

            cardDivider

            // vs Last Session – 3 columns
            let deltas = deltasSummary
            if deltas.total > 0 {
                sectionLabel("vs Last Session")

                HStack(spacing: 0) {
                    deltaStat(value: deltas.weightUp, total: deltas.total, label: "Beat Max Weight")

                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(width: 1, height: 44)

                    deltaStat(value: deltas.repsUp, total: deltas.total, label: "Beat Max Reps")

                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(width: 1, height: 44)

                    deltaStat(value: deltas.volumeUp, total: deltas.total, label: "Beat Total Volume")
                }
                .padding(.bottom, 16)

                cardDivider
            }

            // Exercises list (top 5 ranked by achievement)
            let exercises = topExercises

            sectionLabel("Top 5 Exercises")

            ForEach(exercises.indices, id: \.self) { i in
                let item = exercises[i]
                let exercise = item.exercise
                let hasPB = exercise.sets.workingSets.contains { $0.isPB }
                let deltas = exerciseDeltas[exercise.exercise.persistentModelID]

                if i > 0 {
                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(height: 1)
                        .padding(.leading, hasPB ? 48 : 40)
                }

                HStack(spacing: 0) {
                    Text("\(i + 1)")
                        .font(theme.dataFont(size: 13, weight: .medium))
                        .foregroundStyle(theme.mutedForeground)
                        .frame(width: 24, alignment: .leading)

                    Text(exercise.exercise.name)
                        .font(theme.subheadlineFont)
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    if let deltas {
                        HStack(spacing: 0) {
                            shareDeltaIndicator("scalemass.fill", direction: deltas.weight)
                                .frame(width: 20)
                            shareDeltaIndicator("arrow.2.squarepath", direction: deltas.reps)
                                .frame(width: 20)
                            shareDeltaIndicator("square.stack.3d.up.fill", direction: deltas.volume)
                                .frame(width: 20)
                        }
                    }

                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(hasPB ? theme.pbColor : .clear)
                        .frame(width: 20)
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.vertical, 12)
                .background {
                    if hasPB {
                        HStack(spacing: 0) {
                            Color.clear.frame(width: 8)
                            Rectangle()
                                .fill(theme.pbColor)
                                .frame(width: 3)
                            Rectangle()
                                .fill(theme.pbColor.opacity(theme.isDark ? 0.15 : 0.06))
                            Color.clear.frame(width: 8)
                        }
                    }
                }
            }

            // Footer – CTA
            cardDivider

            Text("The simplest weight tracking app out there :-)")
                .font(theme.interFont(size: 13, weight: .medium))
                .foregroundStyle(theme.mutedForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

            cardDivider

            // Placeholder for user's social link
            Text("insert social link here")
                .font(theme.interFont(size: 13, weight: .regular))
                .foregroundStyle(theme.mutedForeground.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(theme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private var cardDivider: some View {
        Rectangle()
            .fill(theme.borderColor)
            .frame(height: 1)
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(theme.interFont(size: 14, weight: .medium))
            .foregroundStyle(theme.mutedForeground)
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func deltaStat(value: Int, total: Int, label: String) -> some View {
        let color: Color = value > 0 ? .green : .red
        let arrow = value > 0 ? "▲" : "▼"

        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(arrow)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                Text("\(value)")
                    .font(theme.dataFont(size: 22, weight: .bold))
                    .foregroundStyle(color)
                Text("/\(total)")
                    .font(theme.dataFont(size: 14, weight: .medium))
                    .foregroundStyle(theme.mutedForeground)
            }
            Text(label)
                .font(theme.caption2Font)
                .foregroundStyle(theme.mutedForeground)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var donutChart: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerRadius = min(size.width, size.height) / 2
            let innerRadius = outerRadius - 18
            var startAngle = Angle.degrees(-90)

            for index in topMuscleGroups.indices {
                let group = topMuscleGroups[index]
                let sweep = Angle.degrees(group.percentage / 100 * 360)
                let endAngle = startAngle + sweep

                var path = Path()
                path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()

                context.fill(path, with: .color(muscleColors[index % muscleColors.count]))
                startAngle = endAngle
            }
        }
    }

    private func shareDeltaIndicator(_ symbolName: String, direction: HistoryView.DeltaDirection) -> some View {
        Image(systemName: symbolName)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(direction.color)
    }

    // MARK: - Helpers

    private func formatDuration(_ minutes: Int) -> String {
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
}
