//
//  SettingsView.swift
//  PlainWeights
//
//  Settings screen for app configuration
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    @State private var showingDeleteAllAlert = false
    @State private var showingThemePicker = false

    #if DEBUG
    @State private var showingGenerateDataAlert = false
    @State private var showingClearDataAlert = false
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(themeManager.currentTheme.title3Font)
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            // Header divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)
                .padding(.horizontal, -24)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Appearance section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance")
                            .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)
                            .padding(.top, 24)

                        settingsRow(
                            icon: themeManager.currentTheme == .dark ? "moon.fill" : "sun.max.fill",
                            title: "Theme",
                            value: themeManager.currentTheme == .dark ? "Dark" : "Light"
                        ) {
                            themeManager.currentTheme = themeManager.currentTheme == .dark ? .light : .dark
                        }
                    }

                    // Display section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display")
                            .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)

                        settingsToggleRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Show charts by default",
                            isOn: Binding(
                                get: { themeManager.chartVisibleByDefault },
                                set: { themeManager.chartVisibleByDefault = $0 }
                            )
                        )

                        settingsToggleRow(
                            icon: "note.text",
                            title: "Show notes by default",
                            isOn: Binding(
                                get: { themeManager.notesVisibleByDefault },
                                set: { themeManager.notesVisibleByDefault = $0 }
                            )
                        )
                    }

                    // Data section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data")
                            .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)

                        settingsRow(
                            icon: "trash",
                            title: "Delete All Exercises",
                            value: nil,
                            isDestructive: true
                        ) {
                            showingDeleteAllAlert = true
                        }
                    }

                    #if DEBUG
                    // Developer Tools section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Developer Tools")
                            .font(themeManager.currentTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)

                        settingsRow(
                            icon: "terminal",
                            title: "Print Data to Console",
                            value: nil
                        ) {
                            TestDataGenerator.printCurrentData(modelContext: modelContext)
                        }

                        settingsRow(
                            icon: "wand.and.stars",
                            title: "Generate Test Data",
                            value: nil,
                            isDestructive: true
                        ) {
                            showingGenerateDataAlert = true
                        }

                        settingsRow(
                            icon: "trash",
                            title: "Clear All Data",
                            value: nil,
                            isDestructive: true
                        ) {
                            showingClearDataAlert = true
                        }
                    }
                    #endif

                    Spacer(minLength: 40)

                    // Footer
                    VStack(spacing: 4) {
                        Text("PlainWeights v1.0")
                            .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(themeManager.currentTheme.primaryText)
                        Text("A simple workout tracking tool")
                            .font(themeManager.currentTheme.interFont(size: 14, weight: .regular))
                            .foregroundStyle(themeManager.currentTheme.mutedForeground)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
        .alert("Delete All Exercises?", isPresented: $showingDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Everything", role: .destructive) {
                deleteAllExercises()
            }
        } message: {
            Text("This will permanently delete ALL your exercises and workout history. This action cannot be undone.")
        }
        #if DEBUG
        .alert("Generate Test Data?", isPresented: $showingGenerateDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete & Generate", role: .destructive) {
                TestDataGenerator.generateTestData(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("This will DELETE all your existing workout data and replace it with test data. This cannot be undone.")
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                TestDataGenerator.clearAllData(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("This will DELETE all your workout data including exercises and sets. This cannot be undone.")
        }
        #endif
    }

    // MARK: - Settings Row Components

    @ViewBuilder
    private func settingsRow(
        icon: String,
        title: String,
        value: String?,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isDestructive ? .red : themeManager.currentTheme.primaryText)
                    .frame(width: 24)

                Text(title)
                    .font(themeManager.currentTheme.interFont(size: 16, weight: .medium))
                    .foregroundStyle(isDestructive ? .red : themeManager.currentTheme.primaryText)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(themeManager.currentTheme.interFont(size: 16, weight: .regular))
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
            }
            .padding(16)
            .background(themeManager.currentTheme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func settingsToggleRow(
        icon: String,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .frame(width: 24)

            Text(title)
                .font(themeManager.currentTheme.interFont(size: 16, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.primaryText)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(16)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }

    private func deleteAllExercises() {
        do {
            try modelContext.delete(model: Exercise.self)
            try modelContext.save()
        } catch {
            print("Failed to delete all exercises: \(error)")
        }
    }
}
