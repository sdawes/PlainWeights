//
//  DeltaIndicatorsView.swift
//  PlainWeights
//
//  Displays three delta indicator arrows showing whether max weight,
//  max reps, and total volume improved vs the previous session.
//

import SwiftUI

/// Row of three delta indicator arrows (weight, reps, volume)
struct DeltaIndicatorsView: View {
    let deltas: ExerciseDeltas

    var body: some View {
        HStack(spacing: 0) {
            deltaIcon(direction: deltas.weight)
                .frame(width: 20)
            deltaIcon(direction: deltas.reps)
                .frame(width: 20)
            deltaIcon(direction: deltas.volume)
                .frame(width: 20)
        }
    }

    @ViewBuilder
    private func deltaIcon(direction: DeltaDirection) -> some View {
        Image(systemName: direction.arrowSymbol)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(direction.color)
    }
}

/// Info popover explaining what the W / R / V column arrows mean
struct DeltaInfoPopover: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compared to previous session")
                .font(themeManager.effectiveTheme.interFont(size: 14, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                columnRow(letter: "W", label: "Max weight")
                columnRow(letter: "R", label: "Max reps")
                columnRow(letter: "V", label: "Total volume")
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                directionRow(direction: .up, label: "Increased")
                directionRow(direction: .down, label: "Decreased")
                directionRow(direction: .same, label: "No change")
            }
        }
        .padding(16)
        .presentationCompactAdaptation(.popover)
    }

    private func columnRow(letter: String, label: String) -> some View {
        HStack(spacing: 10) {
            Text(letter)
                .font(themeManager.effectiveTheme.interFont(size: 12, weight: .semibold))
                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                .frame(width: 16, alignment: .center)
            Text(label)
                .font(themeManager.effectiveTheme.interFont(size: 13))
                .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
    }

    private func directionRow(direction: DeltaDirection, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: direction.arrowSymbol)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(direction.color)
                .frame(width: 16, alignment: .center)
            Text(label)
                .font(themeManager.effectiveTheme.interFont(size: 13))
                .foregroundStyle(themeManager.effectiveTheme.secondaryText)
        }
    }
}
