# CLAUDE.md

<!--
Project-specific guidance for Claude Code (claude.ai/code)
-->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

### `acp` - Add, Commit, and Push
When the user says **"acp"**, immediately run `git add .`, commit with an appropriate message, and push to remote. No permission needed - just do it.

**After pushing, show only the commit(s) just made** in a table:
```
| Hash | Message |
|------|---------|
| abc1234 | Commit message here |
```

## Agent Role

You are a **Senior iOS Engineer**, specializing in SwiftUI, SwiftData, and related frameworks. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.

## Core Instructions

- Target iOS 26.0 or later
- Swift 6.2 or later, using modern Swift concurrency
- SwiftUI backed by `@Observable` classes for shared data
- Do not introduce third-party frameworks without asking first
- Avoid UIKit unless requested

## Swift Instructions

- Always mark `@Observable` classes with `@MainActor`
- Assume strict Swift concurrency rules are being applied
- Prefer Swift-native alternatives to Foundation methods where they exist, such as using `replacing("hello", with: "world")` with strings rather than `replacingOccurrences(of: "hello", with: "world")`
- Prefer modern Foundation API, for example `URL.documentsDirectory` to find the app's documents directory, and `appending(path:)` to append strings to a URL
- Never use C-style number formatting such as `Text(String(format: "%.2f", abs(myNumber)))`; always use `Text(abs(change), format: .number.precision(.fractionLength(2)))` instead
- Prefer static member lookup to struct instances where possible, such as `.circle` rather than `Circle()`, and `.borderedProminent` rather than `BorderedProminentButtonStyle()`
- Never use old-style Grand Central Dispatch concurrency such as `DispatchQueue.main.async()`. If behavior like this is needed, always use modern Swift concurrency
- Filtering text based on user-input must be done using `localizedStandardContains()` as opposed to `contains()`
- Avoid force unwraps and force `try` unless it is unrecoverable

## SwiftUI Instructions

- Always use `foregroundStyle()` instead of `foregroundColor()`
- Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`
- Always use the `Tab` API instead of `tabItem()`
- Never use `ObservableObject`; always prefer `@Observable` classes instead
- Never use the `onChange()` modifier in its 1-parameter variant; either use the variant that accepts two parameters or accepts none
- Never use `onTapGesture()` unless you specifically need to know a tap's location or the number of taps. All other usages should use `Button`. **Exception:** `onTapGesture` is acceptable on List rows with `.swipeActions` since `Button` can interfere with swipe gestures
- Never use `Task.sleep(nanoseconds:)`; always use `Task.sleep(for:)` instead
- Never use `UIScreen.main.bounds` to read the size of the available space
- Do not break views up using computed properties; place them into new `View` structs instead
- Do not force specific font sizes; prefer using Dynamic Type instead
- Use the `navigationDestination(for:)` modifier to specify navigation, and always use `NavigationStack` instead of the old `NavigationView`
- If using an image for a button label, always specify text alongside like this: `Button("Tap me", systemImage: "plus", action: myButtonAction)`
- When rendering SwiftUI views, always prefer using `ImageRenderer` to `UIGraphicsImageRenderer`
- Don't apply the `fontWeight()` modifier unless there is good reason. If you want to make some text bold, always use `bold()` instead of `fontWeight(.bold)`
- Do not use `GeometryReader` if a newer alternative would work as well, such as `containerRelativeFrame()` or `visualEffect()`. **Exception:** `GeometryReader` is acceptable when you need actual pixel dimensions for calculations (e.g., proportional bar widths, particle positioning)
- When making a `ForEach` out of an `enumerated` sequence, do not convert it to an array first. So, prefer `ForEach(x.enumerated(), id: \.element.id)` instead of `ForEach(Array(x.enumerated()), id: \.element.id)`
- When hiding scroll view indicators, use the `.scrollIndicators(.hidden)` modifier rather than using `showsIndicators: false` in the scroll view initializer
- Place view logic into view models or similar, so it can be tested
- Avoid `AnyView` unless it is absolutely required
- Avoid specifying hard-coded values for padding and stack spacing unless requested
- Avoid using UIKit colors in SwiftUI code

## SwiftData Instructions (CloudKit)

- Never use `@Attribute(.unique)`
- Model properties must always either have default values or be marked as optional
- All relationships must be marked optional

## Project Structure

- Use a consistent project structure, with folder layout determined by app features
- Follow strict naming conventions for types, properties, methods, and SwiftData models
- Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file
- Write unit tests for core application logic
- Only write UI tests if unit tests are not possible
- Add code comments and documentation comments as needed
- If the project requires secrets such as API keys, never include them in the repository

## PR Instructions

- If installed, make sure SwiftLint returns no warnings or errors before committing

## Troubleshooting

### Device Debugging Issues (White Screen / LLDB Hang)

**Symptoms:**
- App shows white screen on physical device but works on Simulator
- Xcode shows "Launching is taking longer than expected"
- "LLDB is likely reading from device memory to resolve symbols"
- App is unresponsive to taps

**Cause:** Corrupted or mismatched debug symbols on the device.

**Fix:**
1. Try **Release mode** first (Edit Scheme → Run → Build Configuration: Release) - if it works, the issue is LLDB/symbols
2. **Reconnect device:** Disconnect iPhone, restart it, reconnect to Mac
3. **Delete iOS DeviceSupport:** In Finder `Cmd+Shift+G` → `~/Library/Developer/Xcode/iOS DeviceSupport` → delete folder for your iOS version
4. **Clean build:** `Cmd+Shift+K` in Xcode
5. Rebuild and run

**Note:** This can happen after branch switches or Xcode updates. The Simulator uses different symbol caches than physical devices.

## Project Overview

PlainWeights is a high-performance gym workout tracking app built with SwiftUI and SwiftData. The app focuses on recording exercises, sets, and reps with optimized data aggregation for real-time charts and statistics using Swift Charts.

## Design Philosophy

**Plain. Simple. Text-based.**

The whole point of PlainWeights is to strip away all unnecessary complexity and design flourishes. The app provides users with only the minimum they need to:
1. Record weights in the gym
2. Measure progress over time

### Design Principles
- **Text-first**: Plain, simple text is the primary UI element
- **Lines as dividers**: Use simple lines (horizontal `────` or vertical `│`) for structure
- **Minimal color**: Hints of color only - never decorative, always functional
- **No unnecessary UI**: Strip out all extra complexities and visual noise
- **Clean and elegant**: Every element must earn its place
- **Functional simplicity**: If it doesn't help the user record or track, remove it

### Typography - System Font (SF Pro)
**The app uses the default iOS system font (SF Pro) for clean, native appearance.**

```swift
// Standard text patterns - use default system font
.font(.body)                    // Body text
.font(.headline)                // Headlines
.font(.subheadline)             // Subheadlines
.font(.caption)                 // Captions
.font(.title2)                  // Titles
.font(.system(size: 24))        // Custom sizes
```

**Why SF Pro (System Default):**
- Native iOS appearance
- Optimized for readability on Apple devices
- Automatic support for Dynamic Type accessibility
- Clean, modern aesthetic

### What to Avoid
- Fancy gradients or decorative backgrounds
- Heavy use of SF Symbols when text suffices
- Excessive padding or whitespace
- Complex nested cards or containers
- Color for color's sake

### What to Embrace
- Clear typography hierarchy using system fonts
- Simple divider lines
- Subtle color hints for meaning (green = up, red = down)
- White space that serves readability
- Clean, minimal backgrounds

## UI Structure & Patterns

This section documents the reusable UI patterns, spacing conventions, and component structures used throughout the app.

### Navigation Structure

**NavigationStack Pattern:**
```swift
@State private var navigationPath = NavigationPath()

