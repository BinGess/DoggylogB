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
  static let appGroupIdentifier = "group.com.example.doggylog"
  static let snapshotKey = "doggylog.widget.snapshot"
  static let snapshotFileName = "doggylog_widget_snapshot.json"

  static func load() -> DoggyLogSharedSnapshot? {
    if let defaults = UserDefaults(suiteName: appGroupIdentifier),
       let json = defaults.string(forKey: snapshotKey),
       let data = json.data(using: .utf8) {
      return try? JSONDecoder().decode(DoggyLogSharedSnapshot.self, from: data)
    }

    if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
      .appendingPathComponent(snapshotFileName),
       let data = try? Data(contentsOf: url) {
      return try? JSONDecoder().decode(DoggyLogSharedSnapshot.self, from: data)
    }

    return nil
  }
}
