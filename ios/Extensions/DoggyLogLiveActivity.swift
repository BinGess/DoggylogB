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
    var countdownTitle: String?
    var countdownDaysRemaining: Int?
  }

  var title: String
}

@available(iOSApplicationExtension 16.1, *)
struct DoggyLogLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DoggyLogLiveActivityAttributes.self) { context in
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(context.state.petName).font(.headline)
            Text("\(context.state.petMood) · \(context.state.sceneMode)")
              .font(.caption)
              .foregroundStyle(.white.opacity(0.72))
          }
          Spacer()
          Text("待办 \(context.state.pendingCount)")
            .font(.title3.weight(.semibold))
        }
        if let nextTaskTitle = context.state.nextTaskTitle {
          Text(nextTaskTitle).lineLimit(1).font(.body.weight(.semibold))
        }
        if let nextTaskTime = context.state.nextTaskTime {
          Text("下一项 \(nextTaskTime)")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.72))
        }
        if let countdownTitle = context.state.countdownTitle,
           let days = context.state.countdownDaysRemaining {
          Text("\(countdownTitle) · 剩余 \(days) 天")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.78))
        }
      }
      .padding()
      .activityBackgroundTint(.black.opacity(0.92))
      .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.state.petName)
            Text(context.state.petMood)
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing, spacing: 2) {
            Text("待办 \(context.state.pendingCount)")
            Text("已完成 \(context.state.completedCount)")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            Text(context.state.nextTaskTitle ?? context.state.countdownTitle ?? "DoggyLog")
              .lineLimit(1)
            if let nextTaskTime = context.state.nextTaskTime {
              Text(nextTaskTime)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
      } compactLeading: {
        Text("汪").font(.headline)
      } compactTrailing: {
        Text("\(context.state.pendingCount)").font(.headline)
      } minimal: {
        Text("汪")
      }
    }
  }
}
#endif
