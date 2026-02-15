//
//  ExerciseNameField.swift
//  PlainWeights
//
//  Exercise name text field with duplicate name validation.
//

import SwiftUI

struct ExerciseNameField: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var name: String
    let isFocused: Bool
    let isDuplicate: Bool
    var onSubmit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Name")
                .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            TextField("e.g. Romanian Deadlift", text: $name)
                .font(themeManager.effectiveTheme.dataFont(size: 20))
                .foregroundStyle(themeManager.effectiveTheme.primaryText)
                .padding(16)
                .frame(height: 56)
                .background(themeManager.effectiveTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isFocused ? themeManager.effectiveTheme.primaryText : themeManager.effectiveTheme.borderColor,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .onSubmit(onSubmit)

            if isDuplicate {
                Text("An exercise with this name already exists")
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(.red)
            }
        }
    }
}
