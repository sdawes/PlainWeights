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
                            .font(.system(.body, design: .monospaced))

                        Spacer()

                        Menu {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Button {
                                    themeManager.currentTheme = theme
                                } label: {
                                    HStack {
                                        Text(theme.displayName)
                                        if theme == themeManager.currentTheme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(themeManager.currentTheme.displayName)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                            }
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        }
                    }
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
        }
    }
}
