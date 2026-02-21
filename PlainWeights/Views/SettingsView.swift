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
    @State private var showingHelp = false

    #if DEBUG
    @State private var showingGenerateDataAlert = false
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Appearance section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance")
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                            .padding(.top, 24)

                        themePickerRow()
                    }

                    // Display section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display")
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                        weightUnitPickerRow()
                    }

                    // Charts section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Charts")
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                        settingsToggleRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Show charts",
                            subtitle: "by default",
                            isOn: Binding(
                                get: { themeManager.chartVisibleByDefault },
                                set: { themeManager.chartVisibleByDefault = $0 }
                            )
                        )

                        settingsToggleRow(
                            icon: "line.diagonal",
                            title: "Show trend lines",
                            subtitle: "by default",
                            isOn: Binding(
                                get: { themeManager.showTrendLineByDefault },
                                set: { themeManager.showTrendLineByDefault = $0 }
                            )
                        )

                        settingsToggleRow(
                            icon: "note.text",
                            title: "Show notes",
                            subtitle: "by default",
                            isOn: Binding(
                                get: { themeManager.notesVisibleByDefault },
                                set: { themeManager.notesVisibleByDefault = $0 }
                            )
                        )

                        settingsToggleRow(
                            icon: "tag",
                            title: "Tag breakdown",
                            subtitle: "by default",
                            isOn: Binding(
                                get: { themeManager.tagBreakdownVisible },
                                set: { themeManager.tagBreakdownVisible = $0 }
                            )
                        )
                    }

                    // Help section
                    settingsRow(
                        icon: "questionmark.circle",
                        title: "How It Works",
                        value: nil,
                        showChevron: true,
                        tinted: true
                    ) {
                        showingHelp = true
                    }

                    // Data section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data")
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

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
                            .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

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

                    }
                    #endif

                    Spacer(minLength: 40)

                    // Footer
                    VStack(spacing: 4) {
                        Text("PlainWeights v1.0")
                            .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        Text("A simple workout tracking tool")
                            .font(themeManager.effectiveTheme.interFont(size: 14, weight: .regular))
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .sheet(isPresented: $showingHelp) {
            HelpView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
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
                TestDataGenerator.generateTestData(container: modelContext.container)
                dismiss()
            }
        } message: {
            Text("This will DELETE all your existing workout data and replace it with test data. This cannot be undone.")
        }
        #endif
    }

    // MARK: - Settings Row Components

    @ViewBuilder
    private func themePickerRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: themeIcon)
                .font(.system(size: 18))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .frame(width: 24)

            Text("Theme")
                .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .lineLimit(1)

            Spacer()

            Picker("", selection: Binding(
                get: { themeManager.currentTheme },
                set: { themeManager.currentTheme = $0 }
            )) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.menu)
            .tint(themeManager.effectiveTheme.mutedForeground)
        }
        .frame(height: 31)
        .padding(16)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    private var themeIcon: String {
        switch themeManager.currentTheme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    @ViewBuilder
    private func weightUnitPickerRow() -> some View {
        settingsToggleRow(
            icon: "scalemass",
            title: "Metric units",
            isOn: Binding(
                get: { themeManager.weightUnit.isMetric },
                set: { themeManager.weightUnit = $0 ? .kg : .lbs }
            )
        )
    }

    @ViewBuilder
    private func settingsRow(
        icon: String,
        title: String,
        value: String?,
        isDestructive: Bool = false,
        showChevron: Bool = false,
        tinted: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isDestructive ? .red : themeManager.effectiveTheme.primaryText)
                    .frame(width: 24)

                Text(title)
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                    .foregroundStyle(isDestructive ? .red : themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(themeManager.effectiveTheme.interFont(size: 16, weight: .regular))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .lineLimit(1)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
            }
            .frame(height: 31)
            .padding(16)
            .background(tinted ? themeManager.effectiveTheme.primary.opacity(0.08) : themeManager.effectiveTheme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(themeManager.effectiveTheme.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func settingsToggleRow(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(themeManager.effectiveTheme.interFont(size: 16, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(themeManager.effectiveTheme.interFont(size: 13, weight: .regular))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .lineLimit(1)
                }
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(16)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    private func deleteAllExercises() {
        do {
            try modelContext.delete(model: Exercise.self)
            try modelContext.save()
        } catch { }
    }
}
