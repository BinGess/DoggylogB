import SwiftUI
import WidgetKit
#if os(macOS)
import AppKit
#endif

extension Color {
  init(hex: UInt32, opacity: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255.0,
      green: Double((hex >> 8) & 0xFF) / 255.0,
      blue: Double(hex & 0xFF) / 255.0,
      opacity: opacity
    )
  }
}

struct DoggyWidgetPalette {
  let cardColors: [Color]
  let cardBorder: Color
  let textPrimary: Color
  let textSecondary: Color
  let accentPrimary: Color
  let accentSecondary: Color
  let focusFill: Color
  let quietSymbol: Color
  let borderWidth: CGFloat
}

enum DoggyWidgetSkinTheme: String {
  case shibaJoy
  case goldenBloom
  case beagleBreeze
  case huskyFrost
  case samoyedSpa

  static func resolve(from snapshot: DoggyLogSharedSnapshot?) -> DoggyWidgetSkinTheme {
    DoggyWidgetSkinTheme(rawValue: snapshot?.pet.skinTheme ?? "") ?? .shibaJoy
  }

  var dogImageName: String {
    switch self {
    case .shibaJoy, .goldenBloom:
      return "calendar_dog_timeline"
    case .beagleBreeze:
      return "calendar_dog1_timeline"
    case .huskyFrost:
      return "calendar_dog2_timeline"
    case .samoyedSpa:
      return "calendar_dog3_timeline"
    }
  }

  var companionScale: CGFloat {
    switch self {
    case .shibaJoy, .goldenBloom:
      return 1.0
    case .beagleBreeze:
      return 1.06
    case .huskyFrost:
      return 0.94
    case .samoyedSpa:
      return 0.92
    }
  }

  var companionYOffset: CGFloat {
    switch self {
    case .shibaJoy, .goldenBloom:
      return 0
    case .beagleBreeze:
      return -1
    case .huskyFrost:
      return 1
    case .samoyedSpa:
      return -2
    }
  }

