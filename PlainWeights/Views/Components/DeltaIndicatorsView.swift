//
//  DeltaIndicatorsView.swift
//  PlainWeights
//
//  Displays three delta indicator icons showing whether max weight,
//  max reps, and total volume improved vs the previous session.
//

import SwiftUI

/// Row of three delta indicator icons (weight, reps, volume)
struct DeltaIndicatorsView: View {
    @Environment(ThemeManager.self) private var themeManager
    let deltas: ExerciseDeltas

    var body: some View {
        HStack(spacing: 0) {
            deltaIcon("scalemass.fill", direction: deltas.weight)
                .frame(width: 20)
            deltaIcon("repeat", direction: deltas.reps)
                .frame(width: 20)
            deltaIcon("chart.bar.fill", direction: deltas.volume)
                .frame(width: 20)
        }
    }

    @ViewBuilder
    private func deltaIcon(_ symbolName: String, direction: DeltaDirection) -> some View {
        Image(systemName: symbolName)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(direction.color)
    }
}

/// Info popover explaining what the delta indicators mean
struct DeltaInfoPopover: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compared to previous session")
                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                infoRow(symbol: "scalemass.fill", label: "Max weight")
                infoRow(symbol: "repeat", label: "Max reps")
                infoRow(symbol: "chart.bar.fill", label: "Total volume")
            }

            Divider()

            HStack(spacing: 16) {
                legendItem(color: DeltaDirection.up.color, label: "Increase")
                legendItem(color: DeltaDirection.down.color, label: "Decrease")
                legendItem(color: DeltaDirection.same.color, label: "No change")
            }
            .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
        .padding(16)
        .presentationCompactAdaptation(.popover)
    }

    private func infoRow(symbol: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .frame(width: 20)
            Text(label)
                .font(themeManager.effectiveTheme.interFont(size: 13, weight: .regular))
                .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(themeManager.effectiveTheme.captionFont)
        }
    }
}
