import SwiftUI
import WidgetKit

// MARK: - Shared colour palette (mirrors Flutter app theme)

private extension Color {
  static let doggyTeal       = Color(red: 0.184, green: 0.561, blue: 0.541) // #2F8F8A
  static let doggyTealLight  = Color(red: 0.447, green: 0.788, blue: 0.757) // #72C9C1
  static let doggyBg         = Color(red: 0.965, green: 0.976, blue: 0.988) // #F6F9FC
}

// MARK: - Shared timeline provider (reads the same shared snapshot)

struct DoggyLogCalendarProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoggyLogEntry {
    DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load())
  }

  func getSnapshot(in context: Context, completion: @escaping (DoggyLogEntry) -> Void) {
    completion(DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DoggyLogEntry>) -> Void) {
    let entry = DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load())
    let nextMidnight = Calendar.current.nextDate(
      after: Date(),
      matching: DateComponents(hour: 0, minute: 0),
      matchingPolicy: .nextTime
    ) ?? Date().addingTimeInterval(3600)
    completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
  }
}

// MARK: - Large Calendar Widget

struct DoggyLogLargeCalendarWidget: Widget {
  let kind = "DoggyLogLargeCalendarWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogLargeCalendarView(entry: entry)
    }
    .configurationDisplayName("日历（大）")
    .description("查看本月完整日历，带宠物标记和任务提示。")
    .supportedFamilies([.systemLarge])
  }
}

// MARK: - Medium Calendar Widget

struct DoggyLogMediumCalendarWidget: Widget {
  let kind = "DoggyLogMediumCalendarWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogMediumCalendarView(entry: entry)
    }
    .configurationDisplayName("日历（周）")
    .description("显示本周日历，爪印标记有任务的日期。")
    .supportedFamilies([.systemMedium])
  }
}

// MARK: - Large Calendar View

struct DoggyLogLargeCalendarView: View {
  let entry: DoggyLogEntry

  private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

  var body: some View {
    let snapshot = entry.snapshot
    let monthLabel = _monthLabel(for: entry.date)
    let petName = snapshot?.pet.name ?? "DoggyLog"
    let days = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)

    VStack(alignment: .leading, spacing: 0) {
      // ── 标题行 ──────────────────────────────────────────
      HStack(alignment: .firstTextBaseline) {
        Text(monthLabel)
          .font(.system(size: 18, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.primary)
        Spacer()
        Text(petName)
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(Color.secondary)
        Text("🐾")
          .font(.system(size: 12))
      }
      .padding(.horizontal, 16)
      .padding(.top, 14)
      .padding(.bottom, 8)

      // ── 星期标题行 ────────────────────────────────────────
      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 10)
      .padding(.bottom, 4)

      Divider()
        .opacity(0.5)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)

      // ── 6×7 月历格 ────────────────────────────────────────
      LazyVGrid(columns: columns, spacing: 2) {
        ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
          _DayCell(day: day, showPetOnToday: true)
        }
      }
      .padding(.horizontal, 10)

      Spacer(minLength: 0)
    }
    .containerBackground(Color.doggyBg, for: .widget)
    .widgetURL(URL(string: "doggylog://tab/calendar"))
  }
}

// MARK: - Medium Calendar View

struct DoggyLogMediumCalendarView: View {
  let entry: DoggyLogEntry

  private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]

  var body: some View {
    let snapshot = entry.snapshot
    let monthLabel = _monthLabel(for: entry.date)
    let allDays = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let weekDays = _currentWeekDays(from: allDays, now: entry.date)

    VStack(alignment: .leading, spacing: 0) {
      // ── 标题行 ──────────────────────────────────────────
      HStack {
        Text(monthLabel)
          .font(.system(size: 15, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.primary)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.top, 12)
      .padding(.bottom, 6)

      // ── 星期标题行 ────────────────────────────────────────
      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 14)

      Spacer(minLength: 4)

      // ── 当前周：日期数字 + 爪印 ───────────────────────────
      HStack(spacing: 0) {
        ForEach(Array(weekDays.enumerated()), id: \.offset) { _, day in
          _WeekDayCell(day: day)
        }
      }
      .padding(.horizontal, 14)
      .padding(.bottom, 12)
    }
    .containerBackground(Color.doggyBg, for: .widget)
    .widgetURL(URL(string: "doggylog://tab/calendar"))
  }
}

