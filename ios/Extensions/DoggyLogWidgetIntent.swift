import AppIntents

// AppIntent that marks the next task as complete directly from the Dynamic Island.
// It writes the task ID to the shared App Group UserDefaults so the main app
// can pick it up on next foreground and complete the task.
@available(iOS 16.2, *)
struct CompleteNextTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "完成下一件任务"
  static var description = IntentDescription("从灵动岛直接标记下一件任务为已完成")

  var taskId: String

  init() {
    self.taskId = ""
  }

  init(taskId: String) {
    self.taskId = taskId
  }

  func perform() async throws -> some IntentResult {
    guard !taskId.isEmpty else { return .result() }
    if let defaults = UserDefaults(suiteName: "group.com.timmy.doggylog") {
      defaults.set(taskId, forKey: "doggylog.widget.pendingCompleteTaskId")
      defaults.synchronize()
    }
    return .result()
  }
}
