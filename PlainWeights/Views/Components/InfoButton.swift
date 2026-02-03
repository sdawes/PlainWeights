//
//  InfoButton.swift
//  PlainWeights
//
//  Reusable info button that shows a popover with explanatory text.
//

import SwiftUI

struct InfoButton: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var showPopover = false
    let text: String

    var body: some View {
        Button {
            showPopover = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover) {
            Text(text)
                .font(themeManager.currentTheme.subheadlineFont)
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .padding(12)
                .presentationCompactAdaptation(.popover)
        }
    }
}
