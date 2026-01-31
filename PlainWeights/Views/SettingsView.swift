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

            // Chart section
            VStack(alignment: .leading, spacing: 12) {
                Text("Charts")
                    .font(themeManager.currentTheme.subheadlineFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                Toggle("Show charts by default", isOn: Binding(
                    get: { themeManager.chartVisibleByDefault },
                    set: { themeManager.chartVisibleByDefault = $0 }
                ))
                .font(themeManager.currentTheme.bodyFont)
                .tint(themeManager.currentTheme.primary)
            }

            Spacer()
        }
        .padding(24)
        .background(themeManager.currentTheme.background)
    }
}
