//
//  InlineNotesComponent.swift
//  PlainWeights
//
//  Inline notes component for exercise detail view with auto-save.
//

import SwiftUI

struct InlineNotesComponent: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var noteText: String
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(themeManager.currentTheme.headlineFont)
                .foregroundStyle(themeManager.currentTheme.primaryText)

            TextEditor(text: $noteText)
                .font(themeManager.currentTheme.bodyFont)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80, maxHeight: 150)
                .padding(12)
                .background(themeManager.currentTheme.muted)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
        .onChange(of: noteText) { _, _ in
            onSave()  // Auto-save on every change
        }
    }
}