NavigationStack(path: $navigationPath) {
    listView
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
}

// Push navigation by appending to path:
navigationPath.append(exercise)
```

**Toolbar Items:**
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button { showingSheet = true } label: {
            Image(systemName: "plus")
                .font(.body)
                .fontWeight(.medium)
        }
    }
}
.navigationBarTitleDisplayMode(.inline)
```
- Icons use `.body` font with `.medium` weight
- No text labels on toolbar buttons

### Standard Spacing Values

| Purpose | Value | Usage |
|---------|-------|-------|
| Tight spacing | 4pt | Button groups, pill buttons |
| Small spacing | 6pt | Section separators |
| Default gap | 8pt | Between elements |
| Label to input | 12pt | Form field labels |
| Content padding | 16pt | Card content, list rows |
| Sheet padding | 24pt | Outer padding for sheets |
| Section spacing | 24pt | Between major sections |

**Common Padding Patterns:**
```swift
.padding(24)                    // Sheet outer padding
.padding(.horizontal, 16)       // List row content
.padding(.vertical, 12)         // Metric cell padding
.listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
```

### List Styling

**Standard List Configuration:**
```swift
List {
    // Content
}
.listStyle(.plain)
.scrollIndicators(.hidden)
.listSectionSpacing(6)
.scrollContentBackground(.hidden)
.background(AnimatedGradientBackground())
.scrollDismissesKeyboard(.immediately)
```

**Row Configuration:**
```swift
.listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
.listRowSeparator(.hidden)
.listRowBackground(Color.clear)
```

**Separator Styling:**
```swift
.listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
.listRowSeparatorTint(themeManager.currentTheme.borderColor)
.alignmentGuide(.listRowSeparatorLeading) { _ in 0 }  // Full-width separators
```

### Sheet/Modal Pattern

All sheets follow this consistent structure:

