# Inline Soft Backdrop Headers Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move the countdown and settings page titles into the `SoftBackdrop` content flow so their top sections feel as naturally integrated as the calendar page.

**Architecture:** Remove `Scaffold.appBar` from the two affected screens and render an in-body header block as the first child inside `SoftBackdrop`, wrapped by `SafeArea` so status bar spacing remains correct. Extract the shared header row into a reusable widget so countdown, settings, and future pages can share the same integrated top treatment without duplicating padding and action layout.

**Tech Stack:** Flutter, Riverpod, shared presentation widgets, widget tests

---

### Task 1: Lock the new page structure with failing tests

**Files:**
- Modify: `test/widgets_test.dart`

**Step 1: Write the failing test**

Add widget tests asserting:
- `CountdownScreen` renders its title without a Material `AppBar`
- `SettingsScreen` renders its title without a Material `AppBar`
- the title still appears on screen after the refactor

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart --plain-name "renders title inline"`
Expected: FAIL because both pages still use `Scaffold.appBar`.

**Step 3: Write minimal implementation**

Replace the separate app bars with inline header content inside `SoftBackdrop`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart --plain-name "renders title inline"`
Expected: PASS

**Step 5: Commit**

```bash
git add test/widgets_test.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart
git commit -m "refactor: inline soft backdrop page headers"
```

### Task 2: Extract a shared inline page header

**Files:**
- Create: `lib/features/shared/presentation/widgets/soft_backdrop_page_header.dart`
- Modify: `lib/features/countdown/presentation/countdown_screen.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Delete or stop using: `lib/features/shared/presentation/widgets/soft_backdrop_app_bar.dart`

**Step 1: Write the failing test**

Use the Task 1 tests plus any compile errors from removing the old app-bar dependency.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL or compile error until the new shared header is wired in.

**Step 3: Write minimal implementation**

Create a shared inline header widget with safe top padding, title text, optional subtitle, and trailing actions. Use it as the first visible content block on countdown and settings pages.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/shared/presentation/widgets/soft_backdrop_page_header.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/widgets_test.dart
git commit -m "feat: share inline backdrop page headers"
```

### Task 3: Full verification

**Files:**
- Test: `test/widgets_test.dart`
- Test: `test/settings_navigation_test.dart`
- Test: `test/pet_skin_gallery_test.dart`

**Step 1: Run focused verification**

Run: `flutter test test/widgets_test.dart test/settings_navigation_test.dart test/pet_skin_gallery_test.dart`
Expected: PASS

**Step 2: Review diff**

Run: `git diff -- lib/features/shared/presentation/widgets/soft_backdrop_page_header.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/widgets_test.dart`
Expected: Only the inline-header refactor appears.

**Step 3: Commit**

```bash
git add docs/plans/2026-03-11-inline-soft-backdrop-headers.md lib/features/shared/presentation/widgets/soft_backdrop_page_header.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/widgets_test.dart
git commit -m "refactor: unify inline page headers"
```
