# Profile Tab Review Card Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将底部导航调整为“倒计时 / 日历 / 我的”三项，并把原“任务复盘”内容合并到“我的”页顶部卡片中。

**Architecture:** 保留现有 `StatsScreen` 作为可复用的复盘内容容器，将其卡片区抽出给“我的”页复用；`HomeShell` 只维护三个底部页签并把默认索引设为日历；通过 widget 测试锁定默认页、底栏文案、以及“我的”页顶部的任务复盘展示。

**Tech Stack:** Flutter, Material 3, Riverpod, flutter_test

---

### Task 1: 底部导航行为测试

**Files:**
- Modify: `test/widgets_test.dart`
- Modify: `lib/features/home/presentation/home_shell.dart`

**Step 1: Write the failing test**

新增 widget 测试，验证：
- 底部只显示“倒计时 / 日历 / 我的”
- 不再显示“复盘 / 设置”
- 首次渲染默认展示日历页内容

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL，因为当前底部仍是四个 Tab，且“日历”不是默认页。

**Step 3: Write minimal implementation**

调整 `HomeShell` 页签顺序、数量、标签与默认索引。

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS

### Task 2: 我的页整合任务复盘

**Files:**
- Modify: `test/widgets_test.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/features/stats/presentation/stats_screen.dart`

**Step 1: Write the failing test**

新增 widget 测试，验证“我的”页顶部可见“任务复盘”卡片，并包含原复盘页中的关键指标文案。

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets_test.dart`
Expected: FAIL，因为当前“设置”页未展示复盘卡片。

**Step 3: Write minimal implementation**

抽取复盘内容组件，在“我的”页顶部插入，保留原有设置项在其下方。

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets_test.dart`
Expected: PASS