// MARK: - Day Cell (Large calendar)

private struct _DayCell: View {
  let day: SnapshotCalendarDay
  let showPetOnToday: Bool

  var body: some View {
    VStack(spacing: 1) {
      ZStack {
        // 今日：Teal 圆形背景
        if day.isToday {
          Circle()
            .fill(Color.doggyTeal)
            .frame(width: 26, height: 26)
        }
        // 日期数字
        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(
            day.isToday
              ? Color.white
              : day.isInMonth
                ? Color.primary
                : Color.secondary.opacity(0.25)
          )
      }
      .frame(width: 26, height: 26)
      .overlay(alignment: .top) {
        // 宠物爪印浮在今日格子上方
        if day.isToday && showPetOnToday {
          Text("🐾")
            .font(.system(size: 10))
            .offset(y: -14)
        }
      }

      // 任务小圆点（非今日 & 有任务）
      Circle()
        .fill(day.taskCount > 0 && !day.isToday ? Color.doggyTeal.opacity(0.75) : Color.clear)
        .frame(width: 3.5, height: 3.5)
    }
    .frame(height: 40)
  }
}

// MARK: - Week Day Cell (Medium calendar)

private struct _WeekDayCell: View {
  let day: SnapshotCalendarDay

  var body: some View {
    VStack(spacing: 5) {
      // 日期数字
      ZStack {
        if day.isToday {
          Circle()
            .fill(Color.doggyTeal)
            .frame(width: 24, height: 24)
        }
        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(
            day.isToday
              ? Color.white
              : day.isInMonth
                ? Color.primary
                : Color.secondary.opacity(0.3)
          )
      }
      .frame(width: 24, height: 24)

      // 爪印指示
      Group {
        if day.isToday {
          // 今日：宠物 emoji 替代爪印
          Text("🐾")
            .font(.system(size: 14))
        } else {
          Image(systemName: day.taskCount > 0 ? "pawprint.fill" : "pawprint")
            .font(.system(size: 11))
            .foregroundStyle(
              day.taskCount > 0
                ? Color.doggyTeal
                : Color.secondary.opacity(0.28)
            )
        }
      }
      .frame(height: 16)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Helpers

private func _monthLabel(for date: Date) -> String {
  let cal = Calendar.current
  let year = cal.component(.year, from: date)
  let month = cal.component(.month, from: date)
  return "\(month)月 \(year)"
}

/// 从 42-cell calendarDays 中提取包含今日的那一周（7天）
private func _currentWeekDays(
  from days: [SnapshotCalendarDay],
  now: Date
) -> [SnapshotCalendarDay] {
  let todayIdx = days.firstIndex(where: { $0.isToday }) ?? 0
  let weekStart = (todayIdx / 7) * 7
  let range = weekStart..<min(weekStart + 7, days.count)
  let slice = Array(days[range])
  // 用空格子补足 7 个
  if slice.count < 7 {
    let pad = Array(repeating: SnapshotCalendarDay(
      day: 0, isInMonth: false, isToday: false, taskCount: 0
    ), count: 7 - slice.count)
    return slice + pad
  }
  return slice
}

/// 无 snapshot 时生成当月占位日历格
private func _placeholderDays(for date: Date) -> [SnapshotCalendarDay] {
  let cal = Calendar.current
  let now = date
  let year = cal.component(.year, from: now)
  let month = cal.component(.month, from: now)
  let todayDay = cal.component(.day, from: now)

  var comps = DateComponents(); comps.year = year; comps.month = month; comps.day = 1
  let firstDay = cal.date(from: comps)!
  let startOffset = cal.component(.weekday, from: firstDay) - 1 // Sun=1 → 0-based

  let lastDay: Int = {
    var c = DateComponents(); c.year = year; c.month = month + 1; c.day = 0
    return cal.component(.day, from: cal.date(from: c)!)
  }()

  return (0..<42).map { i in
    let dayIndex = i - startOffset + 1
    let inMonth = dayIndex >= 1 && dayIndex <= lastDay
    return SnapshotCalendarDay(
      day: inMonth ? dayIndex : 0,
      isInMonth: inMonth,
      isToday: inMonth && dayIndex == todayDay,
      taskCount: 0
    )
  }
}
