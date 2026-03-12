import SwiftUI
import WidgetKit

struct DoggyLogEntry: TimelineEntry {
  let date: Date
  let snapshot: DoggyLogSharedSnapshot?
}

struct DoggyLogProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoggyLogEntry {
    // Return immediately; placeholder is always shown fully redacted by WidgetKit
    // so actual data is irrelevant — and calling load() here can cause I/O delays.
    DoggyLogEntry(date: Date(), snapshot: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (DoggyLogEntry) -> Void) {
    // Always prefer real data; fall back to preview sample so the widget gallery
    // never gets stuck showing the grey redacted placeholder.
    let snapshot = DoggyLogSharedSnapshotStore.load()
      ?? DoggyLogSharedSnapshotStore.preview()
    completion(DoggyLogEntry(date: Date(), snapshot: snapshot))
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
    .description(widgetText("看看今天的宠物状态、下一件事和倒计时。", "See today's pet vibe, next task, and countdown.", "今日のわんこ状態、次の予定、カウントダウンを表示します。"))
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct DoggyLogSummaryWidgetView: View {
  let entry: DoggyLogEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemSmall:
      DoggyLogSummarySmallView(entry: entry)
    case .systemLarge:
      DoggyLogSummaryLargeView(entry: entry)
    default:
      DoggyLogSummaryMediumView(entry: entry)
    }
  }
}

private struct DoggyLogSummarySmallView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let snapshot = entry.snapshot

    VStack(alignment: .leading, spacing: 0) {
      _SummaryHeader(snapshot: snapshot, subtitle: widgetText("今天", "Today", "きょう"))

      Spacer(minLength: 8)

      Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundColor(.doggyInk)
        .lineLimit(3)

      Text(_summaryMetaLine(snapshot: snapshot))
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundColor(.doggyInk.opacity(0.50))
        .padding(.top, 5)

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 0) {
        _SummaryStatPill(value: "\(snapshot?.today.pendingCount ?? 0)", label: widgetText("待办", "To do", "やること"))
        Spacer(minLength: 8)
        _DogCompanionView()
          .frame(width: 64, height: 64)
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 14)
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct DoggyLogSummaryMediumView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let snapshot = entry.snapshot

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        _SummaryHeader(snapshot: snapshot, subtitle: widgetText("今天", "Today", "きょう"))
        Spacer()
        VStack(alignment: .trailing, spacing: 3) {
          Text(widgetMoodLabel(snapshot?.pet.mood ?? "calm"))
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(.doggyWarmTint.opacity(0.95))

          Text(widgetText("陪你过好今天", "A soft little sidekick for today", "今日はやさしく付き添います"))
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.40))
        }
      }

      Spacer(minLength: 10)

      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 8) {
          _SummaryMetricTile(
            title: widgetText("待办", "To do", "やること"),
            value: "\(snapshot?.today.pendingCount ?? 0)",
            accent: .doggyWarmTint.opacity(0.92)
          )

          _SummaryMetricTile(
            title: widgetText("完成", "Done", "できた"),
            value: "\(snapshot?.today.completedCount ?? 0)",
            accent: .doggyTeal.opacity(0.92)
          )
        }
        .frame(width: 74)

        VStack(alignment: .leading, spacing: 7) {
          Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(.doggyInk)
            .lineLimit(2)

          if let time = snapshot?.today.nextTaskTime, !time.isEmpty {
            Text("\(widgetText("下一项", "Next up", "つぎ")) · \(time)")
              .font(.system(size: 10, weight: .medium, design: .rounded))
              .foregroundColor(.doggyWarmTint.opacity(0.92))
          }

          if let countdown = snapshot?.countdown {
            Text("\(countdown.title) · \(widgetText("还有", "", "あと")) \(widgetDaysLeftLabel(max(0, countdown.daysRemaining)))")
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundColor(.doggyInk.opacity(0.55))
              .lineLimit(1)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        _DogCompanionView()
          .frame(width: 70, height: 70)
      }

      Spacer(minLength: 8)

      HStack {
        _SummaryPawRhythmStrip(activeIndex: 1, count: 5)
        Spacer()
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 16)
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct DoggyLogSummaryLargeView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let snapshot = entry.snapshot
    let recentTasks = Array((snapshot?.recentTasks ?? []).prefix(3))

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        _SummaryHeader(snapshot: snapshot, subtitle: widgetText("今日小结", "Daily Summary", "今日のまとめ"))

        Spacer()

        VStack(alignment: .trailing, spacing: 5) {
          Text(widgetBreedLabel(snapshot?.pet.breed ?? widgetText("陪伴犬", "Companion", "相棒")))
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.42))

          Text(widgetMoodLabel(snapshot?.pet.mood ?? "excited"))
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.doggyWarmTint.opacity(0.95))
        }
      }

      Spacer(minLength: 12)

      HStack(alignment: .top, spacing: 10) {
        _SummaryMetricTile(
          title: widgetText("待办", "To do", "やること"),
          value: "\(snapshot?.today.pendingCount ?? 0)",
          accent: .doggyWarmTint.opacity(0.92)
        )

        _SummaryMetricTile(
          title: widgetText("完成", "Done", "できた"),
          value: "\(snapshot?.today.completedCount ?? 0)",
          accent: .doggyTeal.opacity(0.92)
        )

        VStack(alignment: .leading, spacing: 7) {
          Text(widgetText("下一项", "Next up", "つぎ"))
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.40))

          Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.doggyInk)
            .lineLimit(2)

          if let time = snapshot?.today.nextTaskTime, !time.isEmpty {
            Text(time)
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundColor(.doggyWarmTint.opacity(0.95))
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Spacer(minLength: 12)

      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 8) {
          Text(widgetText("今日节奏", "Today's rhythm", "きょうのリズム"))
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.40))

          if recentTasks.isEmpty {
            Text(widgetText("今天还没有记录任务，去 App 里安排一下吧。", "No tasks logged yet. Pop into the app and add one.", "まだ記録された予定はありません。アプリでひとつ入れてみましょう。"))
              .font(.system(size: 12, weight: .medium, design: .rounded))
              .foregroundColor(.doggyInk.opacity(0.54))
              .lineLimit(2)
          } else {
            ForEach(Array(recentTasks.enumerated()), id: \.offset) { index, task in
              HStack(spacing: 7) {
                Circle()
                  .fill(task.completed ? Color.doggyTeal.opacity(0.9) : Color.doggyWarmTint.opacity(0.85))
                  .frame(width: 6, height: 6)

                Text(task.title)
                  .font(.system(size: 12, weight: .medium, design: .rounded))
                  .foregroundColor(.doggyInk.opacity(0.80))
                  .lineLimit(1)

                Spacer(minLength: 4)

                Text(task.time)
                  .font(.system(size: 10, weight: .medium, design: .rounded))
                  .foregroundColor(.doggyInk.opacity(0.40))
              }
              .padding(.vertical, 2)
            }
          }

          if let countdown = snapshot?.countdown {
            Text("\(countdown.title) · \(widgetText("还有", "", "あと")) \(widgetDaysLeftLabel(max(0, countdown.daysRemaining)))")
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundColor(.doggyWarmTint.opacity(0.95))
              .padding(.top, 3)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .trailing, spacing: 10) {
          _DogCompanionView()
            .frame(width: 88, height: 88)

          _SummaryPawRhythmStrip(activeIndex: 2, count: 6)
        }
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 18)
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct _SummaryHeader: View {
  let snapshot: DoggyLogSharedSnapshot?
  let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(snapshot?.pet.name ?? "DoggyLog")
        .font(.system(size: 22, weight: .semibold, design: .rounded))
        .foregroundColor(.doggyInk)
        .lineLimit(1)

      Text(subtitle)
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundColor(.doggyWarmTint.opacity(0.92))
    }
  }
}