  func palette(for colorScheme: ColorScheme) -> DoggyWidgetPalette {
    switch (self, colorScheme) {
    case (.shibaJoy, .light):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0xFFFFFE), Color(hex: 0xFFFBF4F1), Color(hex: 0xFFFFF0EC)],
        cardBorder: Color(hex: 0xF9CCA9),
        textPrimary: Color(hex: 0x3D1010),
        textSecondary: Color(hex: 0xC04040),
        accentPrimary: Color(hex: 0xF05D56),
        accentSecondary: Color(hex: 0x3DBA89),
        focusFill: Color(hex: 0xF05D56, opacity: 0.16),
        quietSymbol: Color(hex: 0x3D1010, opacity: 0.08),
        borderWidth: 1.2
      )
    case (.shibaJoy, .dark):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0x2F1818), Color(hex: 0x251010), Color(hex: 0x3A2020)],
        cardBorder: Color(hex: 0x703020),
        textPrimary: Color(hex: 0xFFE8E7),
        textSecondary: Color(hex: 0xF0A5A0),
        accentPrimary: Color(hex: 0xFF8A85),
        accentSecondary: Color(hex: 0x5FDDAA),
        focusFill: Color(hex: 0xFF8A85, opacity: 0.22),
        quietSymbol: Color(hex: 0xFFE8E7, opacity: 0.10),
        borderWidth: 1.2
      )
    case (.goldenBloom, .light):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0xFFFEFF), Color(hex: 0xFFF4F8FF), Color(hex: 0xFFEAF2FF)],
        cardBorder: Color(hex: 0xC0D5FF),
        textPrimary: Color(hex: 0x0F1B3D),
        textSecondary: Color(hex: 0x3366BB),
        accentPrimary: Color(hex: 0x0066FF),
        accentSecondary: Color(hex: 0x0EA5E9),
        focusFill: Color(hex: 0x0066FF, opacity: 0.12),
        quietSymbol: Color(hex: 0x0F1B3D, opacity: 0.08),
        borderWidth: 1.0
      )
    case (.goldenBloom, .dark):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0x0F1F35), Color(hex: 0x0C1A2D), Color(hex: 0x142540)],
        cardBorder: Color(hex: 0x1E3050),
        textPrimary: Color(hex: 0xE2EDFF),
        textSecondary: Color(hex: 0x90C0F8),
        accentPrimary: Color(hex: 0x60A5FA),
        accentSecondary: Color(hex: 0x2DD4BF),
        focusFill: Color(hex: 0x60A5FA, opacity: 0.20),
        quietSymbol: Color(hex: 0xE2EDFF, opacity: 0.10),
        borderWidth: 1.0
      )
    case (.beagleBreeze, .light):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0xFFFFFFFF), Color(hex: 0xFFF7F4FF), Color(hex: 0xFFF2F3FA)],
        cardBorder: Color(hex: 0xE0E0F0),
        textPrimary: Color(hex: 0x111827),
        textSecondary: Color(hex: 0x4B50D0),
        accentPrimary: Color(hex: 0x6366F1),
        accentSecondary: Color(hex: 0x059669),
        focusFill: Color(hex: 0x6366F1, opacity: 0.12),
        quietSymbol: Color(hex: 0x111827, opacity: 0.08),
        borderWidth: 1.0
      )
    case (.beagleBreeze, .dark):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0x181828), Color(hex: 0x14142A), Color(hex: 0x1E1E32)],
        cardBorder: Color(hex: 0x2A2A3A),
        textPrimary: Color(hex: 0xF9FAFB),
        textSecondary: Color(hex: 0x9BA5F8),
        accentPrimary: Color(hex: 0x818CF8),
        accentSecondary: Color(hex: 0x34D399),
        focusFill: Color(hex: 0x818CF8, opacity: 0.20),
        quietSymbol: Color(hex: 0xF9FAFB, opacity: 0.10),
        borderWidth: 1.0
      )
    case (.huskyFrost, .light):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0xFFFCFEFF), Color(hex: 0xFFEFF4F8), Color(hex: 0xFFE7EEF6)],
        cardBorder: Color(hex: 0xB8D0E8),
        textPrimary: Color(hex: 0x1A3651),
        textSecondary: Color(hex: 0x356890),
        accentPrimary: Color(hex: 0x4A90D9),
        accentSecondary: Color(hex: 0x4E9E7E),
        focusFill: Color(hex: 0x4A90D9, opacity: 0.14),
        quietSymbol: Color(hex: 0x1A3651, opacity: 0.08),
        borderWidth: 1.0
      )
    case (.huskyFrost, .dark):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0x1E2E3E), Color(hex: 0x182838), Color(hex: 0x243240)],
        cardBorder: Color(hex: 0x243850),
        textPrimary: Color(hex: 0xD0E8F5),
        textSecondary: Color(hex: 0x88C0E0),
        accentPrimary: Color(hex: 0x7BB8E8),
        accentSecondary: Color(hex: 0x6EC8A0),
        focusFill: Color(hex: 0x7BB8E8, opacity: 0.20),
        quietSymbol: Color(hex: 0xD0E8F5, opacity: 0.10),
        borderWidth: 1.0
      )
    case (.samoyedSpa, .light):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0xFFFFFFFF), Color(hex: 0xFFFEF5F8), Color(hex: 0xFFFCEEF4)],
        cardBorder: Color(hex: 0xF0C0CC),
        textPrimary: Color(hex: 0x5C1832),
        textSecondary: Color(hex: 0xAA4060),
        accentPrimary: Color(hex: 0xC96480),
        accentSecondary: Color(hex: 0x9B7BBF),
        focusFill: Color(hex: 0xC96480, opacity: 0.14),
        quietSymbol: Color(hex: 0x5C1832, opacity: 0.08),
        borderWidth: 1.0
      )
    case (.samoyedSpa, .dark):
      return DoggyWidgetPalette(
        cardColors: [Color(hex: 0x2F1820), Color(hex: 0x261219), Color(hex: 0x381F2A)],
        cardBorder: Color(hex: 0x5A2535),
        textPrimary: Color(hex: 0xFFE0E8),
        textSecondary: Color(hex: 0xECA0B5),
        accentPrimary: Color(hex: 0xF0A0B4),
        accentSecondary: Color(hex: 0xC4A8E8),
        focusFill: Color(hex: 0xF0A0B4, opacity: 0.22),
        quietSymbol: Color(hex: 0xFFE0E8, opacity: 0.10),
        borderWidth: 1.0
      )
    @unknown default:
      return DoggyWidgetSkinTheme.shibaJoy.palette(for: .light)
    }
  }
}

