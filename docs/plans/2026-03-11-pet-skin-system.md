# Pet Skin System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a pet-linked skin system so selecting a different pet switches the app skin, and expose the selector directly in Settings.

**Architecture:** Derive the active app skin from the currently selected pet breed, then feed that skin into the global `AppTheme`. Use a small theme data model plus a theme extension so shared UI containers such as the backdrop and glass cards can render distinct visual treatments per pet style without rewriting each screen.

**Tech Stack:** Flutter, Material 3, Riverpod, flutter_test, Google Fonts

---

### Task 1: Define skin themes and tests

**Files:**
- Modify: `lib/app/theme/app_theme.dart`
- Create: `lib/app/theme/app_skin_theme.dart`
- Test: `test/app_theme_test.dart`

**Step 1: Write the failing test**

Add tests that assert:
- Different pet skins produce different primary colors
- The skin mapping from breed to app skin is stable
- Font scaling still works with the new theme API

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_theme_test.dart`
Expected: FAIL because skin theme types and mapping do not exist yet.

**Step 3: Write minimal implementation**

Add:
- `AppSkinTheme` enum / descriptor objects
- `PetBreed -> AppSkinTheme` mapper
- `AppTheme.light/dark(..., skinTheme: ...)`
- Theme extension for backdrop/card styling

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_theme_test.dart`
Expected: PASS

### Task 2: Add a settings selector with tests

**Files:**
- Create: `lib/features/settings/presentation/widgets/pet_skin_selector.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Test: `test/pet_skin_selector_test.dart`

**Step 1: Write the failing test**

Add a widget test that renders the selector with multiple pets and verifies tapping a different pet triggers the callback with the chosen pet id.

**Step 2: Run test to verify it fails**

Run: `flutter test test/pet_skin_selector_test.dart`
Expected: FAIL because the selector widget does not exist yet.

**Step 3: Write minimal implementation**

Build a selector that:
- Shows current skin style name and short description
- Displays pet options as accessible chips/cards
- Calls `selectPet` when the user changes the active pet

**Step 4: Run test to verify it passes**

Run: `flutter test test/pet_skin_selector_test.dart`
Expected: PASS

### Task 3: Wire global theme to active pet and verify

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `lib/features/shared/presentation/widgets/soft_backdrop.dart`
- Modify: `lib/features/shared/presentation/widgets/liquid_glass_card.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`

**Step 1: Write the failing integration expectation**

Use the new tests from Task 1 and Task 2 as coverage for the integration path.

**Step 2: Write minimal implementation**

Update app bootstrap and shared widgets so:
- Current selected pet determines active app skin
- Shared backdrop/card visuals use the active skin extension
- Settings page includes the pet-linked skin selector and keeps the pet management entry

**Step 3: Run focused verification**

Run: `flutter test test/app_theme_test.dart test/pet_skin_selector_test.dart test/settings_navigation_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add docs/plans/2026-03-11-pet-skin-system.md test/app_theme_test.dart test/pet_skin_selector_test.dart lib/app/app.dart lib/app/theme/app_skin_theme.dart lib/app/theme/app_theme.dart lib/features/settings/presentation/settings_screen.dart lib/features/settings/presentation/widgets/pet_skin_selector.dart lib/features/shared/presentation/widgets/soft_backdrop.dart lib/features/shared/presentation/widgets/liquid_glass_card.dart
git commit -m "feat: add pet-linked app skins"
```
