# Calendar Sync Dedup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 修复导入系统日历和同步到 iOS 日历后，日历页出现同内容事件重复展示的问题。

**Architecture:** 先在仓库层复现“同一个逻辑事件因不同 `systemEntryId` 被重复入库”的问题，再在导入合并逻辑中增加稳定去重键，优先复用已有本地记录而不是新增重复记录。保持 UI 层不变，避免把数据问题掩盖到展示层。

**Tech Stack:** Flutter, Drift, Riverpod, iOS EventKit

---

### Task 1: Reproduce duplicate imported events in repository tests

**Files:**
- Modify: `test/app_repository_test.dart`
- Modify: `lib/features/shared/data/app_repository.dart`

**Step 1: Write the failing test**

添加一个仓库测试，先插入一条已有的 iOS 日历事件，再导入一条标题/时间/描述相同但 `systemEntryId` 不同的事件。

**Step 2: Run test to verify it fails**

Run: `flutter test test/app_repository_test.dart`

Expected: FAIL，数据库里会保留两条内容相同的事件。

**Step 3: Write minimal implementation**

在 `mergeImportedCalendarItems` 中增加内容级去重匹配，命中后更新原记录的 `systemEntryId` 与内容字段，而不是新建记录。

**Step 4: Run test to verify it passes**

Run: `flutter test test/app_repository_test.dart`

Expected: PASS

### Task 2: Verify sync regression surface

**Files:**
- Test: `test/ios_calendar_sync_service_test.dart`

**Step 1: Run focused regression tests**

Run: `flutter test test/app_repository_test.dart test/ios_calendar_sync_service_test.dart`

Expected: PASS
