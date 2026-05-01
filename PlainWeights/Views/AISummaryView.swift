//
//  AISummaryView.swift
//  PlainWeights
//
//  Sheet that asks AISummaryService to generate a summary of the most
//  recent workout, then renders the result. UI only — all AI logic
//  lives in AISummaryService.
//

import SwiftUI
import SwiftData

struct AISummaryView: View {
    /// Which slice of training data to summarise.
    let scope: AISummaryScope

    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    /// Sourced from SwiftData so the sheet can be presented anywhere
    /// without needing the parent to pass data in.
    @Query private var allSets: [ExerciseSet]

    /// One of these will be set when the task completes.
    @State private var summary: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header — title + dismiss
            HStack {
                Text(scope.rawValue)
                    .font(themeManager.effectiveTheme.title3Font)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }

            // One of three states: loading, summary, error
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Generating summary…")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            } else if let summary {
                ScrollView {
                    Text(summary)
                        .font(themeManager.effectiveTheme.bodyFont)
                        .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func generate() async {
        isLoading = true
        defer { isLoading = false }

        do {
            summary = try await AISummaryService.generateLastSessionSummary(
                from: allSets,
                weightUnit: themeManager.weightUnit
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
