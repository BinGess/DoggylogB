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
    let monthLabel = _timelineMonthLabel(for: entry.date)
    let petName = snapshot?.pet.name ?? "DoggyLog"
    let days = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let focusIndex = _focusDayIndex(in: days)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        Text(monthLabel)
          .font(.system(size: 28, weight: .regular, design: .rounded))
          .foregroundColor(.doggyInk)
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          Text(petName)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.55))
          Text("陪你过今天")
            .font(.system(size: 10, weight: .regular, design: .rounded))
            .foregroundColor(.doggyWarmTint.opacity(0.95))
        }
      }
      .padding(.horizontal, 18)
      .padding(.top, 18)
      .padding(.bottom, 14)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.88))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 10)

      LazyVGrid(columns: columns, spacing: 2) {
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
        VStack(alignment: .leading, spacing: 8) {
          Text("本月节奏")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.5))

          HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
              Image(systemName: "pawprint.fill")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(
                  index == 2
                    ? .doggyWarmTint.opacity(0.38)
                    : .doggyInk.opacity(0.08)
                )
            }
          }
        }

        Spacer()

        _DogCompanionView()
          .frame(width: 96, height: 72)
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
          .font(.system(size: 24, weight: .regular, design: .rounded))
          .foregroundColor(.doggyInk)
        Spacer()
      }
      .padding(.horizontal, 18)
      .padding(.top, 16)
      .padding(.bottom, 14)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.92))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 10)

      HStack(spacing: 0) {
        ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
          VStack(spacing: 0) {
            Text(day.isInMonth ? "\(day.day)" : "")
              .font(.system(size: 16, weight: index == focusIndex ? .semibold : .regular, design: .rounded))
              .foregroundColor(
                index == focusIndex
                  ? .doggyInk
                  : day.isInMonth
                    ? .doggyInk.opacity(0.58)
                    : .doggyInk.opacity(0.18)
              )
              .frame(height: 24)
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 18)

      Spacer(minLength: 10)

      ZStack(alignment: .bottomLeading) {
        HStack(spacing: 0) {
          ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
            VStack(spacing: 6) {
              Image(systemName: "pawprint.fill")
                .font(.system(size: 23, weight: .regular))
                .foregroundColor(
                  index == focusIndex
                    ? .doggyInk.opacity(0.12)
                    : day.taskCount > 0
                      ? .doggyWarmTint.opacity(0.28)
                      : .doggyInk.opacity(0.08)
                )

              Circle()
                .fill(
                  day.taskCount > 0
                    ? Color.doggyTeal.opacity(index == focusIndex ? 0.0 : 0.70)
                    : Color.clear
                )
                .frame(width: 5, height: 5)
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
            .frame(width: 88, height: 66)
            .position(x: dogX, y: 28)
        }
      }
      .frame(height: 84)
      .padding(.horizontal, 18)
      .padding(.bottom, 14)
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
        // 今日：Teal 圆形背景
        if day.isToday {
          Circle()
            .fill(Color.doggyTeal)
            .frame(width: 26, height: 26)
        }
        // 日期数字
        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 12, weight: .regular))
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
            Text("🐾")
              .font(.system(size: 10))
              .offset(y: -14)
          }
        },
        alignment: .top
      )

      // 任务小圆点（非今日 & 有任务）
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
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.doggyWarmTint.opacity(0.18))
            .frame(width: 32, height: 32)
        } else if day.isToday {
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.doggyTeal.opacity(0.88))
            .frame(width: 28, height: 28)
        }

        Text(day.isInMonth ? "\(day.day)" : "")
          .font(.system(size: 14, weight: isFocus ? .semibold : .regular, design: .rounded))
          .foregroundColor(
            day.isToday
              ? .white
              : day.isInMonth
                ? .doggyInk.opacity(isFocus ? 0.95 : 0.62)
                : .doggyInk.opacity(0.18)
          )
      }
      .frame(width: 34, height: 34)
      .overlay(
        Group {
          if day.isToday && showPetOnToday {
            Image(systemName: "pawprint.fill")
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(.doggyInk.opacity(0.92))
              .offset(y: -16)
          }
        },
        alignment: .top
      )

      Circle()
        .fill(day.taskCount > 0 && !day.isToday ? Color.doggyTeal.opacity(0.72) : Color.clear)
        .frame(width: 4, height: 4)
    }
    .frame(height: 42)
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
          .foregroundColor(
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

struct _DogCompanionView: View {
  var body: some View {
    ZStack(alignment: .bottom) {
      Ellipse()
        .fill(Color.black.opacity(0.12))
        .frame(width: 48, height: 10)
        .offset(y: 6)

      ZStack(alignment: .topLeading) {
        _DogTailShape()
          .stroke(Color.doggyInk, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
          .frame(width: 20, height: 32)
          .offset(x: 8, y: 4)

        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.doggyInk)
          .frame(width: 44, height: 24)
          .offset(x: 18, y: 20)

        Capsule()
          .fill(Color.doggyTeal.opacity(0.9))
          .frame(width: 16, height: 5)
          .offset(x: 42, y: 31)

        Circle()
          .fill(Color.doggyInk)
          .frame(width: 25, height: 25)
          .offset(x: 48, y: 10)

        _DogEarShape(flip: false)
          .fill(Color.doggyInk)
          .frame(width: 10, height: 12)
          .offset(x: 50, y: 4)

        _DogEarShape(flip: true)
          .fill(Color.doggyInk)
          .frame(width: 10, height: 12)
          .offset(x: 62, y: 4)

        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color.doggyInk)
          .frame(width: 6, height: 16)
          .offset(x: 24, y: 40)

        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color.doggyInk)
          .frame(width: 6, height: 16)
          .offset(x: 39, y: 40)

        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color.doggyInk)
          .frame(width: 6, height: 16)
          .offset(x: 52, y: 40)

        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(Color.doggyInk)
          .frame(width: 6, height: 16)
          .offset(x: 63, y: 40)

        Circle()
          .fill(.white)
          .frame(width: 6, height: 6)
          .offset(x: 55, y: 19)

        Circle()
          .fill(.white)
          .frame(width: 6, height: 6)
          .offset(x: 66, y: 19)

        Circle()
          .fill(Color.black)
          .frame(width: 2.5, height: 2.5)
          .offset(x: 57, y: 21)

        Circle()
          .fill(Color.black)
          .frame(width: 2.5, height: 2.5)
          .offset(x: 68, y: 21)

        Capsule()
          .fill(Color.white.opacity(0.92))
          .frame(width: 10, height: 6)
          .offset(x: 60, y: 28)
      }
      .frame(width: 88, height: 60)
    }
  }
}

struct _DogEarShape: Shape {
  let flip: Bool

  func path(in rect: CGRect) -> Path {
    var path = Path()
    if flip {
      path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.35))
    } else {
      path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.35))
    }
    path.closeSubpath()
    return path
  }
}

struct _DogTailShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY))
    path.addCurve(
      to: CGPoint(x: rect.maxX * 0.35, y: rect.minY + 3),
      control1: CGPoint(x: rect.maxX * 0.25, y: rect.maxY * 0.65),
      control2: CGPoint(x: rect.maxX * 0.9, y: rect.maxY * 0.15)
    )
    return path
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