private struct _SummaryMetricTile: View {
  let title: String
  let value: String
  let accent: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundColor(.doggyInk.opacity(0.44))

      Text(value)
        .font(.system(size: 24, weight: .semibold, design: .rounded))
        .foregroundColor(.doggyInk)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 10)
    .padding(.vertical, 9)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(accent.opacity(0.13))
    )
  }
}

private struct _SummaryStatPill: View {
  let value: String
  let label: String

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundColor(.doggyInk)
      Text(label)
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundColor(.doggyInk.opacity(0.44))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 7)
    .background(
      Capsule(style: .continuous)
        .fill(Color.doggyWarmTint.opacity(0.13))
    )
  }
}

private struct _SummaryPawRhythmStrip: View {
  let activeIndex: Int
  let count: Int

  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<count, id: \.self) { index in
        Image(systemName: "pawprint.fill")
          .font(.system(size: 13, weight: .regular))
          .foregroundColor(
            index == activeIndex
              ? .doggyWarmTint.opacity(0.36)
              : .doggyInk.opacity(0.07)
          )
      }
    }
  }
}

private func _summaryMetaLine(snapshot: DoggyLogSharedSnapshot?) -> String {
  let pending = snapshot?.today.pendingCount ?? 0
  let completed = snapshot?.today.completedCount ?? 0
  if let time = snapshot?.today.nextTaskTime, !time.isEmpty {
    return "\(widgetText("待办", "To do", "やること")) \(pending) · \(widgetText("已完成", "Done", "できた")) \(completed) · \(time)"
  }
  return "\(widgetText("待办", "To do", "やること")) \(pending) · \(widgetText("已完成", "Done", "できた")) \(completed)"
}
