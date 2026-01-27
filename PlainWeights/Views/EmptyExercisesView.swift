//
//  EmptyExercisesView.swift
//  PlainWeights
//
//  Empty state screen matching Figma Make design
//

import SwiftUI

struct EmptyExercisesView: View {
    @Environment(ThemeManager.self) private var themeManager
    let onAddExercise: () -> Void

    var body: some View {
        // First-time user experience
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 32)

                // Sprite (no circle border)
                RetroLifterView(pixelSize: 4)

                // Welcome text
                VStack(spacing: 12) {
                    Text("Welcome to PlainWeights")
                        .font(themeManager.currentTheme.interFont(size: 24, weight: .medium))
                        .foregroundStyle(themeManager.currentTheme.primaryText)

                    Text("A minimal, text-focused gym tracker with a digital ledger aesthetic. Track your progress with precision.")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 32)

                // Features card
                VStack(alignment: .leading, spacing: 12) {
                    coloredSetTypesRow
                    featureRow("Track max weight, reps, and total volume")
                    featureRow("Compare with last session or all-time best")
                    featureRow("Visual progress charts and history")
                }
                .padding(20)
                .background(themeManager.currentTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
                )
                .padding(.top, 32)

                // CTA section
                VStack(spacing: 16) {
                    Text("Get started by adding your first exercise")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)

                    Button(action: onAddExercise) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add First Exercise")
                        }
                        .font(themeManager.currentTheme.headlineFont)
                        .foregroundStyle(themeManager.currentTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.currentTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.top, 32)

                Spacer()
                    .frame(height: 80)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Feature row with colored set types
    private var coloredSetTypesRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(themeManager.currentTheme.primaryText)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            (Text("Color-coded set types: ")
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
             + Text("Warm-up")
                .foregroundStyle(.orange)
             + Text(", ")
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
             + Text("Bonus")
                .foregroundStyle(.green)
             + Text(", ")
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
             + Text("Drop sets")
                .foregroundStyle(.blue))
                .font(themeManager.currentTheme.subheadlineFont)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // Feature row with bullet point
    private func featureRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(themeManager.currentTheme.primaryText)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(themeManager.currentTheme.subheadlineFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    VStack {
        EmptyExercisesView(onAddExercise: {})
    }
    .environment(ThemeManager())
}
