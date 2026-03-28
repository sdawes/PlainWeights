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
    let exerciseDeltas: [PersistentIdentifier: ExerciseDeltas]

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
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
        let cardWidth: CGFloat = 350
        let renderer = ImageRenderer(content:
            shareCard
                .frame(width: cardWidth)
                .padding(32)
                .background(theme.background)
                .environment(themeManager)
        )
        renderer.scale = UITraitCollection.current.displayScale
        shareImage = renderer.uiImage
    }

    // MARK: - Share Card

    @ViewBuilder
    private var shareCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand + date header
            VStack(alignment: .leading, spacing: 8) {
                Text("Every rep counts. Start tracking yours.")
                    .font(theme.interFont(size: 17, weight: .bold))
                    .foregroundStyle(theme.primaryText)
                HStack(spacing: 0) {
                    Text("Last session: ")
                        .font(theme.interFont(size: 13, weight: .medium))
                        .foregroundStyle(theme.mutedForeground)
                    Text(day.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                        .font(theme.interFont(size: 13, weight: .regular))
                        .foregroundStyle(theme.mutedForeground)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)

            cardDivider

            // Donut + legend side by side
            if !topMuscleGroups.isEmpty {
                Text("Top 5 Muscles Worked")
                    .font(theme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(theme.mutedForeground)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 4)

                HStack(spacing: 0) {
                    donutChart
                        .frame(width: 80, height: 80)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 0) {
                        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
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
                                }
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 12)

                cardDivider
            }

            // Volume + PBs + Duration – three centred stats
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Formatters.formatVolume(themeManager.displayWeight(day.totalVolume)))")
                            .font(theme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(themeManager.weightUnit.displayName)
                            .font(theme.dataFont(size: 12, weight: .medium))
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
                            .font(.system(size: 15))
                            .foregroundStyle(theme.pbColor)
                        Text("\(pbCount)")
                            .font(theme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                    }
                    Text("PBs")
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
                            .font(theme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(theme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
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
                sectionLabel("Exercise Improvements")

                HStack(spacing: 0) {
                    deltaStat(value: deltas.weightUp, total: deltas.total, label: "Heavier")

                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(width: 1, height: 44)

                    deltaStat(value: deltas.repsUp, total: deltas.total, label: "More Reps")

                    Rectangle()
                        .fill(theme.borderColor)
                        .frame(width: 1, height: 44)

                    deltaStat(value: deltas.volumeUp, total: deltas.total, label: "More Volume")
                }
                .padding(.bottom, 16)

            }
        }
        .background(theme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.borderColor, lineWidth: 1)
        )

        // Socials banner image below the card (light/dark variant)
        Image(theme == .dark ? "socials_dark" : "socials")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 12)
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
            .padding(.horizontal, 16)
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

            // Fill remaining segment with grey
            let endOfChart = Angle.degrees(270)
            if startAngle.degrees < endOfChart.degrees - 0.5 {
                var remainderPath = Path()
                remainderPath.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endOfChart, clockwise: false)
                remainderPath.addArc(center: center, radius: innerRadius, startAngle: endOfChart, endAngle: startAngle, clockwise: true)
                remainderPath.closeSubpath()
                context.fill(remainderPath, with: .color(Color.gray.opacity(0.3)))
            }
        }
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
