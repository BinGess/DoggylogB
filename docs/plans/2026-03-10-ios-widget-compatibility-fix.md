# iOS Widget Compatibility Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restore iOS widget registration by making the `DoggyLogWidgets` extension compile for its configured deployment target and ship inside the app bundle.

**Architecture:** Keep the existing `DoggyLogWidgets` target, bundle, and embedding flow intact. Fix the root cause in SwiftUI code by replacing APIs that require newer iOS versions than the extension target supports, then rebuild and confirm the `.appex` is embedded under the app's `PlugIns` directory.

**Tech Stack:** Flutter, Xcode project target configuration, SwiftUI, WidgetKit

---

### Task 1: Capture the failing compatibility signal

**Files:**
- Reference: `ios/Extensions/DoggyLogSummaryWidget.swift`

**Step 1: Run the failing build**

Run: `flutter build ios --simulator --debug --no-codesign`

Expected: FAIL with Swift availability errors in `ios/Extensions/DoggyLogSummaryWidget.swift`.

### Task 2: Apply the minimal SwiftUI compatibility fix

**Files:**
- Modify: `ios/Extensions/DoggyLogSummaryWidget.swift`

**Step 1: Replace the unavailable color constant**

Use an explicit RGB `Color(...)` value instead of `Color.cyan` so the widget compiles on the current deployment target.

**Step 2: Replace unavailable text styling calls**

Use `foregroundColor` where `foregroundStyle` is not valid for the current deployment target in this target.

### Task 3: Verify the extension is built and embedded

**Files:**
- Verify build product under: `build/ios/iphonesimulator/Runner.app/PlugIns/`

**Step 1: Re-run the same build**

Run: `flutter build ios --simulator --debug --no-codesign`

Expected: build succeeds.

**Step 2: Verify the widget extension product exists**

Run: `find build/ios/iphonesimulator/Runner.app -maxdepth 3 | rg 'DoggyLogWidgets\\.appex|PlugIns'`

Expected: `Runner.app/PlugIns/DoggyLogWidgets.appex` is present.
