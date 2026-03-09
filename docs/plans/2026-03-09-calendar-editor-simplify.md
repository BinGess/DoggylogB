# Calendar Editor Simplify Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify the calendar task editor by removing note, category, and pet association controls, and reducing reminder UI to only show the selected option.

**Architecture:** Keep the domain model intact to avoid a broad migration. Limit changes to the task editor UI and the values it submits, preserving compatibility with existing storage and calendar sync code.

**Tech Stack:** Flutter, Riverpod, flutter_test

---

### Task 1: Lock the editor behavior with a widget test

**Files:**
- Create: `test/task_editor_sheet_test.dart`
- Modify: `lib/features/calendar/presentation/task_editor_sheet.dart`

**Step 1: Write the failing test**

Add a widget test that renders `TaskEditorSheet` with an existing item and asserts:
- `备注` is absent
- `关联宠物` is absent
- category labels such as `日常` and `宠物相关` are absent
- only the currently selected reminder labels are shown

**Step 2: Run test to verify it fails**

Run: `flutter test test/task_editor_sheet_test.dart`
Expected: FAIL because the current sheet still renders removed fields and all reminder chips.

**Step 3: Write minimal implementation**

Update the editor to:
- remove description/category/pet controls
- keep only title, start/end time, and reminder control
- replace multi-select reminder chips with a single-select dropdown showing one chosen value

**Step 4: Run test to verify it passes**

Run: `flutter test test/task_editor_sheet_test.dart`
Expected: PASS

### Task 2: Verify no regression in existing calendar tests

**Files:**
- Test: `test/calendar_sort_test.dart`
- Test: `test/widgets_test.dart`

**Step 1: Run targeted regression tests**

Run: `flutter test test/task_editor_sheet_test.dart test/widgets_test.dart test/calendar_sort_test.dart`
Expected: PASS
