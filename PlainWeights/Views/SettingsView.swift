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

    #if DEBUG
    @State private var showingGenerateDataAlert = false
    @State private var showingClearDataAlert = false
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("Settings")
                    .font(themeManager.currentTheme.title3Font)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)

            // Theme section
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                HStack(spacing: 8) {
                    // Light pill
                    Button {
                        themeManager.currentTheme = .light
                    } label: {
                        Label("Light", systemImage: "sun.max.fill")
                            .font(themeManager.currentTheme.subheadlineFont)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeManager.currentTheme == .light ? themeManager.currentTheme.primary : themeManager.currentTheme.muted)
                            .foregroundStyle(themeManager.currentTheme == .light ? .white : themeManager.currentTheme.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    // Dark pill
                    Button {
                        themeManager.currentTheme = .dark
                    } label: {
                        Label("Dark", systemImage: "moon.fill")
                            .font(themeManager.currentTheme.subheadlineFont)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeManager.currentTheme == .dark ? themeManager.currentTheme.primary : themeManager.currentTheme.muted)
                            .foregroundStyle(themeManager.currentTheme == .dark ? .white : themeManager.currentTheme.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Display section
            VStack(alignment: .leading, spacing: 12) {
                Text("Display")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                Toggle("Show charts by default", isOn: Binding(
                    get: { themeManager.chartVisibleByDefault },
                    set: { themeManager.chartVisibleByDefault = $0 }
                ))
                .font(themeManager.currentTheme.bodyFont)
                .tint(themeManager.currentTheme.primary)

                Toggle("Show notes by default", isOn: Binding(
                    get: { themeManager.notesVisibleByDefault },
                    set: { themeManager.notesVisibleByDefault = $0 }
                ))
                .font(themeManager.currentTheme.bodyFont)
                .tint(themeManager.currentTheme.primary)
            }

            // Data section
            VStack(alignment: .leading, spacing: 12) {
                Text("Data")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                Button {
                    showingDeleteAllAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete All Exercises")
                    }
                    .font(themeManager.currentTheme.bodyFont)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(themeManager.currentTheme.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            #if DEBUG
            // Developer Tools section
            VStack(alignment: .leading, spacing: 12) {
                Text("Developer Tools")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                VStack(spacing: 8) {
                    // Print Data button
                    Button {
                        TestDataGenerator.printCurrentData(modelContext: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "terminal")
                            Text("Print Data to Console")
                        }
                        .font(themeManager.currentTheme.bodyFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(themeManager.currentTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    // Generate and Clear buttons side by side
                    HStack(spacing: 8) {
                        Button {
                            showingGenerateDataAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Generate")
                            }
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(themeManager.currentTheme.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)

                        Button {
                            showingClearDataAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear All")
                            }
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(themeManager.currentTheme.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            #endif

            Spacer()
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
            }
        } message: {
            Text("This will DELETE all your existing workout data and replace it with test data. This cannot be undone.")
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                TestDataGenerator.clearAllData(modelContext: modelContext)
            }
        } message: {
            Text("This will DELETE all your workout data including exercises and sets. This cannot be undone.")
        }
        #endif
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
