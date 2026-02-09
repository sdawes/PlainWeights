//
//  TagDonutChart.swift
//  PlainWeights
//
//  Donut chart with internal percentages and external radial labels
//

import SwiftUI

struct TagDonutChart: View {
    @Environment(ThemeManager.self) private var themeManager

    let data: [(tag: String, percentage: Double)]

    // Color palette for chart segments
    static let chartColors: [Color] = [
        Color(red: 0.93, green: 0.47, blue: 0.20),  // Orange
        Color(red: 0.20, green: 0.40, blue: 0.75),  // Deep blue
        Color(red: 0.35, green: 0.70, blue: 0.45),  // Green
        Color(red: 0.75, green: 0.35, blue: 0.55),  // Pink/magenta
        Color(red: 0.55, green: 0.45, blue: 0.70),  // Purple
        Color(red: 0.70, green: 0.60, blue: 0.35),  // Gold/tan
        Color(red: 0.40, green: 0.60, blue: 0.70),  // Teal
        Color(red: 0.65, green: 0.40, blue: 0.35),  // Rust
    ]

    static func color(for index: Int) -> Color {
        chartColors[index % chartColors.count]
    }

    private let innerRadiusRatio: CGFloat = 0.55
    private let strokeWidth: CGFloat = 1
    private let labelPadding: CGFloat = 30
    private let minPercentageForLabel: Double = 6  // Skip labels for tiny segments

    // Calculate cumulative angles for segments
    private var segmentAngles: [(startAngle: Double, endAngle: Double, midAngle: Double)] {
        let total = data.reduce(0) { $0 + $1.percentage }
        guard total > 0 else { return [] }

        var angles: [(startAngle: Double, endAngle: Double, midAngle: Double)] = []
        var currentAngle: Double = -90 // Start from 12 o'clock

        for item in data {
            let sweepAngle = (item.percentage / total) * 360
            let midAngle = currentAngle + sweepAngle / 2
            angles.append((startAngle: currentAngle, endAngle: currentAngle + sweepAngle, midAngle: midAngle))
            currentAngle += sweepAngle
        }
        return angles
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let chartRadius = (size - labelPadding * 2) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let ringMidRadius = chartRadius * (1 + innerRadiusRatio) / 2
            let externalRadius = chartRadius + labelPadding * 0.6

            ZStack {
                // Draw segments
                ForEach(Array(data.enumerated()), id: \.element.tag) { index, item in
                    if index < segmentAngles.count {
                        let angles = segmentAngles[index]
                        let color = Self.color(for: index)

                        // Filled segment
                        DonutSegmentShape(
                            startAngle: .degrees(angles.startAngle),
                            endAngle: .degrees(angles.endAngle),
                            innerRadiusRatio: innerRadiusRatio
                        )
                        .fill(color)
                        .frame(width: chartRadius * 2, height: chartRadius * 2)
                        .position(center)

                        // Stroke outline
                        DonutSegmentShape(
                            startAngle: .degrees(angles.startAngle),
                            endAngle: .degrees(angles.endAngle),
                            innerRadiusRatio: innerRadiusRatio
                        )
                        .stroke(themeManager.effectiveTheme.primaryText, lineWidth: strokeWidth)
                        .frame(width: chartRadius * 2, height: chartRadius * 2)
                        .position(center)

                        // Internal percentage label (on the ring)
                        if item.percentage >= minPercentageForLabel {
                            let internalPos = position(center: center, radius: ringMidRadius, angleDegrees: angles.midAngle)
                            Text(String(format: "%.0f%%", item.percentage))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(.white)
                                .position(internalPos)
                        }

                        // External tag label (positioned radially)
                        let labelPos = position(center: center, radius: externalRadius + 15, angleDegrees: angles.midAngle)

                        Text(item.tag)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                            .position(labelPos)
                    }
                }

                // Center content
                Circle()
                    .fill(themeManager.effectiveTheme.background)
                    .frame(width: chartRadius * 2 * innerRadiusRatio - strokeWidth * 2,
                           height: chartRadius * 2 * innerRadiusRatio - strokeWidth * 2)
                    .position(center)

                VStack(spacing: 1) {
                    Text("\(data.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    Text(data.count == 1 ? "tag" : "tags")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .position(center)
            }
        }
        .frame(height: 220)
    }

    // Convert angle (degrees) to position
    private func position(center: CGPoint, radius: CGFloat, angleDegrees: Double) -> CGPoint {
        let radians = CGFloat((angleDegrees - 90) * .pi / 180)  // Adjust so 0° is at 12 o'clock
        return CGPoint(
            x: center.x + radius * Darwin.cos(radians),
            y: center.y + radius * Darwin.sin(radians)
        )
    }

    // Check if angle is on left side of chart (90° to 270°)
    private func isOnLeftSide(angleDegrees: Double) -> Bool {
        let normalized = (angleDegrees + 360).truncatingRemainder(dividingBy: 360)
        return normalized > 90 && normalized < 270
    }
}

// Custom shape for a donut segment
struct DonutSegmentShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadiusRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio

        var path = Path()

        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle - .degrees(90),
            endAngle: endAngle - .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: center.x + innerRadius * cos(CGFloat((endAngle - .degrees(90)).radians)),
            y: center.y + innerRadius * sin(CGFloat((endAngle - .degrees(90)).radians))
        ))

        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle - .degrees(90),
            endAngle: startAngle - .degrees(90),
            clockwise: true
        )

        path.closeSubpath()

        return path
    }
}
