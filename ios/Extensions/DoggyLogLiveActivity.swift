import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
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

@available(iOSApplicationExtension 16.1, *)
struct DoggyLogLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DoggyLogLiveActivityAttributes.self) { context in
      // 锁屏 / 灵动岛展开下方横幅
      HStack(spacing: 12) {
        // 左侧：宠物信息
        VStack(alignment: .leading, spacing: 3) {
          HStack(spacing: 4) {
            Image(systemName: "pawprint.fill")
              .font(.caption)
              .foregroundStyle(.white.opacity(0.8))
            Text(context.state.petName)
              .font(.headline)
          }
          Text("\(context.state.petMood) · \(context.state.sceneMode)")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.65))
        }
        Spacer()
        // 右侧：任务计数
        VStack(alignment: .trailing, spacing: 3) {
          HStack(spacing: 4) {
            Image(systemName: "checkmark.circle")
              .font(.caption)
              .foregroundStyle(.white.opacity(0.65))
            Text("\(context.state.completedCount)")
              .font(.caption.weight(.medium))
              .foregroundStyle(.white.opacity(0.65))
          }
          HStack(spacing: 4) {
            Image(systemName: "circle")
              .font(.caption)
            Text("\(context.state.pendingCount) 待办")
              .font(.subheadline.weight(.semibold))
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 12)

      // 分隔线
      Divider().overlay(.white.opacity(0.15))
        .padding(.horizontal, 16)

      // 下方：下一任务 + 倒计时
      HStack(alignment: .top, spacing: 0) {
        if let nextTitle = context.state.nextTaskTitle {
          VStack(alignment: .leading, spacing: 2) {
            Text("下一件")
              .font(.caption2)
              .foregroundStyle(.white.opacity(0.5))
            Text(nextTitle)
              .font(.caption.weight(.semibold))
              .lineLimit(1)
            if let nextTime = context.state.nextTaskTime {
              Text(nextTime)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        if let countdownTitle = context.state.countdownTitle,
           let days = context.state.countdownDaysRemaining {
          VStack(alignment: .trailing, spacing: 2) {
            Text("倒计时")
              .font(.caption2)
              .foregroundStyle(.white.opacity(0.5))
            Text("\(days) 天")
              .font(.title3.weight(.bold))
              .foregroundStyle(days <= 3 ? .orange : .white)
            Text(countdownTitle)
              .font(.caption2)
              .lineLimit(1)
              .foregroundStyle(.white.opacity(0.65))
          }
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 12)
      .padding(.top, 6)
      .activityBackgroundTint(.black.opacity(0.92))
      .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        // 展开 Leading：宠物名 + 心情
        DynamicIslandExpandedRegion(.leading) {
          HStack(spacing: 6) {
            Image(systemName: "pawprint.fill")
              .font(.callout)
              .foregroundStyle(.white.opacity(0.85))
            VStack(alignment: .leading, spacing: 1) {
              Text(context.state.petName)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
              Text(context.state.petMood)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
        // 展开 Trailing：任务计数
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 3) {
              Text("\(context.state.pendingCount)")
                .font(.callout.weight(.bold))
              Image(systemName: "circle")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            HStack(spacing: 3) {
              Text("\(context.state.completedCount)")
                .font(.caption2)
              Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(.green.opacity(0.8))
            }
          }
        }
        // 展开 Bottom：下一任务 + 倒计时 + 完成按钮
        DynamicIslandExpandedRegion(.bottom) {
          HStack(alignment: .top) {
            // 下一任务
            if let nextTitle = context.state.nextTaskTitle {
              VStack(alignment: .leading, spacing: 2) {
                Text("下一件")
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                Text(nextTitle)
                  .font(.caption.weight(.semibold))
                  .lineLimit(1)
                if let nextTime = context.state.nextTaskTime {
                  Text(nextTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            // 倒计时
            if let countdownTitle = context.state.countdownTitle,
               let days = context.state.countdownDaysRemaining {
              VStack(alignment: .trailing, spacing: 2) {
                Text(countdownTitle)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                  Text("\(days)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(days <= 3 ? .orange : .white)
                  Text("天")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
              }
              .frame(maxWidth: .infinity, alignment: .trailing)
            }
            // 完成按钮（iOS 16.2+，有待完成任务时显示）
            if #available(iOSApplicationExtension 16.2, *),
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
        // 宠物名（最多5字）+ 爪印图标
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
        // 有倒计时且紧急时显示天数，否则显示待办数
        if let days = context.state.countdownDaysRemaining, days <= 7 {
          HStack(spacing: 2) {
            Text("\(days)天")
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
        // 有紧急倒计时时显示天数徽章，否则显示爪印
        if let days = context.state.countdownDaysRemaining, days <= 3 {
          Text("\(days)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.orange)
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
#endif
