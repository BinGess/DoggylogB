import SwiftUI
import WidgetKit

// MARK: - Shared colour palette (mirrors Flutter app theme)

extension Color {
  static let doggyTeal       = Color(red: 0.184, green: 0.561, blue: 0.541) // #2F8F8A
  static let doggyTealLight  = Color(red: 0.447, green: 0.788, blue: 0.757) // #72C9C1
  static let doggyBg         = Color(red: 0.965, green: 0.976, blue: 0.988) // #F6F9FC
  static let doggyWarmCard   = Color(red: 0.975, green: 0.971, blue: 0.957)
  static let doggyWarmTint   = Color(red: 0.84, green: 0.68, blue: 0.58)
  static let doggyInk        = Color(red: 0.11, green: 0.10, blue: 0.10)
}

extension View {
  @ViewBuilder
  func doggyWidgetBackground<Background: View>(
    @ViewBuilder _ backgroundView: () -> Background
  ) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) {
        backgroundView()
      }
    } else {
      background(backgroundView())
    }
  }
}

// MARK: - Shared timeline provider (reads the same shared snapshot)

struct DoggyLogCalendarProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoggyLogEntry {
    // Return immediately; placeholder is always shown fully redacted by WidgetKit
    // so actual data is irrelevant — and calling load() here can cause I/O delays.
    DoggyLogEntry(date: Date(), snapshot: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (DoggyLogEntry) -> Void) {
    // Always prefer real data; fall back to preview sample so the widget gallery
    // never gets stuck showing the grey redacted placeholder (which happens when
    // both load() and preview() return nil, or when context.isPreview is
    // unexpectedly false on some iOS versions).
    let snapshot = DoggyLogSharedSnapshotStore.load()
      ?? DoggyLogSharedSnapshotStore.preview()
    completion(DoggyLogEntry(date: Date(), snapshot: snapshot))
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
    let monthLabel = _timelineMonthLabel(for: entry.date)
    let petName = snapshot?.pet.name ?? "DoggyLog"
    let days = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let focusIndex = _focusDayIndex(in: days)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        Text(monthLabel)
          .font(.system(size: 26, weight: .regular, design: .rounded))
          .foregroundColor(.doggyInk)
        Spacer()
        VStack(alignment: .trailing, spacing: 3) {
          Text(petName)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.52))
          Text("陪你过今天")
            .font(.system(size: 10, weight: .regular, design: .rounded))
            .foregroundColor(.doggyWarmTint.opacity(0.90))
        }
      }
      .padding(.horizontal, 18)
      .padding(.top, 16)
      .padding(.bottom, 12)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.80))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 8)

      LazyVGrid(columns: columns, spacing: 4) {
        ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
          _LargeCalendarDayCell(
            day: day,
            isFocus: idx == focusIndex,
            showPetOnToday: true
          )
        }
      }
      .padding(.horizontal, 12)

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 0) {
        VStack(alignment: .leading, spacing: 6) {
          Text("本月节奏")
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.46))

          HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
              Image(systemName: "pawprint.fill")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(
                  index == 2
                    ? .doggyWarmTint.opacity(0.40)
                    : .doggyInk.opacity(0.08)
                )
            }
          }
        }

        Spacer()

        _DogCompanionView()
          .frame(width: 76, height: 76)
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 14)
    }
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://tab/calendar"))
  }
}

// MARK: - Medium Calendar View

struct DoggyLogMediumCalendarView: View {
  let entry: DoggyLogEntry

  private let weekdayLabels = ["日", "一", "二", "三", "四", "五", "六"]

  var body: some View {
    let snapshot = entry.snapshot
    let monthLabel = _timelineMonthLabel(for: entry.date)
    let allDays = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let weekDays = _currentWeekDays(from: allDays, now: entry.date)
    let focusIndex = _focusDayIndex(in: weekDays)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center) {
        Text(monthLabel)
          .font(.system(size: 22, weight: .regular, design: .rounded))
          .foregroundColor(.doggyInk)
        Spacer()
      }
      .padding(.horizontal, 18)
      .padding(.top, 14)
      .padding(.bottom, 12)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.88))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 8)

      HStack(spacing: 0) {
        ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
          VStack(spacing: 0) {
            Text(day.isInMonth ? "\(day.day)" : "")
              .font(.system(size: 15, weight: index == focusIndex ? .semibold : .regular, design: .rounded))
              .foregroundColor(
                index == focusIndex
                  ? .doggyInk
                  : day.isInMonth
                    ? .doggyInk.opacity(0.55)
                    : .doggyInk.opacity(0.18)
              )
              .frame(height: 22)
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 18)

      Spacer(minLength: 8)

      ZStack(alignment: .bottomLeading) {
        HStack(spacing: 0) {
          ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
            VStack(spacing: 5) {
              Image(systemName: "pawprint.fill")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(
                  index == focusIndex
                    ? .doggyInk.opacity(0.10)
                    : day.taskCount > 0
                      ? .doggyWarmTint.opacity(0.30)
                      : .doggyInk.opacity(0.07)
                )

              Circle()
                .fill(
                  day.taskCount > 0
                    ? Color.doggyTeal.opacity(index == focusIndex ? 0.0 : 0.70)
                    : Color.clear
                )
                .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
          }
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 4)

        GeometryReader { geo in
          let dayWidth = geo.size.width / CGFloat(max(weekDays.count, 1))
          let dogX = dayWidth * (CGFloat(focusIndex) + 0.5)

          _DogCompanionView()
            .frame(width: 56, height: 56)
            .position(x: dogX, y: 26)
        }
      }
      .frame(height: 80)
      .padding(.horizontal, 18)
      .padding(.bottom, 12)
    }
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
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
        if day.isToday {
          Circle()
            .fill(Color.doggyTeal)
            .frame(width: 26, height: 26)
        }
        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 12, weight: .regular, design: .rounded))
          .foregroundColor(
            day.isToday
              ? Color.white
              : day.isInMonth
                ? Color.primary
                : Color.secondary.opacity(0.25)
          )
      }
      .frame(width: 26, height: 26)
      .overlay(
        Group {
          if day.isToday && showPetOnToday {
            Image(systemName: "pawprint.fill")
              .font(.system(size: 8, weight: .medium))
              .foregroundColor(.doggyInk.opacity(0.70))
              .offset(y: -14)
          }
        },
        alignment: .top
      )

      Circle()
        .fill(day.taskCount > 0 && !day.isToday ? Color.doggyTeal.opacity(0.75) : Color.clear)
        .frame(width: 3.5, height: 3.5)
    }
    .frame(height: 40)
  }
}