struct DoggyWidgetTheme {
  let palette: DoggyWidgetPalette
  let dogImageName: String
  let companionScale: CGFloat
  let companionYOffset: CGFloat

  static func resolve(
    snapshot: DoggyLogSharedSnapshot?,
    colorScheme: ColorScheme
  ) -> DoggyWidgetTheme {
    let skinTheme = DoggyWidgetSkinTheme.resolve(from: snapshot)
    return DoggyWidgetTheme(
      palette: skinTheme.palette(for: colorScheme),
      dogImageName: skinTheme.dogImageName,
      companionScale: skinTheme.companionScale,
      companionYOffset: skinTheme.companionYOffset
    )
  }
}

enum DoggyWidgetTypography {
  static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    .system(size: size, weight: weight)
  }
}

enum DoggyWidgetSpacing {
  static let edgeSmall: CGFloat = 12
  static let edgeMedium: CGFloat = 14
  static let stackTight: CGFloat = 6
  static let stackRegular: CGFloat = 8
}

struct DoggyWidgetCardBackground: View {
  let theme: DoggyWidgetTheme
  let cornerRadius: CGFloat

  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      .fill(
        LinearGradient(
          colors: theme.palette.cardColors,
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(
            theme.palette.cardBorder.opacity(0.72),
            lineWidth: theme.palette.borderWidth
          )
      )
  }
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

struct DoggyLogCalendarProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoggyLogEntry {
    DoggyLogEntry(date: Date(), snapshot: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (DoggyLogEntry) -> Void) {
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

struct DoggyLogLargeCalendarWidget: Widget {
  let kind = "DoggyLogLargeCalendarWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogLargeCalendarView(entry: entry)
    }
    .configurationDisplayName(widgetText("日历（大）", "Calendar (Large)", "カレンダー（大）"))
    .description(widgetText("查看本月完整日历，带宠物标记和任务提示。", "See the full month with pup marks and task hints.", "今月のカレンダーを、わんこマークと予定ヒントつきで表示します。"))
    .supportedFamilies([.systemLarge])
  }
}

struct DoggyLogMediumCalendarWidget: Widget {
  let kind = "DoggyLogMediumCalendarWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogMediumCalendarView(entry: entry)
    }
    .configurationDisplayName(widgetText("日历（周）", "Calendar (Week)", "カレンダー（週）"))
    .description(widgetText("显示本周日历，爪印标记有任务的日期。", "See this week's dates with paw marks on busy days.", "今週の日付を、予定のある日に肉球マークつきで表示します。"))
    .supportedFamilies([.systemMedium])
  }
}

struct DoggyLogLargeCalendarView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  private let weekdayLabels = [
    widgetText("日", "S", "日"),
    widgetText("一", "M", "月"),
    widgetText("二", "T", "火"),
    widgetText("三", "W", "水"),
    widgetText("四", "T", "木"),
    widgetText("五", "F", "金"),
    widgetText("六", "S", "土")
  ]
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)
    let monthLabel = _timelineMonthLabel(for: entry.date)
    let days = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let focusIndex = _focusDayIndex(in: days)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        Text(monthLabel)
          .font(DoggyWidgetTypography.font(size: 26, weight: .regular))
          .foregroundColor(theme.palette.textPrimary)
        Spacer()
      }
      .padding(.horizontal, 18)
      .padding(.top, DoggyWidgetSpacing.edgeMedium)
      .padding(.bottom, DoggyWidgetSpacing.stackRegular)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(DoggyWidgetTypography.font(size: 11, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.9))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, DoggyWidgetSpacing.stackTight)

      LazyVGrid(columns: columns, spacing: 3) {
        ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
          _LargeCalendarDayCell(
            day: day,
            isFocus: idx == focusIndex,
            showPetOnToday: true,
            theme: theme
          )
        }
      }
      .padding(.horizontal, 12)

      Spacer(minLength: 2)

      HStack(alignment: .bottom, spacing: 0) {
        VStack(alignment: .leading, spacing: 4) {
          Text(widgetText("本月节奏", "This month's rhythm", "今月のリズム"))
            .font(DoggyWidgetTypography.font(size: 9, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.76))

          HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
              Image(systemName: "pawprint.fill")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(
                  index == 2
                    ? theme.palette.accentPrimary.opacity(0.32)
                    : theme.palette.quietSymbol
                )
            }
          }
        }

        Spacer()

        _DogCompanionView(theme: theme, baseScale: 0.70, yOffsetAdjustment: -4)
          .frame(width: 48, height: 48)
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 10)
    }
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 30)
    }
    .widgetURL(URL(string: "doggylog://tab/calendar"))
  }
}

