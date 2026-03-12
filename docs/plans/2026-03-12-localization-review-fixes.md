# Localization Review Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the current multilingual regressions so Chinese and English modes no longer leak each other's UI copy, seeded demo data, or hardcoded date/breed labels.

**Architecture:** First restore the broken localization API so the app compiles and tests can run. Then move seeded sample content from pre-translated persisted strings to locale-agnostic templates that are localized only when inserted with the current app language. Finally, replace remaining hardcoded UI/date/breed formatting with locale-aware helpers and lock the behavior down with regression tests.

**Tech Stack:** Flutter, Riverpod, Drift, SharedPreferences, intl, flutter_test

---

### Task 1: Restore the broken localization contract

**Files:**
- Modify: `lib/app/localization/app_localizations.dart`
- Modify: `test/widgets_test.dart`

**Step 1: Write the failing test**

Add/update a widget test that pumps `CountdownScreen` and expects the subtitle text to render from localizations.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL with `countdownSubtitle` missing.

**Step 3: Write minimal implementation**

Restore the `countdownSubtitle` getter in `AppLocalizations`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS for the countdown subtitle case.

### Task 2: Add regression tests for locale-specific labels and formatting

**Files:**
- Modify: `test/widgets_test.dart`
- Modify: `test/pet_skin_gallery_test.dart`
- Add or modify: `test/app_localizations_test.dart`

**Step 1: Write the failing test**

Add tests that verify:
- Chinese locale shows localized breed labels instead of English breed names.
- English locale uses English-style date output for countdown summary/detail helpers.
- Settings screen does not render raw hardcoded `Face ID / Touch ID` copy outside localization.

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_localizations_test.dart test/pet_skin_gallery_test.dart test/widgets_test.dart`
Expected: FAIL on current hardcoded outputs.

**Step 3: Write minimal implementation**

Update localization helpers and UI call sites to use locale-aware strings and formatting.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_localizations_test.dart test/pet_skin_gallery_test.dart test/widgets_test.dart`
Expected: PASS.

### Task 3: Remove persisted translated seed strings

**Files:**
- Modify: `lib/features/shared/data/app_repository.dart`
- Add or modify: `test/app_repository_test.dart`

**Step 1: Write the failing test**

Add a repository-level test that proves seeded sample content is not tied to whichever locale was active when it was first inserted, and that seed templates remain locale-agnostic.

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_repository_test.dart`
Expected: FAIL with current seed implementation.

**Step 3: Write minimal implementation**

Refactor sample/seed generation so persistent seed keys/templates are locale-agnostic and localized only at presentation time or through deterministic mapping that can be re-derived.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_repository_test.dart`
Expected: PASS.

### Task 4: Full verification

**Files:**
- Verify only

**Step 1: Run focused verification**

Run: `flutter test test/app_localizations_test.dart test/app_repository_test.dart test/pet_skin_gallery_test.dart test/widgets_test.dart test/settings_navigation_test.dart`

**Step 2: Run static analysis**

Run: `flutter analyze`

**Step 3: Review output**

Confirm there are no compile errors and the new locale regression tests cover the repaired paths.
