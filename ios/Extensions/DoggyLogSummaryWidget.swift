import SwiftUI
import WidgetKit

struct DoggyLogEntry: TimelineEntry {
  let date: Date
  let snapshot: DoggyLogSharedSnapshot?
}

struct DoggyLogProvider: TimelineProvider {
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

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)

    VStack(alignment: .leading, spacing: 0) {
      _SummaryHeader(
        snapshot: snapshot,
        subtitle: widgetText("今天", "Today", "きょう"),
        theme: theme
      )

      Spacer(minLength: 8)

      Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
        .font(DoggyWidgetTypography.font(size: 14, weight: .medium))
        .foregroundColor(theme.palette.textPrimary)
        .lineLimit(3)

      Text(_summaryMetaLine(snapshot: snapshot))
        .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
        .foregroundColor(theme.palette.textSecondary.opacity(0.72))
        .padding(.top, 5)

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 0) {
        _SummaryStatPill(
          value: "\(snapshot?.today.pendingCount ?? 0)",
          label: widgetText("待办", "To do", "やること"),
          theme: theme
        )
        Spacer(minLength: 8)
        _DogCompanionView(theme: theme)
          .frame(width: 64, height: 64)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 13)
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 28)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct DoggyLogSummaryMediumView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .bottom) {
        _SummaryHeader(
          snapshot: snapshot,
          subtitle: widgetText("今天", "Today", "きょう"),
          theme: theme,
          topInset: 5
        )
        Spacer()
        VStack(alignment: .trailing, spacing: 3) {
          Text(widgetMoodLabel(snapshot?.pet.mood ?? "calm"))
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.accentPrimary.opacity(0.94))

          Text(widgetText("陪你过好今天", "A soft little sidekick for today", "今日はやさしく付き添います"))
            .font(DoggyWidgetTypography.font(size: 9, weight: .regular))
            .foregroundColor(theme.palette.textSecondary.opacity(0.66))
            .lineLimit(1)
        }
      }
      .padding(.top, 4)

      Spacer(minLength: 11)

      HStack(alignment: .top, spacing: 9) {
        VStack(alignment: .leading, spacing: 8) {
          _SummaryMetricTile(
            title: widgetText("待办", "To do", "やること"),
            value: "\(snapshot?.today.pendingCount ?? 0)",
            accent: theme.palette.accentPrimary,
            theme: theme
          )

          _SummaryMetricTile(
            title: widgetText("完成", "Done", "できた"),
            value: "\(snapshot?.today.completedCount ?? 0)",
            accent: theme.palette.accentSecondary,
            theme: theme
          )
        }
        .frame(width: 72)

        VStack(alignment: .leading, spacing: 7) {
          Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
            .font(DoggyWidgetTypography.font(size: 17, weight: .medium))
            .foregroundColor(theme.palette.textPrimary)
            .lineLimit(2)
            .lineSpacing(1.5)

          if let time = snapshot?.today.nextTaskTime, !time.isEmpty {
            Text("\(widgetText("下一项", "Next up", "つぎ")) · \(time)")
              .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
              .foregroundColor(theme.palette.accentPrimary.opacity(0.92))
          }

          if let countdown = snapshot?.countdown {
            Text("\(countdown.title) · \(widgetText("还有", "", "あと")) \(widgetDaysLeftLabel(max(0, countdown.daysRemaining)))")
              .font(DoggyWidgetTypography.font(size: 11, weight: .regular))
              .foregroundColor(theme.palette.textSecondary.opacity(0.74))
              .lineLimit(1)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        _DogCompanionView(theme: theme)
          .frame(width: 54, height: 54)
      }

      Spacer(minLength: 7)

      HStack {
        _SummaryPawRhythmStrip(activeIndex: 1, count: 5, theme: theme)
        Spacer()
      }
    }
    .padding(.horizontal, 12)
    .padding(.top, 16)
    .padding(.bottom, 12)
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 30)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct DoggyLogSummaryLargeView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)
    let recentTasks = Array((snapshot?.recentTasks ?? []).prefix(3))

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        _SummaryHeader(
          snapshot: snapshot,
          subtitle: widgetText("今日小结", "Daily Summary", "今日のまとめ"),
          theme: theme
        )

        Spacer()

        VStack(alignment: .trailing, spacing: 5) {
          Text(widgetBreedLabel(snapshot?.pet.breed ?? widgetText("陪伴犬", "Companion", "相棒")))
            .font(DoggyWidgetTypography.font(size: 11, weight: .regular))
            .foregroundColor(theme.palette.textSecondary.opacity(0.76))

          Text(widgetMoodLabel(snapshot?.pet.mood ?? "excited"))
            .font(DoggyWidgetTypography.font(size: 13, weight: .medium))
            .foregroundColor(theme.palette.accentPrimary.opacity(0.95))
        }
      }

      Spacer(minLength: 12)

      HStack(alignment: .top, spacing: 10) {
        _SummaryMetricTile(
          title: widgetText("待办", "To do", "やること"),
          value: "\(snapshot?.today.pendingCount ?? 0)",
          accent: theme.palette.accentPrimary,
          theme: theme
        )

        _SummaryMetricTile(
          title: widgetText("完成", "Done", "できた"),
          value: "\(snapshot?.today.completedCount ?? 0)",
          accent: theme.palette.accentSecondary,
          theme: theme
        )

        VStack(alignment: .leading, spacing: 7) {
          Text(widgetText("下一项", "Next up", "つぎ"))
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.74))

          Text(snapshot?.today.nextTaskTitle ?? widgetText("今天还没有下一项任务", "Nothing is lined up next yet", "まだ次の予定は入っていません"))
            .font(DoggyWidgetTypography.font(size: 17, weight: .medium))
            .foregroundColor(theme.palette.textPrimary)
            .lineLimit(2)

          if let time = snapshot?.today.nextTaskTime, !time.isEmpty {
            Text(time)
              .font(DoggyWidgetTypography.font(size: 11, weight: .medium))
              .foregroundColor(theme.palette.accentPrimary.opacity(0.95))
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Spacer(minLength: 12)

      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 8) {
          Text(widgetText("今日节奏", "Today's rhythm", "きょうのリズム"))
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.74))

          if recentTasks.isEmpty {
            Text(widgetText("今天还没有记录任务，去 App 里安排一下吧。", "No tasks logged yet. Pop into the app and add one.", "まだ記録された予定はありません。アプリでひとつ入れてみましょう。"))
              .font(DoggyWidgetTypography.font(size: 12, weight: .regular))
              .foregroundColor(theme.palette.textSecondary.opacity(0.78))
              .lineLimit(2)
          } else {
            ForEach(Array(recentTasks.enumerated()), id: \.offset) { _, task in
              HStack(spacing: 7) {
                Circle()
                  .fill(task.completed ? theme.palette.accentSecondary.opacity(0.92) : theme.palette.accentPrimary.opacity(0.88))
                  .frame(width: 6, height: 6)

                Text(task.title)
                  .font(DoggyWidgetTypography.font(size: 12, weight: .regular))
                  .foregroundColor(theme.palette.textPrimary.opacity(0.84))
                  .lineLimit(1)

                Spacer(minLength: 4)

                Text(task.time)
                  .font(DoggyWidgetTypography.font(size: 10, weight: .regular))
                  .foregroundColor(theme.palette.textSecondary.opacity(0.74))
              }
              .padding(.vertical, 2)
            }
          }

          if let countdown = snapshot?.countdown {
            Text("\(countdown.title) · \(widgetText("还有", "", "あと")) \(widgetDaysLeftLabel(max(0, countdown.daysRemaining)))")
              .font(DoggyWidgetTypography.font(size: 11, weight: .medium))
              .foregroundColor(theme.palette.accentPrimary.opacity(0.95))
              .padding(.top, 3)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .trailing, spacing: 10) {
          _DogCompanionView(theme: theme)
            .frame(width: 88, height: 88)

          _SummaryPawRhythmStrip(activeIndex: 2, count: 6, theme: theme)
        }
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 16)
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 32)
    }
    .widgetURL(URL(string: "doggylog://"))
  }
}