```swift
VStack(alignment: .leading, spacing: 24) {
    // Header with dismiss button
    HStack {
        Text("Sheet Title")
            .font(themeManager.currentTheme.title3Font)
            .lineLimit(1)
        Spacer()
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
        }
        .buttonStyle(.plain)
    }
    .padding(.bottom, 8)

    // Scrollable content
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            // Form fields / content
        }
    }

    Spacer()

    // Bottom CTA button
    Button(action: saveAction) {
        Text("Save")
            .font(themeManager.currentTheme.headlineFont)
            .foregroundStyle(themeManager.currentTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(themeManager.currentTheme.primary.opacity(canSave ? 1 : 0.4))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
    .disabled(!canSave)
}
.padding(24)
.background(themeManager.currentTheme.background)
```

**Key files:** `AddSetView.swift`, `AddExerciseView.swift`, `SettingsView.swift`

### Button Styles

**Primary Button (Full-width CTA):**
```swift
Button(action: action) {
    Text("Save")
        .font(themeManager.currentTheme.headlineFont)
        .foregroundStyle(themeManager.currentTheme.background)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(themeManager.currentTheme.primary.opacity(isEnabled ? 1 : 0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
.buttonStyle(.plain)
.disabled(!isEnabled)
```

**Pill Toggle Button:**
```swift
Button { selectedType = type } label: {
    Text(type.rawValue)
        .font(themeManager.currentTheme.subheadlineFont)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? themeManager.currentTheme.primary : themeManager.currentTheme.muted)
        .foregroundStyle(isSelected ? themeManager.currentTheme.background : themeManager.currentTheme.primaryText)
        .clipShape(RoundedRectangle(cornerRadius: 8))
}
.buttonStyle(.plain)
```

**Icon Button (Toolbar):**
```swift
Button { action() } label: {
    Image(systemName: "plus")
        .font(.body)
        .fontWeight(.medium)
        .foregroundStyle(themeManager.currentTheme.textColor)
}
.buttonStyle(.plain)
.contentShape(Rectangle())  // Increases tap target
```

### Form Input Fields

**Text Input Field:**
```swift
TextField("0", text: $text)
    .font(themeManager.currentTheme.dataFont(size: 20))
    .keyboardType(.decimalPad)
    .focused($focusedField, equals: .weight)
    .multilineTextAlignment(.center)
    .padding(16)
    .frame(height: 56)
    .background(themeManager.currentTheme.muted)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(themeManager.currentTheme.borderColor, lineWidth: 1))
    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(focusedField == .weight ? themeManager.currentTheme.mutedForeground : Color.clear, lineWidth: 2))
```

**Input Field Specs:**
- Height: 56pt
- Padding: 16pt
- Border radius: 12pt
- Focus indicator: 2pt border

### Search Bar

```swift
// Only show when data exists
if !items.isEmpty {
    listView
        .searchable(text: $searchText, prompt: "Search by name or tags")
}
```

### SF Symbols Usage

**Icon Sizes:**
| Context | Size |
|---------|------|
| Toolbar buttons | `.body` + `.medium` weight |
| Sheet close button | `.title3` |
| Floating action button | `.title2` |
| Status indicators | `.system(size: 14)` |
| Small badges | `.system(size: 10-13)` |

**Common Icons:**
```swift
Image(systemName: "plus")           // Add
Image(systemName: "xmark")          // Close/dismiss
Image(systemName: "gearshape")      // Settings
Image(systemName: "star.fill")      // PB indicator (gold)
Image(systemName: "pencil")         // Edit
Image(systemName: "trash")          // Delete
Image(systemName: "exclamationmark.circle")  // Warning
```

### Segmented Picker

```swift
Picker("Time Range", selection: $selectedRange) {
    ForEach(Range.allCases) { range in
        Text(range.rawValue).tag(range)
    }
}
.pickerStyle(.segmented)
.frame(width: 180)  // Fixed width for consistency
```

### Empty States

```swift
VStack(spacing: 12) {
    // Optional illustration
    Image(systemName: "tray")
        .font(.largeTitle)
        .foregroundStyle(themeManager.currentTheme.mutedForeground)

    Text("No Items Yet")
        .font(themeManager.currentTheme.title2Font)

    Text("Add your first item to get started.")
        .font(themeManager.currentTheme.subheadlineFont)
        .foregroundStyle(themeManager.currentTheme.mutedForeground)
}
```

### Dimensions Reference

| Element | Value |
|---------|-------|
| Card border radius | 12pt |
| Button border radius | 8-12pt |
| Card border width | 1pt |
| Input field height | 56pt |
| Progress bar height | 8pt |
| Accent strip width | 2pt |
| Chart height | 150pt |
| Divider height | 1pt |

## Core Requirements

### Technology Stack
- **SwiftUI**: Latest features and best practices only
- **SwiftData**: For persistent storage with performance-optimized queries
- **Swift Testing**: New testing framework with `@Test` attributes (NOT XCTest for unit tests)
- **Swift Charts**: For data visualization
- **Minimum iOS Target**: iOS 17+ (to use latest SwiftData and SwiftUI features)

### SwiftUI List Unified Card Pattern - CRITICAL

When creating a unified card appearance across multiple List rows (e.g., header + set rows that look like one card), follow these rules:

#### The Problem
SwiftUI List enforces a **default minimum row height (~44pt)**. When content is shorter, the List **centers** it vertically, creating gaps between rows.

#### The Solution

1. **Use structs, NOT functions** for custom row views:
   ```swift
   // ✅ CORRECT - List recognizes this as a stable row component
   struct HistoricDayHeader: View { ... }

   // ❌ WRONG - List may add extra spacing/padding
   private func historicDayHeader() -> some View { ... }
   ```

2. **Override the default minimum row height** on the List:
   ```swift
   List {
       // rows...
   }
   .environment(\.defaultMinListRowHeight, 1)  // Allow rows to size naturally
   ```

3. **Use partial border shapes** to connect rows visually:
   - `TopOpenBorder` - draws top + left + right edges (no bottom)
   - `SidesOnlyBorder` - draws left + right edges only
   - `BottomOpenBorder` - draws bottom + left + right edges (no top)

4. **Standard row modifiers for card appearance**:
   ```swift
   MyCardRow()
       .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
       .listRowSeparator(.hidden)
       .listRowBackground(Color.clear)
   ```

#### Example: Unified Card Structure
```
┌─ Header (TopOpenBorder) ─────────┐
│ Tuesday 27 Jan         164 kg    │
├──────────────────────────────────┤  ← Internal divider
│ Set 2: 12 kg × 7 (SidesOnlyBorder)│
├──────────────────────────────────┤  ← Internal divider
│ Set 1: 10 kg × 8 (BottomOpenBorder)│
└──────────────────────────────────┘
```

#### Key Files
- `ListRowCard.swift` - Border shapes (TopOpenBorder, SidesOnlyBorder, BottomOpenBorder)
- `TodaySessionCard.swift` - Example of working unified card header
- `HistoricDayHeader.swift` - Historic day header using same pattern
- `SetRowView.swift` - Set rows with `cardPosition` parameter for border selection

### Accent Strip Pattern

A 2px colored left border with light tinted background, used to visually highlight rows or sections with a specific status.

#### Use Cases
- **PBs (red)**: Exercise cards/rows containing personal bests
- **Staleness indicators**: Exercise list items (orange = 14+ days, red = 30+ days, green = today)
- **Set type badges**: Warm-up (orange), Bonus (green), Drop set (blue), Assisted (pink), Timed (gray), Pause (indigo)

#### Visual Specification
```
┌──┬────────────────────────────────┐
│▌▌│ Content with tinted background │  ← 2px solid color + 10% opacity fill
└──┴────────────────────────────────┘
```

#### Code Template
```swift
@ViewBuilder
private func accentStrip(color: Color) -> some View {
    HStack(spacing: 0) {
        Rectangle()
            .fill(color)
            .frame(width: 2)
        Rectangle()
            .fill(color.opacity(0.1))
    }
}

// Usage as background:
.background {
    if shouldHighlight {
        accentStrip(color: .red)
    } else {
        defaultBackground
    }
}
```

#### Key Files
- `SessionSummaryView.swift` - PB accent strip on exercise card headers
- `ExerciseListView.swift` - Staleness indicator on exercise rows
- `SetRowView.swift` - Set type indicators (warm-up, bonus, etc.)

### Standalone Card Component Pattern

When creating info cards with headers and metric cells (like session summary cards), follow this pattern:

#### Card Structure
```
┌─────────────────────────────────────────────┐
│ Header Text                        PB (opt) │  ← Header row (muted background)
├─────────────────────────────────────────────┤  ← 1px divider
│ Label 1    │ Label 2    │ Label 3          │  ← Metric cells row
│ Value 1    │ Value 2    │ Value 3          │
└─────────────────────────────────────────────┘
```

#### Visual Specifications

**Card Container:**
- Background: `themeManager.currentTheme.cardBackgroundColor`
- Corner radius: `12`
- Border: `1px` stroke using `themeManager.currentTheme.borderColor`

**Header Row:**
- Background: `themeManager.currentTheme.muted.opacity(0.3)`
- Font: `themeManager.currentTheme.interFont(size: 14, weight: .medium)`
- Text color: `themeManager.currentTheme.secondaryText`
- Padding: `.horizontal(16)` `.vertical(10)`
- Optional right-aligned indicator (e.g., "PB" in bold red)

**Dividers:**
- Between header and content: `Rectangle().fill(themeManager.currentTheme.borderColor).frame(height: 1)`
- Between metric rows: Same 1px divider

**Metric Cells:**
- Container: `HStack(spacing: 1)` with `.background(themeManager.currentTheme.borderColor)` for 1px gaps
- Each cell background: `themeManager.currentTheme.cardBackgroundColor`
- Label font: `themeManager.currentTheme.captionFont`
- Label color: `themeManager.currentTheme.mutedForeground`
- Value font: `themeManager.currentTheme.dataFont(size: 20, weight: .semibold)`
- Value color: `themeManager.currentTheme.primaryText`
- Cell padding: `.horizontal(16)` `.vertical(12)`
- Cell alignment: `.frame(maxWidth: .infinity, alignment: .leading)`