private struct _LargeCalendarDayCell: View {
  let day: SnapshotCalendarDay
  let isFocus: Bool
  let showPetOnToday: Bool

  var body: some View {
    VStack(spacing: 4) {
      ZStack {
        if isFocus {
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.doggyWarmTint.opacity(0.18))
            .frame(width: 30, height: 30)
        } else if day.isToday {
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.doggyTeal.opacity(0.88))
            .frame(width: 27, height: 27)
        }

        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 13, weight: isFocus ? .semibold : .regular, design: .rounded))
          .foregroundColor(
            day.isToday
              ? .white
              : day.isInMonth
                ? .doggyInk.opacity(isFocus ? 0.95 : 0.60)
                : .doggyInk.opacity(0.18)
          )
      }
      .frame(width: 32, height: 32)
      .overlay(
        Group {
          if day.isToday && showPetOnToday {
            Image(systemName: "pawprint.fill")
              .font(.system(size: 9, weight: .medium))
              .foregroundColor(.doggyInk.opacity(0.85))
              .offset(y: -15)
          }
        },
        alignment: .top
      )

      Circle()
        .fill(day.taskCount > 0 && !day.isToday ? Color.doggyTeal.opacity(0.72) : Color.clear)
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
      ZStack {
        if day.isToday {
          Circle()
            .fill(Color.doggyTeal)
            .frame(width: 24, height: 24)
        }
        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 13, weight: .regular, design: .rounded))
          .foregroundColor(
            day.isToday
              ? Color.white
              : day.isInMonth
                ? Color.primary
                : Color.secondary.opacity(0.3)
          )
      }
      .frame(width: 24, height: 24)

      Group {
        if day.isToday {
          Image(systemName: "pawprint.fill")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.doggyTeal.opacity(0.9))
        } else {
          Image(systemName: day.taskCount > 0 ? "pawprint.fill" : "pawprint")
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(
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

// MARK: - Dog Companion (real image)

struct _DogCompanionView: View {
  var body: some View {
    Image("calendar_dog_timeline")
      .resizable()
      .scaledToFit()
  }
}

// MARK: - Helpers

private func _monthLabel(for date: Date) -> String {
  let cal = Calendar.current
  let year = cal.component(.year, from: date)
  let month = cal.component(.month, from: date)
  return "\(month)月 \(year)"
}

private func _timelineMonthLabel(for date: Date) -> String {
  let cal = Calendar.current
  let year = cal.component(.year, from: date)
  let month = cal.component(.month, from: date)
  return String(format: "%04d 年 %02d 月", year, month)
}

private func _focusDayIndex(in days: [SnapshotCalendarDay]) -> Int {
  if let todayIndex = days.firstIndex(where: { $0.isToday }) {
    return todayIndex
  }
  if let taskIndex = days.firstIndex(where: { $0.taskCount > 0 }) {
    return taskIndex
  }
  return min(max(days.count / 2, 0), max(days.count - 1, 0))
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
  if slice.count < 7 {
    let pad = Array(repeating: SnapshotCalendarDay(
      day: 0, isInMonth: false, isToday: false, taskCount: 0
    ), count: 7 - slice.count)
    return slice + pad
  }
  return slice
}

/// 无 snapshot 时生成当月占位日历格（42 格，周日起始）
private func _placeholderDays(for date: Date) -> [SnapshotCalendarDay] {
  let cal = Calendar.current
  let year = cal.component(.year, from: date)
  let month = cal.component(.month, from: date)
  let todayDay = cal.component(.day, from: date)

  var comps = DateComponents()
  comps.year = year; comps.month = month; comps.day = 1
  guard let firstDay = cal.date(from: comps) else { return [] }
  let startOffset = cal.component(.weekday, from: firstDay) - 1 // Sun=1 → 0-based

  // cal.range(of:in:for:) safely returns days-in-month without force-unwrap
  guard let dayRange = cal.range(of: .day, in: .month, for: firstDay) else { return [] }
  let lastDay = dayRange.count

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