struct DoggyLogMediumCalendarView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  private let weekdayLabels = [
    widgetText("日", "S", "日"),
    widgetText("一", "M", "月"),
    widgetText("二", "T", "火"),
    widgetText("三", "W", "水"),
    widgetText("四", "T", "木"),
    widgetText("五", "F", "金"),
    widgetText("六", "S", "土")
  ]

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)
    let monthLabel = _timelineMonthLabel(for: entry.date)
    let allDays = snapshot?.calendarDays ?? _placeholderDays(for: entry.date)
    let weekDays = _currentWeekDays(from: allDays, now: entry.date)
    let focusIndex = _focusDayIndex(in: weekDays)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center) {
        Text(monthLabel)
          .font(DoggyWidgetTypography.font(size: 24, weight: .medium))
          .foregroundColor(theme.palette.textPrimary)
        Spacer()
      }
      .padding(.horizontal, DoggyWidgetSpacing.edgeSmall)
      .padding(.top, DoggyWidgetSpacing.edgeSmall)
      .padding(.bottom, DoggyWidgetSpacing.stackRegular)

      HStack(spacing: 0) {
        ForEach(weekdayLabels, id: \.self) { label in
          Text(label)
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.95))
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, DoggyWidgetSpacing.edgeSmall)
      .padding(.bottom, DoggyWidgetSpacing.stackTight)

      HStack(spacing: 0) {
        ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
          VStack(spacing: 4) {
            Text(day.isInMonth ? "\(day.day)" : "")
              .font(DoggyWidgetTypography.font(size: 17, weight: index == focusIndex ? .medium : .regular))
              .foregroundColor(
                index == focusIndex
                  ? theme.palette.textPrimary
                  : day.isInMonth
                    ? theme.palette.textSecondary.opacity(0.72)
                    : theme.palette.textPrimary.opacity(0.18)
              )
              .frame(width: 30, height: 24)
              .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                  .fill(
                    index == focusIndex
                      ? theme.palette.focusFill.opacity(0.9)
                      : Color.clear
                  )
              )

            Circle()
              .fill(
                day.taskCount > 0
                  ? (index == focusIndex
                    ? theme.palette.accentPrimary.opacity(0.72)
                    : theme.palette.accentSecondary.opacity(0.8))
                  : Color.clear
              )
              .frame(width: 4, height: 4)
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, DoggyWidgetSpacing.edgeSmall)
      .padding(.top, 2)

      Spacer(minLength: 4)

      ZStack(alignment: .bottomLeading) {
        GeometryReader { geo in
          let dayWidth = geo.size.width / CGFloat(max(weekDays.count, 1))
          let dogX = dayWidth * (CGFloat(focusIndex) + 0.5)
          let focusBandWidth = max(dayWidth - 12, 30)

          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(theme.palette.focusFill.opacity(0.82))
            .overlay(
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.palette.cardBorder.opacity(0.6), lineWidth: 1)
            )
            .frame(width: focusBandWidth, height: 56)
            .position(x: dogX, y: 36)
        }

        HStack(spacing: 0) {
          ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
            VStack(spacing: 5) {
              Image(systemName: "pawprint.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(
                  index == focusIndex
                    ? theme.palette.textPrimary.opacity(0.14)
                    : day.taskCount > 0
                      ? theme.palette.accentPrimary.opacity(0.34)
                      : theme.palette.quietSymbol
                )

              Circle()
                .fill(
                  day.taskCount > 0
                    ? theme.palette.accentSecondary.opacity(index == focusIndex ? 0.0 : 0.82)
                    : Color.clear
                )
                .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
          }
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 6)

        GeometryReader { geo in
          let dayWidth = geo.size.width / CGFloat(max(weekDays.count, 1))
          let dogX = dayWidth * (CGFloat(focusIndex) + 0.5)

          _DogCompanionView(theme: theme)
            .frame(width: 48, height: 48)
            .position(x: dogX, y: 36)
        }
      }
      .frame(height: 70)
      .padding(.horizontal, DoggyWidgetSpacing.edgeSmall)
      .padding(.bottom, DoggyWidgetSpacing.stackRegular)
    }
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 28)
    }
    .widgetURL(URL(string: "doggylog://tab/calendar"))
  }
}

