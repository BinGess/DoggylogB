import SwiftUI
import WidgetKit

struct DoggyLogCountdownWidget: Widget {
  let kind = "DoggyLogCountdownWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogCountdownWidgetView(entry: entry)
    }
    .configurationDisplayName(widgetText("倒计时", "Countdown", "カウントダウン"))
    .description(widgetText("用更醒目的节奏卡片显示最近一个倒计时。", "Show your nearest countdown in a bolder little card.", "いちばん近いカウントダウンを、少し目立つカードで表示します。"))
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct DoggyLogCountdownWidgetView: View {
  let entry: DoggyLogEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemSmall:
      DoggyLogCountdownSmallView(entry: entry)
    default:
      DoggyLogCountdownMediumView(entry: entry)
    }
  }
}

struct DoggyLogCountdownSmallView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)
    let countdown = snapshot?.countdown
    let petName = snapshot?.pet.name ?? widgetText("狗狗日历", "DoggyDays", "ワンカレ")

    VStack(alignment: .leading, spacing: 0) {
      Text(widgetText("倒计时", "Countdown", "カウントダウン"))
        .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
        .foregroundColor(theme.palette.accentPrimary.opacity(0.92))

      Text(petName)
        .font(DoggyWidgetTypography.font(size: 15, weight: .medium))
        .foregroundColor(theme.palette.textPrimary)
        .lineLimit(1)
        .padding(.top, 3)

      Spacer(minLength: 8)

      if let countdown {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
          Text("\(max(0, countdown.daysRemaining))")
            .font(DoggyWidgetTypography.font(size: 44, weight: .medium))
            .foregroundColor(theme.palette.textPrimary)

          Text(widgetText("天", "d", "日"))
            .font(DoggyWidgetTypography.font(size: 13, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.78))
        }

        Text(countdown.title)
          .font(DoggyWidgetTypography.font(size: 11, weight: .medium))
          .foregroundColor(theme.palette.textPrimary.opacity(0.84))
          .lineLimit(1)

        Text(_countdownDueDateLabel(ms: countdown.dueAt))
          .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
          .foregroundColor(theme.palette.accentPrimary.opacity(0.90))
          .padding(.top, 2)
      } else {
        Text(widgetText("暂无倒计时", "No countdown yet", "まだカウントダウンはありません"))
          .font(DoggyWidgetTypography.font(size: 14, weight: .medium))
          .foregroundColor(theme.palette.textPrimary)

        Text(widgetText("打开 App 添加一个目标吧", "Open the app and add one sweet little goal.", "アプリを開いて、楽しみをひとつ入れてみましょう。"))
          .font(DoggyWidgetTypography.font(size: 10, weight: .regular))
          .foregroundColor(theme.palette.textSecondary.opacity(0.72))
          .padding(.top, 4)
      }

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 0) {
        _CountdownPawRhythmStrip(
          activeIndex: 1,
          count: 4,
          iconSize: 11,
          spacing: 7,
          theme: theme
        )
        Spacer(minLength: 6)
        _DogCompanionView(theme: theme)
          .frame(width: 60, height: 60)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 13)
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 28)
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

