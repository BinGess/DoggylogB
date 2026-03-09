import SwiftUI
import WidgetKit

@main
struct DoggyLogWidgetBundle: WidgetBundle {
  var body: some Widget {
    DoggyLogSummaryWidget()
    if #available(iOS 16.1, *) {
      DoggyLogLiveActivityWidget()
    }
  }
}
