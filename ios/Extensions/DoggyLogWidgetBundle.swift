import SwiftUI
import WidgetKit

@main
struct DoggyLogWidgetBundle: WidgetBundle {
  var body: some Widget {
    // 日历（周）— 本周爪印视图（systemMedium）
    DoggyLogMediumCalendarWidget()

    // 日历（大）— 本月完整日历（systemLarge）
    DoggyLogLargeCalendarWidget()

    // 灵动岛 / Live Activity（iOS 16.1+）
    if #available(iOSApplicationExtension 16.1, *) {
      DoggyLogLiveActivityWidget()
    }
  }
}
