# Notification Permission Flow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a manual notification-permission switch in settings and only auto-prompt for notification permission after the user successfully creates their first schedule item.

**Architecture:** First lock down the desired behavior with controller/widget regression tests. Then extend the notification service so app state can read the real OS permission status on startup, wire the settings UI to a switch-based trigger, and narrow the save-task permission prompt to the "first newly created schedule" case while keeping reminder scheduling intact.

**Tech Stack:** Flutter, Riverpod, flutter_local_notifications, drift, flutter_test

---

### Task 1: Add controller regression tests for notification permission timing

**Files:**
- Add: `test/app_state_controller_test.dart`
- Modify: `lib/features/shared/application/doggylog_providers.dart`
- Modify: `lib/platform/notifications/doggylog_notification_service.dart`

**Step 1: Write the failing test**

Add tests that verify:
- app state loads the persisted notification permission status from the notification service
- saving the very first newly created task requests notification permission once
- saving later tasks or editing an existing task does not request permission again

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_state_controller_test.dart`
Expected: FAIL because startup does not hydrate notification permission and `saveTask` prompts on every save.

**Step 3: Write minimal implementation**

Add a read-only permission status method to `DoggylogNotificationService`, hydrate it during controller init, and gate the auto-prompt in `saveTask` to the first newly created schedule path only.

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_state_controller_test.dart`
Expected: PASS.

### Task 2: Add a settings switch that manually triggers notification permission

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `test/widgets_test.dart`

**Step 1: Write the failing test**

Add a widget test that pumps `SettingsScreen` with notification permission disabled and expects:
- a switch tile labeled with the notification copy to appear in the main settings section
- toggling the switch to on triggers the controller permission request callback

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL because the screen currently exposes only a button in the debug capabilities page.

**Step 3: Write minimal implementation**

Replace the hidden button-only affordance with a switch in the main settings list and keep it bound to the controller/state permission flag.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS.

### Task 3: Focused verification

**Files:**
- Verify only

**Step 1: Run focused tests**

Run: `flutter test test/app_state_controller_test.dart test/widgets_test.dart`

**Step 2: Run static analysis**

Run: `flutter analyze`

**Step 3: Review output**

Confirm the new permission flow is covered, the settings UI renders the new switch, and analysis stays clean.