struct DoggyLogCountdownMediumView: View {
  let entry: DoggyLogEntry

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let snapshot = entry.snapshot
    let theme = DoggyWidgetTheme.resolve(snapshot: snapshot, colorScheme: colorScheme)
    let countdown = snapshot?.countdown
    let petName = snapshot?.pet.name ?? widgetText("狗狗日历", "DoggyDays", "ワンカレ")

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(widgetText("倒计时", "Countdown", "カウントダウン"))
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.accentPrimary.opacity(0.92))

          Text(countdown?.title ?? petName)
            .font(DoggyWidgetTypography.font(size: 15, weight: .medium))
            .foregroundColor(theme.palette.textPrimary)
            .lineLimit(1)
        }

        Spacer()

        _CountdownMetaChip(
          text: countdown.map { _countdownDueDateLabel(ms: $0.dueAt) } ?? petName,
          theme: theme
        )
      }

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 10) {
        if let countdown {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Text("\(max(0, countdown.daysRemaining))")
                .font(DoggyWidgetTypography.font(size: 60, weight: .medium))
                .foregroundColor(theme.palette.textPrimary)
                .kerning(-1.4)

              Text(widgetText("天", "d", "日"))
                .font(DoggyWidgetTypography.font(size: 16, weight: .medium))
                .foregroundColor(theme.palette.textSecondary.opacity(0.76))
            }

            Text(widgetText("距离这一天", "Days until it", "この日まで"))
              .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
              .foregroundColor(theme.palette.textSecondary.opacity(0.72))
              .padding(.top, 1)

            Text(countdown.title)
              .font(DoggyWidgetTypography.font(size: 14, weight: .medium))
              .foregroundColor(theme.palette.textPrimary.opacity(0.88))
              .lineLimit(2)
              .padding(.top, 4)

            _CountdownProgressBar(progress: _progress(countdown: countdown), theme: theme)
              .padding(.top, 11)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          VStack(alignment: .leading, spacing: 6) {
            Text(widgetText("暂无倒计时", "No countdown yet", "まだカウントダウンはありません"))
              .font(DoggyWidgetTypography.font(size: 17, weight: .medium))
              .foregroundColor(theme.palette.textPrimary)
            Text(widgetText("前往 App 新建一个小目标，狗狗就会来提醒你。", "Add a little goal in the app, and your pup will keep an eye on it.", "アプリで小さな目標をひとつ作ると、わんこが見守ってくれます。"))
              .font(DoggyWidgetTypography.font(size: 11, weight: .regular))
              .foregroundColor(theme.palette.textSecondary.opacity(0.74))
              .lineLimit(2)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }

        _DogCompanionView(theme: theme)
          .frame(width: 74, height: 74)
      }

      Spacer(minLength: 8)

      HStack(alignment: .center) {
        _CountdownPawRhythmStrip(
          activeIndex: 2,
          count: 6,
          iconSize: 13,
          spacing: 9,
          theme: theme
        )
        Spacer()
        if let countdown {
          Text("\(Int(_progress(countdown: countdown) * 100))%")
            .font(DoggyWidgetTypography.font(size: 10, weight: .medium))
            .foregroundColor(theme.palette.textSecondary.opacity(0.66))
        }
      }
    }
    .padding(.horizontal, 12)
    .padding(.top, 13)
    .padding(.bottom, 12)
    .doggyWidgetBackground {
      DoggyWidgetCardBackground(theme: theme, cornerRadius: 30)
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

private struct _CountdownProgressBar: View {
  let progress: Double
  let theme: DoggyWidgetTheme

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(theme.palette.quietSymbol.opacity(0.9))
          .frame(height: 6)

        Capsule()
          .fill(theme.palette.accentPrimary.opacity(0.88))
          .frame(width: max(16, geo.size.width * progress), height: 6)
      }
    }
    .frame(height: 6)
  }
}

private struct _CountdownMetaChip: View {
  let text: String
  let theme: DoggyWidgetTheme

  var body: some View {
    Text(text)
      .font(DoggyWidgetTypography.font(size: 9, weight: .medium))
      .foregroundColor(theme.palette.accentPrimary.opacity(0.9))
      .lineLimit(1)
      .padding(.horizontal, 9)
      .padding(.vertical, 5)
      .background(
        Capsule(style: .continuous)
          .fill(theme.palette.accentPrimary.opacity(0.12))
      )
  }
}

private struct _CountdownPawRhythmStrip: View {
  let activeIndex: Int
  let count: Int
  let iconSize: CGFloat
  let spacing: CGFloat
  let theme: DoggyWidgetTheme

  var body: some View {
    HStack(spacing: spacing) {
      ForEach(0..<count, id: \.self) { index in
        Image(systemName: "pawprint.fill")
          .font(.system(size: iconSize, weight: .regular))
          .foregroundColor(
            index == activeIndex
              ? theme.palette.accentPrimary.opacity(0.36)
              : theme.palette.quietSymbol
          )
      }
    }
  }
}

private func _countdownDueDateLabel(ms: Int) -> String {
  widgetShortDateLabel(ms: ms)
}

private func _progress(countdown: SnapshotCountdown) -> Double {
  let now = Date().timeIntervalSince1970 * 1000
  let total = Double(countdown.dueAt - countdown.startAt)
  guard total > 0 else { return 1.0 }
  let elapsed = Double(Int(now) - countdown.startAt)
  return min(max(elapsed / total, 0.0), 1.0)
}

func doggyLogCountdownMediumPreview(entry: DoggyLogEntry) -> some View {
  DoggyLogCountdownMediumView(entry: entry)
}
