//
//  ExerciseAnalysisView.swift
//  PlainWeights
//
//  Sheet that asks ExerciseAnalysisService to generate a structured
//  ExerciseAnalysis for a single exercise and renders each field as a
//  labelled section. UI only — sister to AISummaryView, scoped to one
//  exercise instead of the whole training history.
//

import SwiftUI
import SwiftData

struct ExerciseAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise

    @State private var analysis: ExerciseAnalysis?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header — title + dismiss
            HStack {
                Text("Exercise insights")
                    .font(themeManager.effectiveTheme.title3Font)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }

            // On-device AI disclaimer
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(.purple)
                Text("Powered by Apple Intelligence. Everything runs on your device — your data never leaves your phone. Summaries are a smart best guess and may occasionally miss context.")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
            }

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Analysing \(exercise.name)…")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            } else if let analysis {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        section(eyebrow: "PROGRESSION", body: analysis.progression)
                        section(eyebrow: "EFFORT", body: analysis.effort)
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

            // Try-again — visible whenever a result or error is showing.
            // Uses varied sampling so retries actually produce different
            // wording instead of the same deterministic output.
            if !isLoading && (analysis != nil || errorMessage != nil) {
                Button {
                    Task { await regenerate() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                        Text("Try again")
                            .font(themeManager.effectiveTheme.interFont(size: 13, weight: .medium))
                    }
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(themeManager.effectiveTheme.muted)
                    .clipShape(.capsule)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .task {
            await generate(regenerate: false)
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

    private func generate(regenerate: Bool) async {
        analysis = nil
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            analysis = try await ExerciseAnalysisService.generateAnalysis(
                for: exercise,
                weightUnit: themeManager.weightUnit,
                regenerate: regenerate
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func regenerate() async {
        await generate(regenerate: true)
    }
}
