//
//  PlainWeightsApp.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import SwiftUI
import SwiftData

@main
struct PlainWeightsApp: App {
    @State private var themeManager = ThemeManager()
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Exercise.self, ExerciseSet.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            container = try ModelContainer(for: schema, configurations: [config])
            print("✅ ModelContainer created with CloudKit sync enabled")
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ThemeAwareContentView(themeManager: themeManager)
                .dynamicTypeSize(.large)
        }
        .modelContainer(container)
    }
}

/// Wrapper view that tracks system color scheme and updates ThemeManager
private struct ThemeAwareContentView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    let themeManager: ThemeManager

    var body: some View {
        ContentView()
            .environment(themeManager)
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            .onChange(of: systemColorScheme, initial: true) { _, newValue in
                themeManager.systemColorScheme = newValue
            }
    }
}
