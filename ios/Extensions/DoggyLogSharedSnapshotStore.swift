import Foundation

struct DoggyLogSharedSnapshot: Decodable {
  let generatedAt: Int
  let today: SnapshotToday
  let pet: SnapshotPet
  let countdown: SnapshotCountdown?
  let recentTasks: [SnapshotTask]
  let calendarDays: [SnapshotCalendarDay]
}

struct SnapshotToday: Decodable {
  let pendingCount: Int
  let completedCount: Int
  let nextTaskTitle: String?
  let nextTaskTime: String?
}

struct SnapshotPet: Decodable {
  let name: String
  let breed: String
  let mood: String
  let loyaltyLevel: Int
  let sceneMode: String
  let skinTheme: String?
}

struct SnapshotCountdown: Decodable {
  let title: String
  let dueAt: Int
  let daysRemaining: Int
  let startAt: Int
}

struct SnapshotTask: Decodable {
  let title: String
  let time: String
  let category: String
  let completed: Bool
}

/// 月历格子：42 项（6周 × 7列，周日起始）
struct SnapshotCalendarDay: Decodable {
  let day: Int          // 日期数字 1-31；非当月填充格为 0
  let isInMonth: Bool
  let isToday: Bool
  let taskCount: Int
}

enum DoggyLogSharedSnapshotStore {
  static let appGroupIdentifier = "group.com.timmy.doggylog"
  static let snapshotKey = "doggylog.widget.snapshot"
  static let snapshotFileName = "doggylog_widget_snapshot.json"

  static func load() -> DoggyLogSharedSnapshot? {
    // Read exclusively from the shared file.
    // Intentionally avoids UserDefaults(suiteName:): on fresh installs the
    // cfprefsd daemon rejects app-extension access with a "detaching" warning
    // that can block the call long enough to time out getSnapshot/getTimeline,
    // which causes WidgetKit to keep the widget stuck in gray-placeholder mode.
    guard let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupIdentifier
    ) else { return nil }

    let fileURL = containerURL.appendingPathComponent(snapshotFileName)
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    return try? JSONDecoder().decode(DoggyLogSharedSnapshot.self, from: data)
  }

  /// Returns hardcoded sample data for the widget gallery preview.
  /// Called when `context.isPreview == true` in `getSnapshot`.
  static func preview() -> DoggyLogSharedSnapshot? {
    let cal = Calendar.current
    let now = Date()
    let year = cal.component(.year, from: now)
    let month = cal.component(.month, from: now)
    let today = cal.component(.day, from: now)

    var comps = DateComponents()
    comps.year = year; comps.month = month; comps.day = 1
    guard let firstDay = cal.date(from: comps) else { return nil }
    let startOffset = cal.component(.weekday, from: firstDay) - 1
    guard let dayRange = cal.range(of: .day, in: .month, for: firstDay) else { return nil }
    let lastDay = dayRange.count

    let taskDays: Set<Int> = [3, 7, 12, 15, 20, 22, 25]
    let calendarDays: [SnapshotCalendarDay] = (0..<42).map { i in
      let dayIndex = i - startOffset + 1
      let inMonth = dayIndex >= 1 && dayIndex <= lastDay
      return SnapshotCalendarDay(
        day: inMonth ? dayIndex : 0,
        isInMonth: inMonth,
        isToday: inMonth && dayIndex == today,
        taskCount: inMonth && taskDays.contains(dayIndex) ? 2 : 0
      )
    }

    return DoggyLogSharedSnapshot(
      generatedAt: Int(now.timeIntervalSince1970 * 1000),
      today: SnapshotToday(
        pendingCount: 3,
        completedCount: 2,
        nextTaskTitle: widgetText("下午遛狗", "Afternoon walk", "午後のおさんぽ"),
        nextTaskTime: "15:00"
      ),
      pet: SnapshotPet(
        name: widgetText("小白", "Mochi", "Mochi"),
        breed: "shiba",
        mood: "excited",
        loyaltyLevel: 7,
        sceneMode: "walking",
        skinTheme: "shibaJoy"
      ),
      countdown: SnapshotCountdown(
        title: widgetText("狗狗生日", "Pup birthday", "わんこの誕生日"),
        dueAt: Int(now.addingTimeInterval(12 * 86400).timeIntervalSince1970 * 1000),
        daysRemaining: 12,
        startAt: Int(now.addingTimeInterval(-30 * 86400).timeIntervalSince1970 * 1000)
      ),
      recentTasks: [
        SnapshotTask(title: widgetText("晨跑 30 分钟", "Morning stretch", "朝のストレッチ"), time: "07:00", category: "exercise", completed: true),
        SnapshotTask(title: widgetText("宠物检查", "Vet check", "病院チェック"), time: "10:00", category: "vet", completed: true),
        SnapshotTask(title: widgetText("下午遛狗", "Afternoon walk", "午後のおさんぽ"), time: "15:00", category: "walk", completed: false)
      ],
      calendarDays: calendarDays
    )
  }
}
