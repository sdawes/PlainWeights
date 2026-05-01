//
//  SaveGroupSheet.swift
//  PlainWeights
//
//  Sheet that prompts the user for a group name when saving a new
//  ExerciseGroup from the selection in ExerciseListView.
//

import SwiftUI

struct SaveGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    /// Number of exercises that will be saved into the new group.
    let exerciseCount: Int

    /// Called with the trimmed group name when the user taps Save.
    let onSave: (String) -> Void

    @State private var name: String = ""
    @FocusState private var nameFieldFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header — title + dismiss
            HStack {
                Text("Save group")
                    .font(themeManager.effectiveTheme.title3Font)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
            }

            // Selection count subtext
            Text("\(exerciseCount) \(exerciseCount == 1 ? "exercise" : "exercises") selected")
                .font(themeManager.effectiveTheme.subheadlineFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Group name")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

                TextField("e.g. Leg Day", text: $name)
                    .font(themeManager.effectiveTheme.bodyFont)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .focused($nameFieldFocused)
                    .padding(16)
                    .frame(height: 56)
                    .background(themeManager.effectiveTheme.muted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(themeManager.effectiveTheme.borderColor, lineWidth: 1)
                    )
                    .submitLabel(.done)
                    .onSubmit { commitIfValid() }
            }

            Spacer()

            // Primary CTA
            Button(action: commitIfValid) {
                Text("Save")
                    .font(themeManager.effectiveTheme.headlineFont)
                    .foregroundStyle(themeManager.effectiveTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.effectiveTheme.primary.opacity(canSave ? 1 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        .padding(24)
        .background(themeManager.effectiveTheme.background)
        .presentationDetents([.medium])
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .task {
            // Brief delay so the sheet animation finishes before the
            // keyboard slides up — feels less abrupt.
            try? await Task.sleep(for: .milliseconds(200))
            nameFieldFocused = true
        }
    }

    private func commitIfValid() {
        guard canSave else { return }
        onSave(trimmedName)
        dismiss()
    }
}
