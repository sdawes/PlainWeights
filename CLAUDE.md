# CLAUDE.md

<!--
Project-specific guidance for Claude Code (claude.ai/code)
-->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

### `acp` - Add, Commit, and Push
When the user says **"acp"**, immediately run `git add .`, commit with an appropriate message, and push to remote. No permission needed - just do it.

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
