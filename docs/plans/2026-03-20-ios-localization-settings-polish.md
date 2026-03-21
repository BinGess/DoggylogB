# iOS Localization And Settings Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the iOS home screen app name localization, restore the About screen app icon, and prevent the Settings page content from being obscured by the bottom navigation bar.

**Architecture:** Keep the fixes small and local. Use iOS plist localization for the app name, Flutter asset registration for the About icon, and bottom safe-area aware padding for the Settings page so the list clears the floating tab bar.

**Tech Stack:** Flutter, Dart, iOS InfoPlist localization, Xcode project resources.

---

### Task 1: Fix iOS home screen display name fallback

**Files:**
- Modify: `ios/Runner/Info.plist`
- Modify: `ios/Runner/zh-Hans.lproj/InfoPlist.strings`

**Step 1: Verify the current localized display name source**

Check:
- `ios/Runner/Info.plist`
- `ios/Runner/zh-Hans.lproj/InfoPlist.strings`

Expected:
- Base plist still uses the English fallback name.

**Step 2: Update the fallback and localized name**

Change:
- Base `CFBundleDisplayName` and `CFBundleName` to the intended product naming strategy.
- Simplify the Chinese localized value if needed so the home screen consistently shows Chinese when Chinese localization is active.

**Step 3: Verify plist files are syntactically valid**

Run:
- `plutil -lint ios/Runner/Info.plist`

### Task 2: Restore About screen icon rendering

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/settings/presentation/about_screen.dart`

**Step 1: Verify the asset exists and is missing from Flutter assets**

Check:
- `assets/icon.png`
- `pubspec.yaml`

Expected:
- File exists, but `assets/icon.png` is not listed under `flutter.assets`.

**Step 2: Register the asset and add a graceful UI fallback**

Change:
- Add `assets/icon.png` to `flutter.assets`.
- Keep the About screen image usage, but make the widget resilient if the asset fails to decode.

**Step 3: Verify asset registration via Flutter tests**

Run:
- `flutter test test/doggylog_shared_snapshot_test.dart`

### Task 3: Prevent Settings content from hiding behind the floating tab bar

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Reference: `lib/features/home/presentation/home_shell.dart`

**Step 1: Confirm the current safe-area behavior**

Check:
- `SafeArea(bottom: false)` in Settings screen
- `HomeShell.navHeight` and floating tab bar padding

Expected:
- Settings list does not reserve enough bottom space for the floating navigation.

**Step 2: Apply a bottom-safe layout fix**

Change:
- Respect bottom safe area or compute a larger bottom inset using the tab bar height and device padding.
- Keep the current visual design while ensuring the final settings items remain scrollable and visible.

**Step 3: Verify related settings tests still pass**

Run:
- `flutter test test/settings_navigation_test.dart`
- `flutter test test/settings_notification_switch_test.dart`
