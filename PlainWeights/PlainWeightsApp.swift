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

    init() {
        // Customize inline title appearance: bold (default is semibold 17pt)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        appearance.shadowColor = .clear  // Hide native nav bar separator
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

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
