//
//  TagInputSection.swift
//  PlainWeights
//
//  Reusable tag input with text field, add button, autocomplete suggestions, and tag pills.
//

import SwiftUI

struct TagInputSection: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let placeholder: String
    @Binding var tags: [String]
    @Binding var input: String
    var isFocused: FocusState<Bool>.Binding
    let isSecondary: Bool
    var suggestions: [String] = []
    var onSubmit: () -> Void = {}

    /// Filtered suggestions: match input, exclude already-added tags, max 5
    private var filteredSuggestions: [String] {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return suggestions
            .filter { $0.localizedStandardContains(trimmed) && !tags.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)

            HStack(spacing: 8) {
                TextField(placeholder, text: $input)
                    .focused(isFocused)
                    .font(themeManager.effectiveTheme.dataFont(size: 20))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .padding(16)
                    .frame(height: 56)
                    .background(themeManager.effectiveTheme.cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isFocused.wrappedValue ? themeManager.effectiveTheme.primaryText : themeManager.effectiveTheme.borderColor,
                                lineWidth: isFocused.wrappedValue ? 2 : 1
                            )
                    )
                    .onSubmit {
                        addTag()
                        onSubmit()
                    }

                Button(action: addTag) {
                    let isDisabled = input.trimmingCharacters(in: .whitespaces).isEmpty
                    Text("Add")
                        .font(themeManager.effectiveTheme.headlineFont)
                        .foregroundStyle(themeManager.effectiveTheme.background)
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(isDisabled ? themeManager.effectiveTheme.primary.opacity(0.4) : themeManager.effectiveTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Autocomplete suggestions
            if !filteredSuggestions.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Button {
                            selectSuggestion(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(themeManager.effectiveTheme.interFont(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(themeManager.effectiveTheme.muted.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(themeManager.effectiveTheme.borderColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagPillView(tag: tag, isSecondary: isSecondary) {
                            withAnimation { tags.removeAll { $0 == tag } }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private func addTag() {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) && tags.count < 10 {
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
