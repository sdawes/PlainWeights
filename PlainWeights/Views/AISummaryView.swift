//
//  AISummaryView.swift
//  PlainWeights
//
//  Sheet that asks AISummaryService to generate a structured WorkoutAnalysis
//  and renders each field as a labelled section. UI only.
//

import SwiftUI
import SwiftData

struct AISummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    /// Sourced from SwiftData so the sheet can be presented anywhere
    /// without needing the parent to pass data in.
    @Query private var allSets: [ExerciseSet]

    /// One of these will be set when the task completes.
    @State private var analysis: WorkoutAnalysis?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header — title + dismiss
            HStack {
                Text("Workout insights")
                    .font(themeManager.effectiveTheme.title3Font)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Generating insights…")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            } else if let analysis {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        section(eyebrow: "WHAT YOU TRAINED", body: analysis.coverage)
                        section(eyebrow: "PROGRESS", body: analysis.progress)
                        section(eyebrow: "RECOMMENDATION", body: analysis.recommendation)
                    }
                }
                .scrollIndicators(.hidden)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(themeManager.effectiveTheme.subheadlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .task {
            await generate()
        }
    }

    @ViewBuilder
    private func section(eyebrow: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            Text(body)
                .font(themeManager.effectiveTheme.bodyFont)
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(3)
        }
    }

    private func generate() async {
        isLoading = true
        defer { isLoading = false }

        do {
            analysis = try await AISummaryService.generateAnalysis(
                from: allSets,
                weightUnit: themeManager.weightUnit
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
