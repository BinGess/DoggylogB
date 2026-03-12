import SwiftUI
import WidgetKit

// MARK: - Countdown Widget

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

  var body: some View {
    let snapshot = entry.snapshot
    let countdown = snapshot?.countdown
    let petName = snapshot?.pet.name ?? "DoggyLog"

    VStack(alignment: .leading, spacing: 0) {
      Text(widgetText("倒计时", "Countdown", "カウントダウン"))
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundColor(.doggyWarmTint.opacity(0.92))

      Text(petName)
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .foregroundColor(.doggyInk)
        .lineLimit(1)
        .padding(.top, 3)

      Spacer(minLength: 8)

      if let countdown {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
          Text("\(max(0, countdown.daysRemaining))")
            .font(.system(size: 44, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk)

          Text(widgetText("天", "d", "日"))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.55))
        }

        Text(countdown.title)
          .font(.system(size: 11, weight: .medium, design: .rounded))
          .foregroundColor(.doggyInk.opacity(0.82))
          .lineLimit(1)

        Text(_countdownDueDateLabel(ms: countdown.dueAt))
          .font(.system(size: 10, weight: .medium, design: .rounded))
          .foregroundColor(.doggyWarmTint.opacity(0.90))
          .padding(.top, 2)
      } else {
        Text(widgetText("暂无倒计时", "No countdown yet", "まだカウントダウンはありません"))
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .foregroundColor(.doggyInk)

        Text(widgetText("打开 App 添加一个目标吧", "Open the app and add one sweet little goal.", "アプリを開いて、楽しみをひとつ入れてみましょう。"))
          .font(.system(size: 10, weight: .medium, design: .rounded))
          .foregroundColor(.doggyInk.opacity(0.48))
          .padding(.top, 4)
      }

      Spacer(minLength: 8)

      HStack(alignment: .bottom, spacing: 0) {
        _PawRhythmStrip(activeIndex: 1, count: 4, iconSize: 11, spacing: 7)
        Spacer(minLength: 6)
        _DogCompanionView()
          .frame(width: 60, height: 60)
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 14)
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

struct DoggyLogCountdownMediumView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let snapshot = entry.snapshot
    let countdown = snapshot?.countdown
    let petName = snapshot?.pet.name ?? "DoggyLog"

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 3) {
          Text(widgetText("倒计时", "Countdown", "カウントダウン"))
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.doggyWarmTint.opacity(0.92))

          Text(petName)
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundColor(.doggyInk)
            .lineLimit(1)
        }

        Spacer()

        Text(widgetText("陪你守住目标", "Keeping this goal close", "この目標をそっと見守ります"))
          .font(.system(size: 10, weight: .medium, design: .rounded))
          .foregroundColor(.doggyInk.opacity(0.40))
      }

      Spacer(minLength: 10)

      HStack(alignment: .bottom, spacing: 12) {
        if let countdown {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Text("\(max(0, countdown.daysRemaining))")
                .font(.system(size: 52, weight: .medium, design: .rounded))
                .foregroundColor(.doggyInk)

              Text(widgetText("天", "d", "日"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.doggyInk.opacity(0.52))
            }

            Text(countdown.title)
              .font(.system(size: 13, weight: .semibold, design: .rounded))
              .foregroundColor(.doggyInk.opacity(0.86))
              .lineLimit(2)
              .padding(.top, 2)

            Text(_countdownDueDateLabel(ms: countdown.dueAt))
              .font(.system(size: 10, weight: .medium, design: .rounded))
              .foregroundColor(.doggyWarmTint.opacity(0.92))
              .padding(.top, 2)

            _CountdownProgressBar(progress: _progress(countdown: countdown))
              .padding(.top, 10)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          VStack(alignment: .leading, spacing: 6) {
            Text(widgetText("暂无倒计时", "No countdown yet", "まだカウントダウンはありません"))
              .font(.system(size: 17, weight: .semibold, design: .rounded))
              .foregroundColor(.doggyInk)
            Text(widgetText("前往 App 新建一个小目标，狗狗就会来提醒你。", "Add a little goal in the app, and your pup will keep an eye on it.", "アプリで小さな目標をひとつ作ると、わんこが見守ってくれます。"))
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundColor(.doggyInk.opacity(0.50))
              .lineLimit(2)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }

        _DogCompanionView()
          .frame(width: 80, height: 80)
      }

      Spacer(minLength: 8)

      HStack(alignment: .center) {
        _PawRhythmStrip(activeIndex: 2, count: 6, iconSize: 13, spacing: 9)
        Spacer()
        if let countdown {
          Text("\(Int(_progress(countdown: countdown) * 100))%")
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundColor(.doggyInk.opacity(0.40))
        }
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 16)
    .doggyWidgetBackground {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(Color.doggyWarmCard)
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

private struct _CountdownProgressBar: View {
  let progress: Double

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.doggyInk.opacity(0.07))
          .frame(height: 6)

        Capsule()
          .fill(Color.doggyWarmTint.opacity(0.85))
          .frame(width: max(16, geo.size.width * progress), height: 6)
      }
    }
    .frame(height: 6)
  }
}

private struct _PawRhythmStrip: View {
  let activeIndex: Int
  let count: Int
  let iconSize: CGFloat
  let spacing: CGFloat

  var body: some View {
    HStack(spacing: spacing) {
      ForEach(0..<count, id: \.self) { index in
        Image(systemName: "pawprint.fill")
          .font(.system(size: iconSize, weight: .regular))
          .foregroundColor(
            index == activeIndex
              ? .doggyWarmTint.opacity(0.36)
              : .doggyInk.opacity(0.07)
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
