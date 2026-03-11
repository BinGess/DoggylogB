# Card Surface Refresh Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refresh the countdown and settings card surfaces so they read as clean, airy, and neutral instead of muddy or over-tinted.

**Architecture:** Lock the desired visual direction with theme-level tests first, then update the shared surface tokens and `LiquidGlassCard` rendering so all card-based screens inherit the cleaner treatment automatically. After that, trim local status fills on countdown/settings surfaces so page-specific accents do not reintroduce the dirty look.

**Tech Stack:** Flutter, Material 3, Riverpod, shared theme extensions, widget tests

---

### Task 1: Lock airy card theme expectations

**Files:**
- Modify: `test/app_theme_test.dart`
- Test: `test/app_theme_test.dart`

**Step 1: Write the failing test**

Add a light-theme test that iterates every `AppSkinTheme` and asserts:
- `AppThemeSurfaceStyle.cardGradientColors` stay in a high-luminance range suitable for clean cards
- the darkest channel of each card gradient color stays near white
- the card border/shadow styling remains subtle enough for light surfaces

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_theme_test.dart`
Expected: FAIL because at least one skin still uses tinted/darker card colors outside the new clean-surface thresholds.

**Step 3: Write minimal implementation**

Adjust theme tokens only as much as needed to satisfy the new light-surface expectations.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_theme_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add test/app_theme_test.dart lib/app/theme/app_skin_theme.dart lib/app/theme/app_theme.dart
git commit -m "refactor: refresh app card surfaces"
```

### Task 2: Rework shared card rendering

**Files:**
- Modify: `lib/features/shared/presentation/widgets/liquid_glass_card.dart`
- Modify: `lib/app/theme/app_theme.dart`

**Step 1: Write the failing test**

Add or extend a widget/theme test that verifies the shared card uses the cleaned-up theme extension values instead of adding a heavy tinted fallback look.

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_theme_test.dart test/widgets_test.dart`
Expected: FAIL because the card still applies strong highlight/shadow treatment.

**Step 3: Write minimal implementation**

Reduce highlight opacity, soften shadow spread, and keep the shared card background anchored to neutral light gradients with restrained accents.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_theme_test.dart test/widgets_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/shared/presentation/widgets/liquid_glass_card.dart lib/app/theme/app_theme.dart test/app_theme_test.dart test/widgets_test.dart
git commit -m "refactor: soften liquid glass cards"
```

### Task 3: Trim page-level accent fills

**Files:**
- Modify: `lib/features/countdown/presentation/countdown_screen.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Test: `test/widgets_test.dart`

**Step 1: Write the failing test**

Add assertions around countdown badges/summary containers and settings card usage so local fills stay restrained and readable on the lighter shared cards.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL because countdown status and helper fills still lean too saturated for the refreshed card surface.

**Step 3: Write minimal implementation**

Shift local badge, swipe, and helper backgrounds to low-alpha surface/primary blends that preserve hierarchy without muddying the page.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/widgets_test.dart
git commit -m "style: clean up countdown and settings cards"
```

### Task 4: Full verification

**Files:**
- Test: `test/app_theme_test.dart`
- Test: `test/widgets_test.dart`
- Test: `test/settings_navigation_test.dart`

**Step 1: Run focused verification**

Run: `flutter test test/app_theme_test.dart test/widgets_test.dart test/settings_navigation_test.dart`
Expected: PASS with no new failures.

**Step 2: Review diffs**

Run: `git diff -- lib/app/theme/app_skin_theme.dart lib/app/theme/app_theme.dart lib/features/shared/presentation/widgets/liquid_glass_card.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/app_theme_test.dart test/widgets_test.dart`
Expected: Only the planned surface refresh changes appear.

**Step 3: Commit**

```bash
git add docs/plans/2026-03-11-card-surface-refresh.md lib/app/theme/app_skin_theme.dart lib/app/theme/app_theme.dart lib/features/shared/presentation/widgets/liquid_glass_card.dart lib/features/countdown/presentation/countdown_screen.dart lib/features/settings/presentation/settings_screen.dart test/app_theme_test.dart test/widgets_test.dart
git commit -m "style: refresh card surfaces"
```
