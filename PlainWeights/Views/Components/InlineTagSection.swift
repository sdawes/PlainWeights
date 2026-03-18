//
//  InlineTagSection.swift
//  PlainWeights
//
//  Inline tag input that shows pills and a text cursor in a single flow.
//  Matches the "Typing Primary" whiteboard design.
//

import SwiftUI

struct InlineTagSection<Accessory: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let emptyHint: String
    @Binding var tags: [String]
    @Binding var input: String
    var isFocused: FocusState<Bool>.Binding
    let isSecondary: Bool
    var suggestions: [String] = []
    var onSubmit: () -> Void = {}
    let titleAccessory: Accessory

    @State private var cachedFilteredSuggestions: [String] = []

    private var tagColor: Color {
        isSecondary
            ? themeManager.effectiveTheme.secondaryTagText
            : themeManager.effectiveTheme.primaryTagText
    }

    private var dotColor: Color {
        tagColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label
            HStack(spacing: 6) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(themeManager.effectiveTheme.interFont(size: 11, weight: .semibold))
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    .textCase(.uppercase)
                    .tracking(0.8)
                titleAccessory
            }
            .padding(.bottom, 8)

            // Tags + inline input (always show the text field so it's tappable)
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    TagPillView(tag: tag, isSecondary: isSecondary) {
                        withAnimation { tags.removeAll { $0 == tag } }
                    }
                }

                // Inline text field
                TextField("", text: $input, prompt: Text("add tag…").foregroundStyle(themeManager.effectiveTheme.primary.opacity(0.18)))
                    .focused(isFocused)
                    .font(themeManager.effectiveTheme.interFont(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .frame(minWidth: 70)
                    .fixedSize(horizontal: false, vertical: true)
                    .onSubmit {
                        addTag()
                        onSubmit()
                    }
            }

            // Autocomplete suggestions
            if !cachedFilteredSuggestions.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(cachedFilteredSuggestions, id: \.self) { suggestion in
                        Button {
                            selectSuggestion(suggestion)
                        } label: {
                            suggestionLabel(suggestion)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 6)
            }
        }
        .onChange(of: input) { _, newValue in
            if newValue.count > 20 { input = String(newValue.prefix(20)) }
            updateFilteredSuggestions()
        }
        .onChange(of: tags) { _, _ in updateFilteredSuggestions() }
    }

    @ViewBuilder
    private func suggestionLabel(_ suggestion: String) -> some View {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        let bg = isSecondary
            ? themeManager.effectiveTheme.secondaryTagBackground.opacity(0.5)
            : themeManager.effectiveTheme.primaryTagBackground.opacity(0.5)
        let borderColor = isSecondary
            ? themeManager.effectiveTheme.secondaryTagText.opacity(0.3)
            : themeManager.effectiveTheme.primaryTagText.opacity(0.3)
        let textColor = isSecondary
            ? themeManager.effectiveTheme.secondaryTagText
            : themeManager.effectiveTheme.primaryTagText

        // Bold the matching portion
        if let range = suggestion.localizedStandardRange(of: trimmed) {
            let before = String(suggestion[suggestion.startIndex..<range.lowerBound])
            let match = String(suggestion[range])
            let after = String(suggestion[range.upperBound...])

            HStack(spacing: 0) {
                if !before.isEmpty {
                    Text(before)
                        .font(themeManager.effectiveTheme.interFont(size: 13))
                }
                Text(match)
                    .font(themeManager.effectiveTheme.interFont(size: 13, weight: .semibold))
                if !after.isEmpty {
                    Text(after)
                        .font(themeManager.effectiveTheme.interFont(size: 13))
                }
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(borderColor, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        } else {
            Text(suggestion)
                .font(themeManager.effectiveTheme.interFont(size: 13))
                .foregroundStyle(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(borderColor, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
        }
    }

    private func updateFilteredSuggestions() {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            cachedFilteredSuggestions = []
            return
        }
        cachedFilteredSuggestions = suggestions
            .filter { $0.localizedStandardContains(trimmed) && !tags.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    private func addTag() {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) && tags.count < 10 && trimmed.count <= 20 {
            withAnimation {
                tags.append(trimmed)
            }
        }
        input = ""
    }

    private func selectSuggestion(_ suggestion: String) {
        guard !tags.contains(suggestion) && tags.count < 10 else { return }
        withAnimation {
            tags.append(suggestion)
        }
        input = ""
    }
}

// Default accessory to EmptyView
extension InlineTagSection where Accessory == EmptyView {
    init(title: String, emptyHint: String, tags: Binding<[String]>, input: Binding<String>,
         isFocused: FocusState<Bool>.Binding, isSecondary: Bool,
         suggestions: [String] = [], onSubmit: @escaping () -> Void = {}) {
        self.title = title
        self.emptyHint = emptyHint
        self._tags = tags
        self._input = input
        self.isFocused = isFocused
        self.isSecondary = isSecondary
        self.suggestions = suggestions
        self.onSubmit = onSubmit
        self.titleAccessory = EmptyView()
    }
}

// Custom accessory
extension InlineTagSection {
    init(title: String, emptyHint: String, tags: Binding<[String]>, input: Binding<String>,
         isFocused: FocusState<Bool>.Binding, isSecondary: Bool,
         suggestions: [String] = [], onSubmit: @escaping () -> Void = {},
         @ViewBuilder titleAccessory: () -> Accessory) {
        self.title = title
        self.emptyHint = emptyHint
        self._tags = tags
        self._input = input
        self.isFocused = isFocused
        self.isSecondary = isSecondary
        self.suggestions = suggestions
        self.onSubmit = onSubmit
        self.titleAccessory = titleAccessory()
    }
}
