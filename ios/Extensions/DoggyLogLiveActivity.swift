import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
import AppIntents
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
struct DoggyLogLiveActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var petName: String
    var petBreed: String
    var petMood: String
    var sceneMode: String
    var pendingCount: Int
    var completedCount: Int
    var nextTaskTitle: String?
    var nextTaskTime: String?
    var nextTaskId: String?
    var countdownTitle: String?
    var countdownDaysRemaining: Int?
  }

  var title: String
}

// CompleteNextTaskIntent 定义在 DoggyLogWidgetIntent.swift，供灵动岛完成按钮使用。

@available(iOSApplicationExtension 16.1, *)
struct DoggyLogLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DoggyLogLiveActivityAttributes.self) { context in
      _LiveActivityLockScreenView(context: context)
      .activityBackgroundTint(.clear)
      .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          HStack(spacing: 6) {
            Image(systemName: "pawprint.fill")
              .font(.callout)
              .foregroundStyle(.white.opacity(0.85))
            VStack(alignment: .leading, spacing: 1) {
              Text(context.state.petName)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
              Text(context.state.petBreed)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          if let days = context.state.countdownDaysRemaining {
            VStack(alignment: .trailing, spacing: 2) {
              Text(widgetText("倒计时", "Countdown", "カウントダウン"))
                .font(.caption2)
                .foregroundStyle(.secondary)
              Text("\(max(0, days))")
                .font(.title3.weight(.bold))
                .foregroundStyle(days <= 3 ? .orange : .white)
            }
          } else {
            _LiveActivityCountSummary(
              pendingCount: context.state.pendingCount,
              completedCount: context.state.completedCount
            )
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack(alignment: .bottom, spacing: 12) {
            _LiveActivityIslandCountdown(context: context)
              .frame(maxWidth: .infinity, alignment: .leading)
            if #available(iOSApplicationExtension 17.0, *),
               let taskId = context.state.nextTaskId, !taskId.isEmpty {
              Button(
                intent: CompleteNextTaskIntent(taskId: taskId)
              ) {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title2)
                  .foregroundStyle(.green)
              }
              .buttonStyle(.plain)
            }
          }
        }
      } compactLeading: {
        HStack(spacing: 3) {
          Image(systemName: "pawprint.fill")
            .font(.caption2)
          Text(context.state.petName)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: 52)
        }
      } compactTrailing: {
        if let days = context.state.countdownDaysRemaining {
          HStack(spacing: 2) {
            Text(widgetDaysLeftLabel(max(0, days)))
              .font(.caption.weight(.bold))
              .foregroundStyle(days <= 3 ? .orange : .white)
          }
        } else {
          HStack(spacing: 2) {
            Text("\(context.state.pendingCount)")
              .font(.caption.weight(.bold))
            Image(systemName: "circle")
              .font(.system(size: 8))
              .foregroundStyle(.secondary)
          }
        }
      } minimal: {
        if let days = context.state.countdownDaysRemaining {
          Text("\(max(0, days))")
            .font(.caption2.weight(.bold))
            .foregroundStyle(days <= 3 ? .orange : .white)
        } else if context.state.pendingCount > 0 {
          ZStack {
            Image(systemName: "pawprint.fill")
              .font(.caption2)
            Text("\(context.state.pendingCount)")
              .font(.system(size: 7, weight: .bold))
              .offset(x: 5, y: -5)
          }
        } else {
          Image(systemName: "pawprint.fill")
            .font(.caption2)
        }
      }
    }
  }
}