private struct _SummaryHeader: View {
  let snapshot: DoggyLogSharedSnapshot?
  let subtitle: String
  let theme: DoggyWidgetTheme
  var topInset: CGFloat = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(snapshot?.pet.name ?? "DoggyLog")
        .font(DoggyWidgetTypography.font(size: 20, weight: .medium))
        .foregroundColor(theme.palette.textPrimary)
        .lineLimit(1)
        .padding(.top, topInset)

      Text(subtitle)
        .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
        .foregroundColor(theme.palette.accentPrimary.opacity(0.92))
    }
  }
}

private struct _SummaryMetricTile: View {
  let title: String
  let value: String
  let accent: Color
  let theme: DoggyWidgetTheme

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(DoggyWidgetTypography.font(size: 9, weight: .medium))
        .foregroundColor(theme.palette.textSecondary.opacity(0.74))

      Text(value)
        .font(DoggyWidgetTypography.font(size: 24, weight: .medium))
        .foregroundColor(theme.palette.textPrimary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 9)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(accent.opacity(0.14))
    )
  }
}

private struct _SummaryStatPill: View {
  let value: String
  let label: String
  let theme: DoggyWidgetTheme

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value)
        .font(DoggyWidgetTypography.font(size: 20, weight: .medium))
        .foregroundColor(theme.palette.textPrimary)
      Text(label)
        .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
        .foregroundColor(theme.palette.textSecondary.opacity(0.74))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 7)
    .background(
      Capsule(style: .continuous)
        .fill(theme.palette.accentPrimary.opacity(0.14))
    )
  }
}

private struct _SummaryPawRhythmStrip: View {
  let activeIndex: Int
  let count: Int
  let theme: DoggyWidgetTheme

  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<count, id: \.self) { index in
        Image(systemName: "pawprint.fill")
          .font(.system(size: 13, weight: .regular))
          .foregroundColor(
            index == activeIndex
              ? theme.palette.accentPrimary.opacity(0.34)
              : theme.palette.quietSymbol
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

func doggyLogSummaryMediumPreview(entry: DoggyLogEntry) -> some View {
  DoggyLogSummaryMediumView(entry: entry)
}
