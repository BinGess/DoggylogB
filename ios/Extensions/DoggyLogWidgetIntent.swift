import AppIntents

// AppIntent that marks the next task as complete directly from the Dynamic Island.
// It writes the task ID to the shared App Group UserDefaults so the main app
// can pick it up on next foreground and complete the task via Flutter.
@available(iOS 16.2, *)
struct CompleteNextTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "完成下一件任务"
  static var description = IntentDescription("从灵动岛直接标记下一件任务为已完成")
  /// 执行后打开 App，让 AppDelegate 读取待处理的任务 ID 并通知 Flutter。
  static let openAppWhenRun = true

  // @Parameter is required so WidgetKit serialises/deserialises the value
  // correctly when the interactive button is tapped.
  @Parameter(title: "任务 ID")
  var taskId: String

  init() { taskId = "" }
  init(taskId: String) { self.taskId = taskId }

  func perform() async throws -> some IntentResult {
    guard !taskId.isEmpty else { return .result() }
    if let defaults = UserDefaults(suiteName: "group.com.timmy.doggylog") {
      defaults.set(taskId, forKey: "doggylog.widget.pendingCompleteTaskId")
      defaults.synchronize()
    }
    return .result()
  }
}
