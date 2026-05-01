//
//  GroupNameSheet.swift
//  PlainWeights
//
//  Sheet for naming an ExerciseGroup. Used in two modes:
//  - .create: when starting the new-group flow on the Groups screen.
//             Primary action is "Next"; tapping it dismisses and signals
//             the parent to present the exercise-selection cover.
//  - .rename: when renaming an existing group from the action row inside
//             an expanded card. Primary action is "Save"; tapping it
//             commits the name change and dismisses.
//
//  Visual style matches AddExerciseView so the sheet experience is
//  consistent across the app (same header layout, same card chrome,
//  same primary-coloured Save button).
//

import SwiftUI

struct GroupNameSheet: View {
    enum Mode {
        case create
        case rename(currentName: String)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    let mode: Mode
    /// Called with the trimmed name when the user taps the primary action.
    let onSubmit: (String) -> Void

    @State private var name: String
    @FocusState private var nameFieldFocused: Bool

    init(mode: Mode, onSubmit: @escaping (String) -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .create:
            _name = State(initialValue: "")
        case .rename(let current):
            _name = State(initialValue: current)
        }
    }

    private var screenTitle: String {
        switch mode {
        case .create: return "New Group"
        case .rename: return "Rename Group"
        }
    }

    private var primaryActionLabel: String {
        switch mode {
        case .create: return "Next"
        case .rename: return "Save"
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — matches AddExerciseView layout
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")

                Text(screenTitle)
                    .font(themeManager.effectiveTheme.title3Font)
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)

                Spacer()

                Button(action: commit) {
                    Text(primaryActionLabel)
                        .font(themeManager.effectiveTheme.headlineFont)
                        .foregroundStyle(
                            canSave
                                ? themeManager.effectiveTheme.primary
                                : themeManager.effectiveTheme.primary.opacity(0.4)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .accessibilityLabel(primaryActionLabel)
            }
            .padding(.bottom, 20)

            // Name card
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .textCase(.uppercase)
                    .tracking(0.8)

                TextField(
                    "",
                    text: $name,
                    prompt: Text("e.g. Leg Day")
                        .foregroundStyle(themeManager.effectiveTheme.primary.opacity(0.18))
                )
                .focused($nameFieldFocused)
                .font(themeManager.effectiveTheme.dataFont(size: 20))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .submitLabel(.done)
                .onSubmit { commit() }
                .onChange(of: name) { _, newValue in
                    if newValue.count > 50 { name = String(newValue.prefix(50)) }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.effectiveTheme.cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(24)
        .background(themeManager.effectiveTheme.surfaceColor)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .task {
            // Brief delay so the sheet's slide-up finishes before the
            // keyboard rises — feels less abrupt.
            try? await Task.sleep(for: .milliseconds(200))
            nameFieldFocused = true
        }
    }

    private func commit() {
        guard canSave else { return }
        onSubmit(trimmedName)
        dismiss()
    }
}