#### Code Template
```swift
@ViewBuilder
private func infoCard(title: String, hasPB: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack {
            Text(title)
                .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.secondaryText)
            Spacer()
            if hasPB {
                Text("PB")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(themeManager.currentTheme.muted.opacity(0.3))

        // Divider
        Rectangle()
            .fill(themeManager.currentTheme.borderColor)
            .frame(height: 1)

        // Metric cells row
        HStack(spacing: 1) {
            metricCell(label: "Label", value: "Value")
            metricCell(label: "Label", value: "Value")
            metricCell(label: "Label", value: "Value")
        }
        .background(themeManager.currentTheme.borderColor)
    }
    .background(themeManager.currentTheme.cardBackgroundColor)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
    )
}

@ViewBuilder
private func metricCell(label: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(label)
            .font(themeManager.currentTheme.captionFont)
            .foregroundStyle(themeManager.currentTheme.mutedForeground)
        Text(value)
            .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
            .foregroundStyle(themeManager.currentTheme.primaryText)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(themeManager.currentTheme.cardBackgroundColor)
}
```

#### Key Files
- `SessionSummaryView.swift` - Reference implementation with session info card and exercise cards

### Progress Chart Component

The `InlineProgressChart` displays exercise progress over time using Swift Charts with dual Y-axes for weight and reps.

**Location:** `PlainWeights/Views/Components/InlineProgressChart.swift`

#### Structure
```
┌─────────────────────────────────────────────────────────────┐
│ Progress                              [1Y] [3Y] [Max]       │  ← Header + time range picker
├─────────────────────────────────────────────────────────────┤
│ 12 ┤                                                    │ 80│  ← Dual Y-axes (reps left, weight right)
│ 10 ┤      ╭──────╮    🏆                               │ 70│
│  8 ┤  ╭───╯      ╰────────╮                            │ 60│  ← Weight line (solid) + area gradient
│  6 ┤──╯                    ╰─ ─ ─ ─                    │ 50│  ← Reps line (dashed)
│    └────┬────┬────┬────┬────┬────┬────┬────┬────┬─────┘    │
│       27/1  3/2  10/2 17/2 24/2  3/3  10/3 17/3 24/3       │  ← X-axis dates
├─────────────────────────────────────────────────────────────┤
│ ── Weight (kg)    - - Reps                                  │  ← Legend
└─────────────────────────────────────────────────────────────┘
```

#### Time Range Options
| Range | Data Filter | Granularity |
|-------|-------------|-------------|
| **6M** (default) | Past 6 months | Always daily - shows each session |
| **1Y** | Past 1 year | Weekly grouping |
| **3Y** | Past 3 years | Monthly grouping |
| **Max** | All data | Monthly grouping |

#### Granularity Rules (Performance Optimized)
```swift
// Under 6 months of data - always daily for all views
if dataSpanDays < 180 {
    granularity = .daily
} else {
    // Larger datasets - granularity depends on selected time range
    switch timeRange {
    case .sixMonths: granularity = .daily   // 6M always shows daily
    case .oneYear: granularity = .weekly    // 1Y groups by week
    case .threeYears, .max: granularity = .monthly  // 3Y/Max groups by month
    }
}
```

