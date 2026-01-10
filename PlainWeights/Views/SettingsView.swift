//
//  SettingsView.swift
//  PlainWeights
//
//  Settings screen for app configuration
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var showingThemePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack {
                            Text("Theme")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(themeManager.currentTheme.displayName)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("APPEARANCE")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerSheet()
                    .preferredColorScheme(themeManager.currentTheme.colorScheme)
            }
        }
    }
}
