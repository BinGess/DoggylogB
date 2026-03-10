import SwiftUI
import WidgetKit

// MARK: - Countdown Widget

struct DoggyLogCountdownWidget: Widget {
  let kind = "DoggyLogCountdownWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoggyLogCalendarProvider()) { entry in
      DoggyLogCountdownWidgetView(entry: entry)
    }
    .configurationDisplayName("倒计时")
    .description("大字显示最近一个倒计时的剩余天数。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Countdown Entry View (dispatches by family)

struct DoggyLogCountdownWidgetView: View {
  let entry: DoggyLogEntry

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      DoggyLogCountdownSmallView(entry: entry)
    default:
      DoggyLogCountdownMediumView(entry: entry)
    }
  }
}

// MARK: - Small View

struct DoggyLogCountdownSmallView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let countdown = entry.snapshot?.countdown
    let petName = entry.snapshot?.pet.name ?? "DoggyLog"

    ZStack {
      // 背景渐变
      LinearGradient(
        colors: [
          Color(red: 0.184, green: 0.561, blue: 0.541),
          Color(red: 0.447, green: 0.788, blue: 0.757),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 0) {
        // 宠物名行
        HStack(spacing: 3) {
          Text(petName)
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.white.opacity(0.80))
          Text("🐾")
            .font(.system(size: 11))
        }

        Spacer()

        // 核心：剩余天数
        if let countdown {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
              Text("\(max(0, countdown.daysRemaining))")
                .font(.system(size: 46, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
              Text("天")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(.white.opacity(0.88))
            }
            Text(countdown.title)
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(.white)
              .lineLimit(1)
            Text(_dueDateLabel(ms: countdown.dueAt))
              .font(.system(size: 10, weight: .regular))
              .foregroundStyle(.white.opacity(0.68))
              .padding(.top, 2)
          }
        } else {
          Text("暂无倒计时")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.white.opacity(0.75))
        }
      }
      .padding(14)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    .containerBackground(for: .widget) {
      LinearGradient(
        colors: [
          Color(red: 0.184, green: 0.561, blue: 0.541),
          Color(red: 0.447, green: 0.788, blue: 0.757),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

// MARK: - Medium View

struct DoggyLogCountdownMediumView: View {
  let entry: DoggyLogEntry

  var body: some View {
    let countdown = entry.snapshot?.countdown
    let petName = entry.snapshot?.pet.name ?? "DoggyLog"

    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.184, green: 0.561, blue: 0.541),
          Color(red: 0.447, green: 0.788, blue: 0.757),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      HStack(alignment: .center, spacing: 0) {
        // ── 左列：宠物 + 天数大字 ───────────────────────
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 3) {
            Text(petName)
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(.white.opacity(0.80))
            Text("🐾")
              .font(.system(size: 12))
          }

          Spacer()

          HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text("\(max(0, countdown?.daysRemaining ?? 0))")
              .font(.system(size: 50, weight: .thin, design: .rounded))
              .foregroundStyle(.white)
            Text("天")
              .font(.system(size: 15, weight: .light))
              .foregroundStyle(.white.opacity(0.88))
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        // 分隔线
        Rectangle()
          .fill(.white.opacity(0.25))
          .frame(width: 0.8)
          .padding(.vertical, 10)
          .padding(.horizontal, 12)

        // ── 右列：标题 + 截止日期 + 进度 ──────────────────
        VStack(alignment: .leading, spacing: 6) {
          if let countdown {
            Text(countdown.title)
              .font(.system(size: 14, weight: .regular))
              .foregroundStyle(.white)
              .lineLimit(2)

            Text(_dueDateLabel(ms: countdown.dueAt))
              .font(.system(size: 11, weight: .regular))
              .foregroundStyle(.white.opacity(0.72))

            Spacer(minLength: 4)

            // 进度条
            let progress = _progress(countdown: countdown)
            VStack(alignment: .trailing, spacing: 3) {
              GeometryReader { geo in
                ZStack(alignment: .leading) {
                  Capsule()
                    .fill(.white.opacity(0.25))
                    .frame(height: 4)
                  Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: geo.size.width * progress, height: 4)
                }
              }
              .frame(height: 4)

              Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.white.opacity(0.68))
            }
          } else {
            Spacer()
            Text("暂无倒计时\n前往 App 添加吧")
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(.white.opacity(0.80))
              .multilineTextAlignment(.leading)
            Spacer()
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
    }
    .containerBackground(for: .widget) {
      LinearGradient(
        colors: [
          Color(red: 0.184, green: 0.561, blue: 0.541),
          Color(red: 0.447, green: 0.788, blue: 0.757),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
    .widgetURL(URL(string: "doggylog://tab/countdown"))
  }
}

// MARK: - Helpers

private func _dueDateLabel(ms: Int) -> String {
  let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
  let cal = Calendar.current
  let month = cal.component(.month, from: date)
  let day = cal.component(.day, from: date)
  let year = cal.component(.year, from: date)
  let nowYear = cal.component(.year, from: Date())
  return year == nowYear ? "\(month)月\(day)日" : "\(year)年\(month)月\(day)日"
}

private func _progress(countdown: SnapshotCountdown) -> Double {
  let now = Date().timeIntervalSince1970 * 1000
  let total = Double(countdown.dueAt - countdown.startAt)
  guard total > 0 else { return 1.0 }
  let elapsed = Double(Int(now) - countdown.startAt)
  return min(max(elapsed / total, 0.0), 1.0)
}