private struct _LargeCalendarDayCell: View {
  let day: SnapshotCalendarDay
  let isFocus: Bool
  let showPetOnToday: Bool
  let theme: DoggyWidgetTheme

  var body: some View {
    VStack(spacing: 3) {
      ZStack {
        if isFocus {
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(theme.palette.focusFill)
            .frame(width: 30, height: 30)
        } else if day.isToday {
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(theme.palette.accentPrimary.opacity(0.92))
            .frame(width: 27, height: 27)
        }

        Text(day.isInMonth ? "\(day.day)" : "")
          .font(DoggyWidgetTypography.font(size: 13, weight: isFocus ? .medium : .regular))
          .foregroundColor(
            day.isToday
              ? .white
              : day.isInMonth
                ? theme.palette.textPrimary.opacity(isFocus ? 0.95 : 0.68)
                : theme.palette.textPrimary.opacity(0.18)
          )
          .offset(y: day.isToday ? 2 : 0)
      }
      .frame(width: 32, height: 32)
      .overlay(
        Group {
          if day.isToday && showPetOnToday {
            Image(systemName: "pawprint.fill")
              .font(.system(size: 9, weight: .medium))
              .foregroundColor(theme.palette.textPrimary.opacity(0.8))
              .offset(y: -15)
          }
        },
        alignment: .top
      )

      Circle()
        .fill(
          day.taskCount > 0 && !day.isToday
            ? theme.palette.accentSecondary.opacity(0.82)
            : Color.clear
        )
        .frame(width: 3.5, height: 3.5)
    }
    .frame(height: 40)
  }
}

struct _DogCompanionView: View {
  let theme: DoggyWidgetTheme
  var baseScale: CGFloat = 1
  var yOffsetAdjustment: CGFloat = 0

  var body: some View {
    doggyWidgetCompanionImage(named: theme.dogImageName)
      .resizable()
      .scaledToFit()
      .scaleEffect(theme.companionScale * baseScale)
      .offset(y: theme.companionYOffset + yOffsetAdjustment)
  }
}

private func doggyWidgetCompanionImage(named name: String) -> Image {
  #if os(macOS)
  if let image = NSImage(named: name) {
    return Image(nsImage: image)
  }

  let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("ios/DoggyLogWidgets/Assets.xcassets/\(name).imageset/\(name).png")
  if let image = NSImage(contentsOf: fileURL) {
    return Image(nsImage: image)
  }
  return Image(systemName: "pawprint.fill")
  #else
  return Image(name)
  #endif
}

private func _timelineMonthLabel(for date: Date) -> String {
  widgetMonthLabel(for: date)
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

private func _currentWeekDays(
  from days: [SnapshotCalendarDay],
  now: Date
) -> [SnapshotCalendarDay] {
  let todayIdx = days.firstIndex(where: { $0.isToday }) ?? 0
  let weekStart = (todayIdx / 7) * 7
  let range = weekStart..<min(weekStart + 7, days.count)
  let slice = Array(days[range])
  if slice.count < 7 {
    let pad = Array(
      repeating: SnapshotCalendarDay(day: 0, isInMonth: false, isToday: false, taskCount: 0),
      count: 7 - slice.count
    )
    return slice + pad
  }
  return slice
}

private func _placeholderDays(for date: Date) -> [SnapshotCalendarDay] {
  let cal = Calendar.current
  let year = cal.component(.year, from: date)
  let month = cal.component(.month, from: date)
  let todayDay = cal.component(.day, from: date)

  var comps = DateComponents()
  comps.year = year
  comps.month = month
  comps.day = 1
  guard let firstDay = cal.date(from: comps) else { return [] }
  let startOffset = cal.component(.weekday, from: firstDay) - 1

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
