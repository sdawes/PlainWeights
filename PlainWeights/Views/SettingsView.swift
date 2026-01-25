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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Theme")
                            .font(.body)

                        Spacer()

                        HStack(spacing: 8) {
                            // Light button
                            Button {
                                themeManager.currentTheme = .light
                            } label: {
                                Label("Light", systemImage: "sun.max.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(themeManager.currentTheme == .light ? .primary : .secondary)
                            .opacity(themeManager.currentTheme == .light ? 1.0 : 0.5)

                            // Dark button
                            Button {
                                themeManager.currentTheme = .dark
                            } label: {
                                Label("Dark", systemImage: "moon.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(themeManager.currentTheme == .dark ? .primary : .secondary)
                            .opacity(themeManager.currentTheme == .dark ? 1.0 : 0.5)
                        }
                    }
                } header: {
                    Text("APPEARANCE")
                        .font(.caption)
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
        }
    }
}
