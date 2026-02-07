//
//  TextInputField.swift
//  PlainWeights
//
//  Reusable text input field component with consistent styling.
//

import SwiftUI

struct TextInputField: View {
    @Environment(ThemeManager.self) private var themeManager
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let isFocused: Bool
    var textAlignment: TextAlignment = .center

    var body: some View {
        TextField(placeholder, text: $text)
            .font(themeManager.effectiveTheme.dataFont(size: 20))
            .keyboardType(keyboardType)
            .multilineTextAlignment(textAlignment)
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
    }
}
