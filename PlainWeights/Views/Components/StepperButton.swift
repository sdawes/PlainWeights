//
//  StepperButton.swift
//  PlainWeights
//
//  Reusable +/- stepper button for numeric input fields.
//

import SwiftUI

struct StepperButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let systemName: String  // "plus" or "minus"
    let size: CGFloat
    let action: () -> Void

    init(systemName: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.systemName = systemName
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .frame(width: size, height: size)
                .background(themeManager.currentTheme.muted)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
