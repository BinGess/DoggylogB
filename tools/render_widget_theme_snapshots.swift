import AppKit
import SwiftUI
import WidgetKit

@main
@MainActor
struct WidgetThemeSnapshotRenderer {
  static func main() throws {
    let outputDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent("tmp/widget-theme-renders", isDirectory: true)
    try FileManager.default.createDirectory(
      at: outputDirectory,
      withIntermediateDirectories: true
    )

    try renderSheet(
      name: "calendar-medium-light",
      outputDirectory: outputDirectory,
      colorScheme: .light
    ) { entry in
      DoggyLogMediumCalendarView(entry: entry)
        .frame(width: 329, height: 155)
    }

    try renderSheet(
      name: "summary-medium-light",
      outputDirectory: outputDirectory,
      colorScheme: .light
    ) { entry in
      doggyLogSummaryMediumPreview(entry: entry)
        .frame(width: 329, height: 155)
    }

    try renderSheet(
      name: "countdown-medium-light",
      outputDirectory: outputDirectory,
      colorScheme: .light
    ) { entry in
      doggyLogCountdownMediumPreview(entry: entry)
        .frame(width: 329, height: 155)
    }

    try renderSheet(
      name: "calendar-medium-dark",
      outputDirectory: outputDirectory,
      colorScheme: .dark
    ) { entry in
      DoggyLogMediumCalendarView(entry: entry)
        .frame(width: 329, height: 155)
    }

    try renderSheet(
      name: "summary-medium-dark",
      outputDirectory: outputDirectory,
      colorScheme: .dark
    ) { entry in
      doggyLogSummaryMediumPreview(entry: entry)
        .frame(width: 329, height: 155)
    }

    try renderSheet(
      name: "countdown-medium-dark",
      outputDirectory: outputDirectory,
      colorScheme: .dark
    ) { entry in
      doggyLogCountdownMediumPreview(entry: entry)
        .frame(width: 329, height: 155)
    }
  }

  static func renderSheet(
    name: String,
    outputDirectory: URL,
    colorScheme: ColorScheme,
    @ViewBuilder content: @escaping (DoggyLogEntry) -> some View
  ) throws {
    let themes: [(String, String, String)] = [
      ("shibaJoy", "Mochi", widgetText("柴犬", "Shiba Inu", "柴犬")),
      ("goldenBloom", "Sunny", widgetText("金毛", "Golden Retriever", "ゴールデンレトリバー")),
      ("beagleBreeze", "Pixel", widgetText("比格", "Beagle", "ビーグル")),
      ("huskyFrost", "Nova", widgetText("哈士奇", "Husky", "ハスキー")),
      ("samoyedSpa", "Cloud", widgetText("萨摩耶", "Samoyed", "サモエド")),
    ]

    let sheet = VStack(alignment: .leading, spacing: 18) {
      ForEach(themes, id: \.0) { theme in
        VStack(alignment: .leading, spacing: 8) {
          Text(theme.0)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.primary)

          content(makeEntry(theme: theme.0, petName: theme.1, breedLabel: theme.2))
            .environment(\.colorScheme, colorScheme)
            .padding(10)
            .background(colorScheme == .dark ? Color(hex: 0x111318) : Color(hex: 0xF1F3F6))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
      }
    }
    .padding(20)
    .frame(width: 380, alignment: .leading)
    .background(colorScheme == .dark ? Color(hex: 0x050608) : Color(hex: 0xE8EBF0))

    try save(
      view: sheet,
      to: outputDirectory.appendingPathComponent("\(name).png")
    )
  }

  static func makeEntry(theme: String, petName: String, breedLabel: String) -> DoggyLogEntry {
    let snapshot = DoggyLogSharedSnapshot(
      generatedAt: Int(Date().timeIntervalSince1970 * 1000),
      today: SnapshotToday(
        pendingCount: 3,
        completedCount: 2,
        nextTaskTitle: widgetText("下午遛狗", "Afternoon walk", "午後のおさんぽ"),
        nextTaskTime: "15:00"
      ),
      pet: SnapshotPet(
        name: petName,
        breed: breedLabel,
        mood: "excited",
        loyaltyLevel: 6,
        sceneMode: "walking",
        skinTheme: theme
      ),
      countdown: SnapshotCountdown(
        title: widgetText("狗狗生日", "Pup birthday", "わんこの誕生日"),
        dueAt: Int(Date().addingTimeInterval(12 * 86400).timeIntervalSince1970 * 1000),
        daysRemaining: 12,
        startAt: Int(Date().addingTimeInterval(-18 * 86400).timeIntervalSince1970 * 1000)
      ),
      recentTasks: [
        SnapshotTask(
          title: widgetText("晨跑 30 分钟", "Morning stretch", "朝のストレッチ"),
          time: "07:00",
          category: "exercise",
          completed: true
        ),
        SnapshotTask(
          title: widgetText("宠物检查", "Vet check", "病院チェック"),
          time: "10:00",
          category: "vet",
          completed: true
        ),
        SnapshotTask(
          title: widgetText("下午遛狗", "Afternoon walk", "午後のおさんぽ"),
          time: "15:00",
          category: "walk",
          completed: false
        ),
      ],
      calendarDays: makeCalendarDays()
    )

    return DoggyLogEntry(date: Date(), snapshot: snapshot)
  }

  static func makeCalendarDays() -> [SnapshotCalendarDay] {
    [
      SnapshotCalendarDay(day: 9, isInMonth: true, isToday: false, taskCount: 0),
      SnapshotCalendarDay(day: 10, isInMonth: true, isToday: false, taskCount: 1),
      SnapshotCalendarDay(day: 11, isInMonth: true, isToday: false, taskCount: 0),
      SnapshotCalendarDay(day: 12, isInMonth: true, isToday: true, taskCount: 2),
      SnapshotCalendarDay(day: 13, isInMonth: true, isToday: false, taskCount: 1),
      SnapshotCalendarDay(day: 14, isInMonth: true, isToday: false, taskCount: 0),
      SnapshotCalendarDay(day: 15, isInMonth: true, isToday: false, taskCount: 2),
    ] + Array(repeating: SnapshotCalendarDay(day: 0, isInMonth: false, isToday: false, taskCount: 0), count: 35)
  }

  static func save<V: View>(view: V, to url: URL) throws {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 2
    guard let nsImage = renderer.nsImage else {
      throw SnapshotRenderError.renderFailed
    }
    guard let tiffData = nsImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
      throw SnapshotRenderError.encodingFailed
    }
    try pngData.write(to: url)
  }
}

enum SnapshotRenderError: Error {
  case renderFailed
  case encodingFailed
}
