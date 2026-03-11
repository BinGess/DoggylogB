# Remove Pet Onboarding Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove the initial pet-selection onboarding flow so new and returning users always enter the main app directly.

**Architecture:** Delete the onboarding route as an app entry requirement and treat onboarding as permanently completed in persisted preferences. Keep the seeded default pet roster so theme selection and pet management still work after launch, then remove no-longer-used onboarding UI/controller/repository code and update tests accordingly.

**Tech Stack:** Flutter, Riverpod, GoRouter, Drift, SharedPreferences, widget/unit tests

---

### Task 1: Lock direct-entry behavior with failing tests

**Files:**
- Modify: `test/app_router_test.dart`
- Modify: `test/app_repository_test.dart`

**Step 1: Write the failing test**

Add tests that assert:
- the router no longer redirects non-onboarded users to `/onboarding`
- loading default preferences returns onboarding as completed

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_router_test.dart test/app_repository_test.dart`
Expected: FAIL because routing and stored defaults still preserve onboarding.

**Step 3: Write minimal implementation**

Update router and preference loading/defaults to remove onboarding gating while preserving compatibility with stored data.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_router_test.dart test/app_repository_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add test/app_router_test.dart test/app_repository_test.dart lib/app/router/app_router.dart lib/features/shared/domain/models.dart lib/features/shared/data/app_repository.dart
git commit -m "refactor: remove onboarding gating"
```

### Task 2: Remove onboarding UI and dead code

**Files:**
- Modify: `lib/app/router/app_router.dart`
- Modify: `lib/features/shared/application/doggylog_providers.dart`
- Modify: `lib/features/shared/data/app_repository.dart`
- Delete: `lib/features/onboarding/presentation/onboarding_screen.dart`

**Step 1: Write the failing test**

Rely on the Task 1 tests plus analyzer/compiler feedback to catch leftover references to onboarding-only APIs.

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_router_test.dart`
Expected: FAIL or compile error until onboarding references are removed.

**Step 3: Write minimal implementation**

Remove the onboarding route and screen reference, delete onboarding-specific controller/repository methods that are no longer used, and keep app startup working through the existing seeded pet roster.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_router_test.dart test/app_repository_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/app/router/app_router.dart lib/features/shared/application/doggylog_providers.dart lib/features/shared/data/app_repository.dart
git rm lib/features/onboarding/presentation/onboarding_screen.dart
git commit -m "refactor: delete pet onboarding flow"
```

### Task 3: Full verification

**Files:**
- Test: `test/app_router_test.dart`
- Test: `test/app_repository_test.dart`
- Test: `test/widgets_test.dart`
- Test: `test/settings_navigation_test.dart`
- Test: `test/pet_skin_gallery_test.dart`

**Step 1: Run focused verification**

Run: `flutter test test/app_router_test.dart test/app_repository_test.dart test/widgets_test.dart test/settings_navigation_test.dart test/pet_skin_gallery_test.dart`
Expected: PASS

**Step 2: Review diff**

Run: `git diff -- lib/app/router/app_router.dart lib/features/shared/domain/models.dart lib/features/shared/data/app_repository.dart lib/features/shared/application/doggylog_providers.dart test/app_router_test.dart test/app_repository_test.dart`
Expected: Only onboarding-removal changes appear.

**Step 3: Commit**

```bash
git add docs/plans/2026-03-11-remove-pet-onboarding.md lib/app/router/app_router.dart lib/features/shared/domain/models.dart lib/features/shared/data/app_repository.dart lib/features/shared/application/doggylog_providers.dart test/app_router_test.dart test/app_repository_test.dart
git commit -m "refactor: remove pet onboarding"
```
