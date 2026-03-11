# Pet Theme Roster Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make pet selection on the management page the single source of truth for theme switching, ensure the app has one pet per skin style, and upgrade each skin into a cohesive full-theme treatment.

**Architecture:** Remove the settings-page selector and keep theme switching driven by the currently selected pet. Backfill a four-pet roster at the repository layer so existing installs are corrected, then update the theme spec and pets screen so each pet represents a distinct, fully styled UI system rather than a background tint.

**Tech Stack:** Flutter, Riverpod, Drift, SharedPreferences, flutter_test, Google Fonts

---

### Task 1: Lock roster and selection behavior with tests

**Files:**
- Modify: `test/app_repository_test.dart`
- Create: `test/pet_skin_gallery_test.dart`

**Step 1: Write the failing test**

Add tests that assert:
- `seedIfNeeded()` yields at least one pet for each breed
- `completeOnboarding()` does not create duplicate pets for a breed that already exists
- The pet management gallery reports the tapped pet id

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_repository_test.dart test/pet_skin_gallery_test.dart`
Expected: FAIL because the roster sync and new gallery widget do not exist yet.

**Step 3: Write minimal implementation**

Add repository roster sync and the gallery widget callback path.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_repository_test.dart test/pet_skin_gallery_test.dart`
Expected: PASS

### Task 2: Rewire theme switching to pet management only

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/features/shared/application/doggylog_providers.dart`
- Modify: `lib/features/pets/presentation/pets_screen.dart`

**Step 1: Write the failing expectation**

Use the new gallery test to cover pet-page selection and existing theme tests to cover mapping.

**Step 2: Write minimal implementation**

Remove the settings-page selector, make pet-page card taps switch the selected pet immediately, and keep the settings entry as the navigation path into management.

**Step 3: Run focused verification**

Run: `flutter test test/app_theme_test.dart test/pet_skin_gallery_test.dart test/settings_navigation_test.dart`
Expected: PASS

### Task 3: Upgrade each skin into a cohesive design system

**Files:**
- Modify: `lib/app/theme/app_skin_theme.dart`
- Modify: `lib/app/theme/app_theme.dart`
- Modify: `lib/features/shared/presentation/widgets/liquid_glass_card.dart`
- Modify: `lib/features/shared/presentation/widgets/soft_backdrop.dart`
- Modify: `lib/features/pets/presentation/pets_screen.dart`

**Step 1: Write the failing expectation**

Keep the theme tests green while expanding the theme surface coverage.

**Step 2: Write minimal implementation**

Apply fuller color systems, button treatments, typography pairing, card shadows, and pet-page previews inspired by UI/UX Pro Max styles.

**Step 3: Run focused verification**

Run: `flutter test test/app_theme_test.dart test/app_repository_test.dart test/pet_skin_gallery_test.dart test/settings_navigation_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add docs/plans/2026-03-11-pet-theme-roster-fix.md test/app_repository_test.dart test/pet_skin_gallery_test.dart lib/features/shared/application/doggylog_providers.dart lib/features/settings/presentation/settings_screen.dart lib/features/pets/presentation/pets_screen.dart lib/app/theme/app_skin_theme.dart lib/app/theme/app_theme.dart lib/features/shared/presentation/widgets/liquid_glass_card.dart lib/features/shared/presentation/widgets/soft_backdrop.dart
git commit -m "feat: rework pet theme switching"
```
