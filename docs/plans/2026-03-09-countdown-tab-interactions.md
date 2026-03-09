# Countdown Tab Interactions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 为倒计时 TAB 增加与日历页一致的左右滑操作，并支持点击条目查看与编辑详情。

**Architecture:** 在现有倒计时数据模型和仓库能力上补齐 `copyWith`、删除和完成状态切换接口；倒计时列表页复用日历页的 `Dismissible + InkWell` 交互模式；新增倒计时详情底部弹层，承接查看、编辑、删除与完成状态切换。测试先覆盖仓库行为与界面交互，再补实现。

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test

---

### Task 1: 倒计时数据能力

**Files:**
- Modify: `lib/features/shared/domain/models.dart`
- Modify: `lib/features/shared/data/app_repository.dart`
- Modify: `lib/features/shared/application/doggylog_providers.dart`
- Test: `test/app_repository_test.dart`

**Step 1: Write the failing test**

新增仓库测试，验证倒计时可被标记完成与删除。

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_repository_test.dart`
Expected: FAIL，因为仓库还没有对应接口。

**Step 3: Write minimal implementation**

为 `CountdownItem` 添加 `copyWith`，在仓库和状态控制器中补齐保存、切换完成、删除能力。

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_repository_test.dart`
Expected: PASS

### Task 2: 倒计时详情与列表交互

**Files:**
- Create: `lib/features/countdown/presentation/countdown_detail_sheet.dart`
- Modify: `lib/features/countdown/presentation/countdown_screen.dart`
- Test: `test/widgets_test.dart`

**Step 1: Write the failing test**

新增 widget 测试，验证倒计时卡片支持左右滑文案、点击后弹出详情，并可看到“完成倒计时”操作。

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL，因为详情弹层与交互尚未接入。

**Step 3: Write minimal implementation**

新增倒计时详情弹层；倒计时列表改为 `Dismissible` 卡片，右滑切换完成、左滑删除、点击打开详情；完成态在卡片与详情中展示。

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS

### Task 3: 回归验证

**Files:**
- Verify only

**Step 1: Run targeted tests**

Run: `flutter test test/app_repository_test.dart test/widgets_test.dart`

**Step 2: Run broader confidence check**

Run: `flutter test test/calendar_sort_test.dart test/task_editor_sheet_test.dart`

**Step 3: Review output**

确认无失败、无新增相关回归。
