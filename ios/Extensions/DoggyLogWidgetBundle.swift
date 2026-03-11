import SwiftUI
import WidgetKit

@main
struct DoggyLogWidgetBundle: WidgetBundle {
  var body: some Widget {
    // 原有摘要 Widget（small/medium/large 通用）
    DoggyLogSummaryWidget()

    // 新增：大日历（systemLarge）
    DoggyLogLargeCalendarWidget()

    // 新增：中型日历——本周爪印视图（systemMedium）
    DoggyLogMediumCalendarWidget()

    // 新增：倒计时（systemSmall + systemMedium）
    DoggyLogCountdownWidget()

    if #available(iOSApplicationExtension 16.1, *) {
      DoggyLogLiveActivityWidget()
    }
  }
}