#### Visual Styling
- **Weight line**: Solid, 2px, `chartColor1` (orange in light, blue in dark) + gradient fill
- **Reps line**: Dashed (5,3), 1.5px, `chartColor2` (teal in light, green in dark), no fill
- **PB markers**: Vertical rule line + star icon at top, using `pbColor` (#faac05 gold)
- **Grid lines**: Dashed (3,3), 0.5px, `borderColor`
- **Chart height**: 170pt, Y-axis height: 150pt

#### Reps-Only Exercises
For bodyweight exercises (weight = 0), the chart adapts:
- Single Y-axis on left (reps only)
- Solid line with gradient fill (like weight line styling)
- Uses `chartColor2` (green/teal)

#### Performance Considerations
1. **Cached chart data**: Computed in `init` and stored in `@State` to prevent recalculation on every render
2. **Time filtering**: Cutoff dates limit data loaded (1Y default reduces initial load)
3. **Adaptive granularity**: Larger datasets auto-aggregate to reduce chart points
4. **Static computation**: Uses `static func` for data transformation (required for init)

#### Key Code Patterns
```swift
// Cache expensive transformations
@State private var cachedChartData: [ChartDataPoint]

init(sets: [ExerciseSet]) {
    self.sets = sets
    _cachedChartData = State(initialValue: Self.computeChartData(from: sets, timeRange: .sixMonths))
}

// Update cache when data or time range changes
.onChange(of: sets) { _, _ in
    cachedChartData = Self.computeChartData(from: sets, timeRange: selectedTimeRange)
}
.onChange(of: selectedTimeRange) { _, newRange in
    withAnimation(.easeInOut(duration: 0.2)) {
        cachedChartData = Self.computeChartData(from: sets, timeRange: newRange)
    }
}
```

#### Chart Colors (from AppTheme)
```swift
// Light theme
chartColor1: Color(red: 0.92, green: 0.45, blue: 0.18)  // Vibrant orange (weight)
chartColor2: Color(red: 0.18, green: 0.70, blue: 0.65)  // Vibrant teal (reps)

// Dark theme
chartColor1: Color(red: 0.45, green: 0.50, blue: 0.95)  // Bright blue/purple (weight)
chartColor2: Color(red: 0.45, green: 0.82, blue: 0.58)  // Bright green (reps)

// PB indicator (both themes)
pbColor: Color(red: 0.980, green: 0.675, blue: 0.020)   // Gold #faac05
```

### SwiftUI API Preferences
**Always use `foregroundStyle()` instead of `foregroundColor()`** - the latter is deprecated.

```swift
// ✅ CORRECT
.foregroundStyle(.red)
.foregroundStyle(themeManager.effectiveTheme.primaryText)

// ❌ WRONG (deprecated)
.foregroundColor(.red)
.foregroundColor(themeManager.effectiveTheme.primaryText)
```

### UIKit Policy - CRITICAL
**NEVER use UIKit unless there is absolutely no SwiftUI alternative to achieve the desired result.**

- Always prefer SwiftUI modifiers and APIs over UIKit appearance customization
- If tempted to use `UINavigationBarAppearance`, `UITableView.appearance()`, or similar UIKit APIs, first research SwiftUI alternatives
- Examples of SwiftUI alternatives:
  - Navigation bar background: `.toolbarBackground(_:for:)` instead of `UINavigationBarAppearance`
  - Custom title styling: `ToolbarItem(placement: .principal)` with custom `Text` view
  - List styling: `.listStyle()`, `.listRowBackground()` instead of `UITableView.appearance()`
- Only use UIKit as a last resort when SwiftUI genuinely cannot achieve the requirement

### PlainWeights Color Theme

The app uses a consistent iPhone 17-inspired color palette with `pw_` prefix:

#### Color Palette
```swift
// Orange family (inspired by iPhone 17 Pro Cosmic Orange)
static let pw_orangeLight = Color(red: 0.98, green: 0.65, blue: 0.35)
static let pw_orange = Color(red: 0.93, green: 0.47, blue: 0.20)
static let pw_orangeDark = Color(red: 0.75, green: 0.35, blue: 0.10)

// Blue family (inspired by iPhone 17 Pro Deep Blue)
static let pw_blueLight = Color(red: 0.35, green: 0.55, blue: 0.75)
static let pw_blue = Color(red: 0.0, green: 0.48, blue: 1.0)  // Bright iOS blue
static let pw_blueDark = Color(red: 0.11, green: 0.28, blue: 0.45)

// Grey family (inspired by iPhone 17 Silver/neutral tones)
static let pw_greyLight = Color(red: 0.95, green: 0.95, blue: 0.96)
static let pw_grey = Color(red: 0.75, green: 0.75, blue: 0.77)
static let pw_greyDark = Color(red: 0.35, green: 0.35, blue: 0.37)
```

**Location:** `PlainWeights/Utilities/AppColors.swift`

### Theme System

The app has its own theme system with Light and Dark themes, managed by `ThemeManager`. This overrides iOS system dark mode.

**Key Files:**
- `PlainWeights/Models/AppTheme.swift` - Theme definitions (Light/Dark with explicit colors)
- `PlainWeights/Utilities/ThemeManager.swift` - Observable theme manager with UserDefaults persistence

#### Sheets and Color Scheme - CRITICAL

**Sheets/modals may not inherit `.preferredColorScheme()` from the root view.** To prevent iOS device dark mode from affecting sheets, explicitly apply the color scheme:

```swift
// ✅ CORRECT - Sheet respects in-app theme, ignores device dark mode
.sheet(isPresented: $showingSheet) {
    MySheetView()
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
}

// ❌ WRONG - Sheet may use device dark mode instead of app theme
.sheet(isPresented: $showingSheet) {
    MySheetView()
}
```

**Apply to ALL sheet types:**
- `.sheet(isPresented:)`
- `.sheet(item:)`
- `.fullScreenCover(isPresented:)`

### Performance Priorities - CRITICAL
**PERFORMANCE IS THE #1 PRIORITY - Every millisecond matters**
- All data operations MUST be database-level (NEVER in-memory filtering)
- Implement aggressive caching with smart invalidation
- Use lazy loading and pagination for ALL datasets
- Minimize view re-renders using computed properties and `@Observable` macro
- Background processing mandatory for any operation > 16ms
- Batch operations required for all multi-item updates
- Profile with Instruments before and after EVERY feature

### SwiftData Best Practices - CRITICAL

**IMPORTANT: SwiftData is designed to be used directly in views. DO NOT overcomplicate with unnecessary abstraction layers.**

#### SwiftData Architecture Principles (MUST FOLLOW)
- **ALWAYS use SwiftData patterns directly** - `@Environment(\.modelContext)` and `@Query` in views
- **NEVER add unnecessary ViewModel layers** - SwiftData provides reactive updates automatically
- **NEVER try to "improve" SwiftData with MVVM** - It breaks the framework's elegant design
- **DO use Services for business logic** - But call them directly from views, not through ViewModels

#### Caching SwiftData Transformations - CRITICAL FOR PERFORMANCE

**Problem:** Computed properties that transform SwiftData (filtering, grouping, aggregating) run on EVERY view render - potentially 60+ times per second during scrolling, causing lag/jutter.

**Solution:** Cache expensive transformations with `@State`, update only when data changes.

```swift
// ✅ CORRECT - Cache with @State, update on data change
struct MyView: View {
    let sets: [ExerciseSet]
    @State private var cachedChartData: [ChartDataPoint]

    init(sets: [ExerciseSet]) {
        self.sets = sets
        // Compute in init to prevent layout shift on appear
        _cachedChartData = State(initialValue: Self.computeChartData(from: sets))
    }

    private static func computeChartData(from sets: [ExerciseSet]) -> [ChartDataPoint] {
        // Expensive transformation logic
    }

    var body: some View {
        Chart(cachedChartData) { ... }
            .onChange(of: sets) { _, _ in
                cachedChartData = Self.computeChartData(from: sets)
            }
    }
}

// ❌ WRONG - Computed property runs on every render
struct MyView: View {
    let sets: [ExerciseSet]

    private var chartData: [ChartDataPoint] {
        // This runs 60+ times/second during scroll!
        sets.filter { ... }.grouped { ... }.map { ... }
    }
}
```

**Key patterns:**
1. **Use static functions** for transformations called in `init` (can't access `self` yet)
2. **Compute in init** when data is passed as parameter - prevents layout shift
3. **Update in onChange(of:)** to react to data changes
4. **Don't animate initial load** if it causes visible delay - set animation state to `true` initially

### SwiftUI Animation Best Practices

#### Deletions - Always Use `withAnimation`
When deleting items from a List/ForEach, wrap the deletion in `withAnimation` to prevent glitchy animations where adjacent rows briefly disappear:

```swift
// ✅ CORRECT - Smooth deletion animation
private func deleteItem(_ item: Item) {
    withAnimation {
        context.delete(item)
        try? context.save()
    }
}

// ❌ WRONG - Adjacent rows may flicker/disappear
private func deleteItem(_ item: Item) {
    context.delete(item)
    try? context.save()
}
```

#### State Changes That Affect Layout
Any state change that adds/removes/reorders views should be wrapped in `withAnimation`:
- Adding/removing items from arrays
- Toggling visibility of sections
- Reordering list items

#### Input Field UX Patterns

**Select All on Focus** - For numeric input fields, select all text when field gains focus:
```swift
.onChange(of: focusedField) { _, newValue in
    if newValue != nil {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
        }
    }
}
```

**Border Clipping Fix** - Use `.strokeBorder()` instead of `.stroke()` for overlays to prevent border clipping:
```swift
// ✅ CORRECT - Border draws inside bounds
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .strokeBorder(borderColor, lineWidth: 1)
)

// ❌ WRONG - Border may be clipped on edges
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(borderColor, lineWidth: 1)
)
```

**Text Truncation Prevention** - For numeric labels that might overflow (e.g., chart axis labels), use:
```swift
Text("764.65")
    .lineLimit(1)
    .minimumScaleFactor(0.7)  // Shrinks text to fit rather than wrapping
```

#### Full Swipe-to-Delete with Confirmation Alert

When you need full swipe to trigger a **confirmation alert** (e.g., deleting an entire exercise), NavigationLink blocks the gesture. Use programmatic navigation instead:

```swift
// ✅ CORRECT - Full swipe triggers confirmation alert
@State private var navigationPath = NavigationPath()
@State private var exerciseToDelete: Exercise?

NavigationStack(path: $navigationPath) {
    List {
        ForEach(exercises) { exercise in
            ExerciseRow(exercise: exercise)
                .onTapGesture {
                    navigationPath.append(exercise)  // Programmatic navigation
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        exerciseToDelete = exercise  // Triggers alert
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
    .alert("Delete Exercise?", isPresented: .constant(exerciseToDelete != nil)) {
        // Confirmation buttons...
    }
}
```

**Note:** This pattern is for destructive actions needing confirmation (deleting exercises). For simple deletions without confirmation (like sets), standard swipe actions work fine without programmatic navigation.

#### Reusable Components

When creating UI elements that may be reused (buttons, inputs, etc.), create them as separate component files in `Views/Components/` rather than private functions within views. Examples:
- `StepperButton.swift` - +/- buttons for numeric inputs
- `TagPillView.swift` - Tag display pills
- `FlowLayout.swift` - Wrapping horizontal layout

### iCloud Sync (CloudKit)

The app uses SwiftData with automatic CloudKit sync. User data is backed up to their iCloud account and restored automatically on reinstall or new device.

**Configuration:**
- ModelContainer uses `cloudKitDatabase: .automatic`
- iCloud capability with CloudKit enabled
- Background Modes with Remote Notifications enabled
- CloudKit container: `iCloud.com.stevolution.PlainWeights`

**Model Requirements for CloudKit:**
- All properties must have default values OR be optional
- All relationships must be optional
- Cannot use `@Attribute(.unique)`
- Delete rules cannot be `.deny`

**Key Files:**
- `PlainWeightsApp.swift` - ModelContainer with CloudKit config
- `Exercise.swift` - Model with CloudKit-compatible defaults
- `ExerciseSet.swift` - Model with CloudKit-compatible defaults

**Testing CloudKit:**
1. Must test on real device (Simulator is unreliable)
2. Check CloudKit Dashboard: https://icloud.developer.apple.com/dashboard
3. Look in `com.apple.coredata.cloudkit.zone` for records
4. Sync can take 30 seconds to several minutes

**Schema Changes After Release:**
Once deployed to Production, follow "Add-Only, No-Delete, No-Change" principle:
- Can add new properties/entities
- Cannot delete or rename existing properties
- Cannot change property types

---

## Pre-Release Checklist

**Before submitting to App Store, complete these steps:**

### CloudKit Schema Deployment
1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Select container `iCloud.com.stevolution.PlainWeights`
3. Click **Deploy Schema Changes** to push Development schema to Production
4. Verify schema deployed successfully

### App Store Connect
- [ ] App screenshots for all device sizes
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] App category set correctly
- [ ] Version number and build number updated

### Testing
- [ ] Test on multiple real devices
- [ ] Test CloudKit sync (delete app, reinstall, verify data restores)
- [ ] Test both light and dark themes
- [ ] Test with large datasets (performance)

---

### Git Workflow
**CRITICAL: DO NOT commit or push changes unless explicitly requested by the user.**
- Only make commits when the user specifically asks you to commit
- Never auto-commit after completing features or fixes
- Always ask for permission before running git commit or git push commands

## Build and Development Commands

### Building the Project
```bash
# Build for Debug configuration (iOS Simulator - RECOMMENDED FOR TESTING)
xcodebuild -scheme PlainWeights -configuration Debug build -destination "platform=iOS Simulator,name=iPhone 16"

# Clean build folder
xcodebuild -scheme PlainWeights clean
```

**IMPORTANT**: Always use the iOS Simulator destination when testing builds, as this is an iOS app and building without a destination may default to macOS and fail.

## Development Approach
- **INCREMENTAL DELIVERY**: Break down implementation into small, testable chunks
- Provide one feature or component at a time
- Allow testing and verification between each step
- Show progress gradually rather than delivering complete solutions
- Each code change should be functional and runnable
- Wait for feedback before proceeding to next step

## Figma MCP Integration

### Figma Make File Access
The design source of truth is in Figma Make. To access Make files via MCP:

**File Key:** `SIRV3FHiHxGFMgg6jnp1aO`
**URL:** https://www.figma.com/make/SIRV3FHiHxGFMgg6jnp1aO/Gym-Workout-Tracker

### How to Access Make Files

1. **Get file listing** - Use `mcp__figma__get_design_context` with `nodeId: "0:1"`:
   ```
   mcp__figma__get_design_context(fileKey: "SIRV3FHiHxGFMgg6jnp1aO", nodeId: "0:1")
   ```
   This returns a list of all source files with their resource URIs.

2. **Read individual files** - Use `ReadMcpResourceTool` with the resource URI:
   ```
   ReadMcpResourceTool(server: "figma", uri: "file://figma/make/source/SIRV3FHiHxGFMgg6jnp1aO/src/app/components/ExerciseList.tsx")
   ```

### Key Design Files
- `src/app/components/ExerciseList.tsx` - Exercise list item styling
- `src/app/screens/ExerciseDetailScreen.tsx` - Exercise detail view
- `src/styles/theme.css` - Typography and color variables

### Typography Specs (from theme.css)
| Element | Size | Weight |
|---------|------|--------|
| h1 | 1.5rem (24px) | 500 (medium) |
| h2 | 1.25rem (20px) | 500 (medium) |
| h3 | 1.125rem (18px) | 500 (medium) |
| h4 | 1rem (16px) | 500 (medium) |
| body | 1rem (16px) | 400 (normal) |

### SwiftUI Equivalents
```swift
// h3 equivalent (18px, medium) - for exercise titles
.font(.system(size: 18, weight: .medium))

// h4 equivalent (16px, medium)
.font(.system(size: 16, weight: .medium))

// body equivalent (16px, normal)
.font(.system(size: 16, weight: .regular))
```
