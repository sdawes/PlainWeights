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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .dynamicTypeSize(.large)
        }
        .modelContainer(for: [Exercise.self, ExerciseSet.self])
    }
}