@available(iOSApplicationExtension 16.1, *)
private struct _LiveActivityLockScreenView: View {
  let context: ActivityViewContext<DoggyLogLiveActivityAttributes>

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack(alignment: .center, spacing: 12) {
        HStack(spacing: 6) {
          Image(systemName: "pawprint.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.86))
          Text(context.state.petName)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
        }
        Spacer(minLength: 12)

        _LiveActivityCountSummary(
          pendingCount: context.state.pendingCount,
          completedCount: context.state.completedCount
        )
      }

      if let countdownTitle = context.state.countdownTitle,
         let days = context.state.countdownDaysRemaining {
        HStack(alignment: .top, spacing: 18) {
          VStack(alignment: .leading, spacing: 12) {
            Text(widgetText("只保留一个提醒焦点", "One reminder in focus", "ひとつの予定だけに集中"))
              .font(.caption.weight(.semibold))
              .foregroundStyle(.white.opacity(0.72))
            Text(countdownTitle)
              .font(.title2.weight(.semibold))
              .foregroundStyle(.white)
              .lineLimit(2)
              .layoutPriority(1)
              .fixedSize(horizontal: false, vertical: true)
            Text(widgetText("倒计时会持续停留在锁屏中央。", "This countdown stays centered on your lock screen.", "このカウントダウンをロック画面の中心に残します。"))
              .font(.caption.weight(.medium))
              .foregroundStyle(.white.opacity(0.58))
              .lineLimit(2)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: 8)

          VStack(alignment: .trailing, spacing: 10) {
            Text("\(max(0, days))")
              .font(.system(size: 54, weight: .bold, design: .rounded))
              .foregroundStyle(days <= 3 ? .orange : .white)
            Text(widgetText("天", "days", "日"))
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.white.opacity(0.78))
            Text(widgetText("倒计时", "Countdown", "カウントダウン"))
              .font(.caption2.weight(.medium))
              .foregroundStyle(.white.opacity(0.54))
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(
                Capsule(style: .continuous)
                  .fill(.white.opacity(0.08))
              )
              .multilineTextAlignment(.trailing)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, minHeight: 148, alignment: .topLeading)
    .padding(.horizontal, 20)
    .padding(.vertical, 18)
    .background {
      ZStack {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color(red: 0.17, green: 0.10, blue: 0.14),
                Color(red: 0.28, green: 0.16, blue: 0.12),
                Color(red: 0.40, green: 0.22, blue: 0.14)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(.white.opacity(0.06))
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .strokeBorder(.white.opacity(0.14), lineWidth: 1)
      }
    }
  }
}

@available(iOSApplicationExtension 16.1, *)
private struct _LiveActivityIslandCountdown: View {
  let context: ActivityViewContext<DoggyLogLiveActivityAttributes>

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      if let countdownTitle = context.state.countdownTitle,
         let days = context.state.countdownDaysRemaining {
        Text(widgetText("只保留一个提醒焦点", "One reminder in focus", "ひとつの予定だけに集中"))
          .font(.caption2)
          .foregroundStyle(.secondary)
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text("\(max(0, days))")
            .font(.title3.weight(.bold))
            .foregroundStyle(days <= 3 ? .orange : .white)
          Text(widgetText("天", "days", "日"))
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
        }
        Text(countdownTitle)
          .font(.caption.weight(.semibold))
          .lineLimit(1)
      }
    }
  }
}

private struct _LiveActivityCountSummary: View {
  let pendingCount: Int
  let completedCount: Int

  var body: some View {
    HStack(spacing: 8) {
      _LiveActivityCountPill(
        icon: "circle",
        value: pendingCount,
        tint: .white.opacity(0.92)
      )
      _LiveActivityCountPill(
        icon: "checkmark.circle.fill",
        value: completedCount,
        tint: .green.opacity(0.92)
      )
    }
  }
}

private struct _LiveActivityCountPill: View {
  let icon: String
  let value: Int
  let tint: Color

  var body: some View {
    HStack(spacing: 5) {
      Image(systemName: icon)
        .font(.caption2.weight(.semibold))
      Text("\(value)")
        .font(.caption.weight(.semibold))
    }
    .foregroundColor(tint)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule(style: .continuous)
        .fill(.white.opacity(0.08))
    )
  }
}
#endif
