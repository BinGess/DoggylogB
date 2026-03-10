import SwiftUI
import WidgetKit

struct DoggyLogEntry: TimelineEntry {
  let date: Date
  let snapshot: DoggyLogSharedSnapshot?
}

struct DoggyLogProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoggyLogEntry {
    DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load())
  }

  func getSnapshot(in context: Context, completion: @escaping (DoggyLogEntry) -> Void) {
    completion(DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DoggyLogEntry>) -> Void) {
    let entry = DoggyLogEntry(date: Date(), snapshot: DoggyLogSharedSnapshotStore.load())
    let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
    completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
  }
}

struct DoggyLogSummaryWidget: Widget {
  let kind = "DoggyLogSummaryWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogProvider()) { entry in
      DoggyLogSummaryWidgetView(entry: entry)
    }
    .configurationDisplayName("DoggyLog")
    .description("Show today’s pet mood, next task, and countdown.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct DoggyLogSummaryWidgetView: View {
  let entry: DoggyLogEntry

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color.orange.opacity(0.9),
          Color(red: 0.38, green: 0.82, blue: 0.93).opacity(0.55),
          Color.black.opacity(0.92),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 10) {
        Text(entry.snapshot?.pet.name ?? "DoggyLog")
          .font(.headline)
        Text("待办 \(entry.snapshot?.today.pendingCount ?? 0) · 已完成 \(entry.snapshot?.today.completedCount ?? 0)")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.78))
        Text(entry.snapshot?.today.nextTaskTitle ?? "今天还没有下一项任务")
          .font(.body.weight(.semibold))
          .lineLimit(2)
        if let countdown = entry.snapshot?.countdown {
          Text("\(countdown.title) · 还有 \(countdown.daysRemaining) 天")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.72))
        }
        Spacer()
      }
      .foregroundColor(.white)
      .padding()
    }
  }
}
