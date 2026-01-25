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
