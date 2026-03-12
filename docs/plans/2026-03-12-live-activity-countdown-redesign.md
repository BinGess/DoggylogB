# Live Activity Countdown Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refresh the DoggyLog lock-screen live activity so it shows a single countdown-focused card, removes the low-mood scene text, and prevents duplicate activity cards from stacking.

**Architecture:** Keep the Flutter snapshot payload intact, but tighten iOS live-activity presentation rules so an activity only exists when a countdown exists. Add a small testable selection helper in the iOS app target to collapse duplicate ActivityKit instances down to one primary activity, then redesign the SwiftUI live-activity view around a single countdown hero card with secondary task/count metadata.

**Tech Stack:** Flutter, Swift, SwiftUI, ActivityKit, XCTest

---

### Task 1: Add failing iOS regression tests

**Files:**
- Modify: `ios/RunnerTests/RunnerTests.swift`
- Modify: `ios/Runner/AppDelegate.swift`

**Step 1: Write the failing test**

Add XCTest coverage for:
- countdown-only live-activity presentation
- duplicate activity selection preferring the stored activity id
- duplicate activity selection falling back to the first available activity

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: FAIL because the new helpers do not exist yet.

### Task 2: Implement duplicate-collapsing presentation logic

**Files:**
- Modify: `ios/Runner/AppDelegate.swift`

**Step 1: Add minimal implementation**

Create small helper types/functions that:
- only present live activity when `snapshot.countdown != nil`
- choose one primary activity id and mark the rest as stale
- end stale activities whenever a live activity update occurs

**Step 2: Run test to verify it passes**

Run: `xcodebuild test -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS for the new RunnerTests.

### Task 3: Redesign the live activity card

**Files:**
- Modify: `ios/Extensions/DoggyLogLiveActivity.swift`

**Step 1: Update the SwiftUI layout**

Implement a single countdown-led card that:
- removes the mood + scene subtitle
- keeps pet name and task counts
- uses a warmer glass card treatment and stronger countdown typography
- keeps next-task info only as a small secondary footer

**Step 2: Verify visually and build**

Run:
- `xcodebuild test -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16'`
- `flutter test test/doggylog_shared_snapshot_test.dart`

Expected: tests pass and the live activity code compiles cleanly.
