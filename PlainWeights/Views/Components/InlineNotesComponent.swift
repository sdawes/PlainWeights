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

    // Debounce save to avoid database write on every keystroke
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder text
            if noteText.isEmpty {
                Text("Add notes about form, cues, or tips...")
                    .font(themeManager.effectiveTheme.bodyFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }

            // Text editor
            TextEditor(text: $noteText)
                .font(themeManager.effectiveTheme.bodyFont)
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80, maxHeight: 150)
                .padding(12)
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
        .onChange(of: noteText) { _, _ in
            // Cancel previous pending save and start a new debounce timer
            saveTask?.cancel()
            saveTask = Task {
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                onSave()
            }
        }
        .onDisappear {
            // Flush any pending save when leaving the view
            saveTask?.cancel()
            onSave()
        }
    }
}
