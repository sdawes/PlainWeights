//
//  SheetHeader.swift
//  PlainWeights
//
//  Reusable header component for sheet/modal views with title and dismiss button.
//

import SwiftUI

struct SheetHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let dismiss: DismissAction
    var lineLimit: Int = 1

    var body: some View {
        HStack {
            Text(title)
                .font(themeManager.effectiveTheme.title3Font)
                .lineLimit(lineLimit)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            }
            .buttonStyle(.plain)
        }
    }
}
