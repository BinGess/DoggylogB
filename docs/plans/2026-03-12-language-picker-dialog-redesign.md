# Language Picker Dialog Redesign Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current raw language dropdown in settings with a polished, theme-aware language selection modal that matches the app's pet skin system and feels intentionally designed on mobile.

**Architecture:** Keep the existing `AppLanguageMode` preference model and locale resolution logic. Move the selection UI into a dedicated bottom-sheet widget that reads the current theme surface tokens, presents language options as branded cards, and updates preferences immediately on tap.

**Tech Stack:** Flutter, Riverpod, flutter_test

---

### Task 1: Add regression tests for the new language selection flow

**Files:**
- Modify: `test/widgets_test.dart`

**Step 1: Write the failing test**

Add widget coverage that verifies:
- tapping the language settings row opens a modal selector
- the selector renders all supported language options
- choosing a language updates the summary text on the settings row and closes the selector

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL because the screen still uses the inline dropdown and no custom modal exists.

**Step 3: Write minimal implementation**

Replace the dropdown interaction with a dedicated modal entry point and wire it to `updatePreferences`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS for the new language modal coverage.

### Task 2: Build a theme-aware language picker modal

**Files:**
- Add: `lib/features/settings/presentation/widgets/language_picker_bottom_sheet.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/app/localization/app_localizations.dart`

**Step 1: Implement the modal shell**

Create a custom bottom sheet with a strong header, concise supporting copy, clear selected state, and full-width tappable language option cards.

**Step 2: Localize new copy**

Add any new dialog title, subtitle, and option metadata strings needed for the redesigned experience.

**Step 3: Connect theme styling**

Use the app's current theme tokens so button fills, text hierarchy, borders, and selected accents all adapt when the user changes skins.

### Task 3: Verify focused behavior

**Files:**
- Verify only

**Step 1: Run focused tests**

Run: `flutter test test/widgets_test.dart test/settings_navigation_test.dart`

**Step 2: Review output**

Confirm the new modal flow works, the settings screen still navigates correctly, and no regressions were introduced in the existing settings tests.
