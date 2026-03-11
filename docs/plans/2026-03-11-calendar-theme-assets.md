# Calendar Theme Assets Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Map the four calendar dog PNG/GIF asset groups to the four visible theme styles and switch them automatically when the user changes theme.

**Architecture:** Replace hard-coded timeline asset constants with a single theme-aware asset mapper. Read the current theme from the selected pet / skin theme, then use the same mapper everywhere the calendar timeline illustration appears so PNG and GIF stay in sync.

**Tech Stack:** Flutter, Riverpod, flutter_test

---

### Task 1: Lock the theme-to-asset mapping with tests

**Files:**
- Modify: `test/calendar_timeline_dog_asset_test.dart`
- Create: `lib/features/calendar/presentation/calendar_theme_assets.dart`

**Step 1: Write the failing test**

Add tests that assert:
- `积木学堂` uses the original `calendar_dog_timeline` PNG/GIF pair
- `AI 对话` uses the `calendar_dog1_timeline` pair
- `健康轻灵` uses the `calendar_dog2_timeline` pair
- `云朵温柔` uses the `calendar_dog3_timeline` pair

**Step 2: Run test to verify it fails**

Run: `flutter test test/calendar_timeline_dog_asset_test.dart`
Expected: FAIL because the theme-aware mapper does not exist yet.

**Step 3: Write minimal implementation**

Create a small asset descriptor and theme mapping helper.

**Step 4: Run test to verify it passes**

Run: `flutter test test/calendar_timeline_dog_asset_test.dart`
Expected: PASS

### Task 2: Rewire calendar UI to the mapper

**Files:**
- Modify: `lib/features/calendar/presentation/calendar_screen.dart`

**Step 1: Use the failing asset test as coverage**

Keep the asset mapping test red until the UI is switched to use the helper.

**Step 2: Write minimal implementation**

Read the active `AppSkinTheme` from the selected pet and use the mapped PNG/GIF pair in every timeline illustration and fallback render.

**Step 3: Run focused verification**

Run: `flutter test test/calendar_timeline_dog_asset_test.dart test/widgets_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add docs/plans/2026-03-11-calendar-theme-assets.md lib/features/calendar/presentation/calendar_theme_assets.dart lib/features/calendar/presentation/calendar_screen.dart test/calendar_timeline_dog_asset_test.dart
git commit -m "feat: map calendar timeline assets to themes"
```
