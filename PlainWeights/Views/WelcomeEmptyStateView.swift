//
//  WelcomeEmptyStateView.swift
//  PlainWeights
//
//  First-launch screen shown when the user has zero exercises. Completely
//  separate from ExerciseListView so the populated-list code (the 99.9% path)
//  stays untouched while the empty state evolves.
//

import SwiftUI

struct WelcomeEmptyStateView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var navigationPath: NavigationPath

    @State private var showingAddExercise = false
    @State private var showingSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("AppIconImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(.rect(cornerRadius: 28))
                .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
                // Force the asset's light/dark luminosity variant to follow the
                // in-app theme rather than the device colour scheme.
                .environment(\.colorScheme, themeManager.effectiveTheme.colorScheme ?? .light)
                .padding(.top, 40)
                .padding(.bottom, 24)

            Text("Welcome to")
                .font(themeManager.effectiveTheme.interFont(size: 32, weight: .bold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

            Text("plainweights")
                .font(themeManager.effectiveTheme.interFont(size: 32, weight: .bold))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .padding(.bottom, 22)

            subtitleText
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // iCloud footer — grey hairline divider above, bold icon + text inline left.
            // Trailing padding keeps the text clear of the FAB column.
            VStack(alignment: .leading, spacing: 18) {
                Rectangle()
                    .fill(themeManager.effectiveTheme.dividerColor)
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "icloud.and.arrow.down")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                    Text("Returning user? Data may take a few minutes to sync from iCloud.")
                        .font(themeManager.effectiveTheme.interFont(size: 16, weight: .regular))
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.trailing, 70)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .background(AnimatedGradientBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.effectiveTheme.textColor)
                }
                .accessibilityLabel("Settings")
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            Button(action: { showingAddExercise = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(themeManager.effectiveTheme.background)
            }
            .frame(width: 55, height: 55)
            .background(themeManager.effectiveTheme.primary)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .accessibilityLabel("Add exercise")
            .padding(.trailing, 20)
            .padding(.bottom, 3)
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { newExercise in
                navigationPath.append(newExercise)
            }
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }

    // Subtitle composed of three Text segments so the inline plus.circle.fill
    // SF Symbol can be tinted with the theme's primary colour (black in light,
    // white in dark — mirroring the FAB) while the surrounding copy stays muted.
    private var subtitleText: Text {
        let font = themeManager.effectiveTheme.interFont(size: 17, weight: .regular)
        let muted = themeManager.effectiveTheme.mutedForeground
        let primary = themeManager.effectiveTheme.primary

        return Text("Add your first exercise by tapping the ")
            .font(font)
            .foregroundStyle(muted)
            + Text(Image(systemName: "plus.circle.fill"))
            .font(font)
            .foregroundStyle(primary)
            + Text(" at the bottom.")
            .font(font)
            .foregroundStyle(muted)
    }
}
