import Flutter
import WidgetKit
import EventKit
import CoreMotion
import Foundation
import UserNotifications
import UIKit
#if canImport(ActivityKit)
import ActivityKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let eventKitService = DoggylogEventKitService()
  private let snapshotStore = DoggylogSnapshotStore()
  private let liveActivityBridge = DoggylogLiveActivityBridge()
  private let motionService = DoggylogMotionService()
  private var platformChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "doggylog/platform",
        binaryMessenger: controller.binaryMessenger
      )
      platformChannel = channel
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "isCalendarSyncAvailable":
          result(self.eventKitService.isAvailable())
        case "requestCalendarAccess":
          self.eventKitService.requestAccess { granted in
            result(granted)
          }
        case "importCalendarItems":
          let arguments = call.arguments as? [String: Any]
          let selectedCalendarIds = arguments?["selectedCalendarIds"] as? [String]
          self.eventKitService.importCalendarItems(selectedCalendarIds: selectedCalendarIds) { payload in
            result(payload)
          }
        case "getSystemCalendars":
          self.eventKitService.getSystemCalendars { payload in
            result(payload)
          }
        case "syncCalendarDelta":
          let arguments = call.arguments as? [String: Any]
          let updatedAfter = arguments?["updatedAfter"] as? Int
          let selectedCalendarIds = arguments?["selectedCalendarIds"] as? [String]
          self.eventKitService.syncCalendarDelta(
            updatedAfterMillis: updatedAfter,
            selectedCalendarIds: selectedCalendarIds
          ) { payload in
            result(payload)
          }
        case "upsertCalendarItem":
          let payloadJson = (call.arguments as? [String: Any])?["payloadJson"] as? String ?? ""
          self.eventKitService.upsertCalendarItem(payloadJson: payloadJson) { eventIdentifier in
            result(eventIdentifier)
          }
        case "deleteCalendarItem":
          let arguments = call.arguments as? [String: Any]
          let systemEntryId = arguments?["systemEntryId"] as? String
          let localId = arguments?["localId"] as? String
          self.eventKitService.deleteCalendarItem(systemEntryId: systemEntryId, localId: localId) { deleted in
            result(deleted)
          }
        case "publishWidgetSnapshot":
          let payloadJson = (call.arguments as? [String: Any])?["payloadJson"] as? String ?? ""
          result(self.snapshotStore.publish(payloadJson: payloadJson))
        case "updateDynamicIsland":
          let payloadJson = (call.arguments as? [String: Any])?["payloadJson"] as? String ?? ""
          self.liveActivityBridge.update(payloadJson: payloadJson, snapshotStore: self.snapshotStore) { supported in
            result(supported)
          }
        case "endDynamicIsland":
          self.liveActivityBridge.end { ended in
            result(ended)
          }
        case "startSensors":
          result(self.motionService.start { [weak self] sample in
            self?.platformChannel?.invokeMethod("sensorSample", arguments: sample)
          })
        case "backupToCloud":
          result(false)
        case "stopSensors":
          self.motionService.stop()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleEventStoreDidChange),
        name: .EKEventStoreChanged,
        object: nil
      )
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func handleEventStoreDidChange() {
    platformChannel?.invokeMethod("eventStoreDidChange", arguments: nil)
  }
}

final class DoggylogSnapshotStore {
  private let appGroupIdentifier = "group.com.timmy.doggylog"
  private let snapshotFileName = "doggylog_widget_snapshot.json"

  func publish(payloadJson: String) -> Bool {
    guard let data = payloadJson.data(using: .utf8) else {
      return false
    }

    if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
      defaults.set(payloadJson, forKey: "doggylog.widget.snapshot")
      defaults.synchronize()
    }

    do {
      let url = try containerDirectory().appendingPathComponent(snapshotFileName)
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true,
        attributes: nil
      )
      try data.write(to: url, options: .atomic)
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      return true
    } catch {
      return false
    }
  }

  func load() -> String? {
    if let defaults = UserDefaults(suiteName: appGroupIdentifier),
       let snapshot = defaults.string(forKey: "doggylog.widget.snapshot") {
      return snapshot
    }
    guard let url = try? containerDirectory().appendingPathComponent(snapshotFileName) else {
      return nil
    }
    return try? String(contentsOf: url, encoding: .utf8)
  }

  private func containerDirectory() throws -> URL {
    if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
      return url
    }
    let appSupport = try FileManager.default.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    return appSupport.appendingPathComponent("DoggyLogShared", isDirectory: true)
  }
}

final class DoggylogLiveActivityBridge {
  func update(
    payloadJson: String,
    snapshotStore: DoggylogSnapshotStore,
    completion: @escaping (Bool) -> Void
  ) {
    guard snapshotStore.publish(payloadJson: payloadJson) else {
      completion(false)
      return
    }
    #if canImport(ActivityKit)
    if #available(iOS 16.1, *) {
      guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        completion(false)
        return
      }
      guard let snapshot = decodeSnapshot(from: payloadJson) else {
        completion(false)
        return
      }
      guard shouldPresent(snapshot) else {
        end(completion: completion)
        return
      }
      Task {
        let success = await startOrUpdate(snapshot: snapshot)
        DispatchQueue.main.async {
          completion(success)
        }
      }
      return
    }
    #endif
    completion(false)
  }

  func end(completion: @escaping (Bool) -> Void) {
    #if canImport(ActivityKit)
    if #available(iOS 16.1, *) {
      Task {
        let success = await endCurrentActivities()
        DispatchQueue.main.async {
          completion(success)
        }
      }
      return
    }
    #endif
    completion(false)
  }

  private let activityIdKey = "doggylog.liveActivity.id"
  private let defaults = UserDefaults.standard

  private func decodeSnapshot(from payloadJson: String) -> DoggylogActivitySnapshot? {
    guard let data = payloadJson.data(using: .utf8) else {
      return nil
    }
    return try? JSONDecoder().decode(DoggylogActivitySnapshot.self, from: data)
  }

  private func shouldPresent(_ snapshot: DoggylogActivitySnapshot) -> Bool {
    snapshot.today.pendingCount > 0 ||
      snapshot.today.nextTaskTitle != nil ||
      snapshot.countdown != nil ||
      !snapshot.recentTasks.isEmpty
  }

  #if canImport(ActivityKit)
  @available(iOS 16.1, *)
  private func startOrUpdate(snapshot: DoggylogActivitySnapshot) async -> Bool {
    let attributes = DoggylogLiveActivityAttributes(title: "DoggyLog")
    let state = DoggylogLiveActivityAttributes.ContentState(
      petName: snapshot.pet.name,
      petBreed: snapshot.pet.breed,
      petMood: snapshot.pet.mood,
      sceneMode: snapshot.pet.sceneMode,
      pendingCount: snapshot.today.pendingCount,
      completedCount: snapshot.today.completedCount,
      nextTaskTitle: snapshot.today.nextTaskTitle,
      nextTaskTime: snapshot.today.nextTaskTime,
      countdownTitle: snapshot.countdown?.title,
      countdownDaysRemaining: snapshot.countdown?.daysRemaining
    )

    if let activity = currentActivity() {
      await update(activity: activity, state: state)
      return true
    }

    do {
      let activity: Activity<DoggylogLiveActivityAttributes>
      if #available(iOS 16.2, *) {
        let content = ActivityContent(
          state: state,
          staleDate: Date().addingTimeInterval(60 * 60)
        )
        activity = try Activity.request(
          attributes: attributes,
          content: content,
          pushType: nil
        )
      } else {
        activity = try Activity.request(
          attributes: attributes,
          contentState: state,
          pushType: nil
        )
      }
      defaults.set(activity.id, forKey: activityIdKey)
      return true
    } catch {
      return false
    }
  }

  @available(iOS 16.1, *)
  private func update(
    activity: Activity<DoggylogLiveActivityAttributes>,
    state: DoggylogLiveActivityAttributes.ContentState
  ) async {
    if #available(iOS 16.2, *) {
      let content = ActivityContent(
        state: state,
        staleDate: Date().addingTimeInterval(60 * 60)
      )
      await activity.update(content)
    } else {
      await activity.update(using: state)
    }
    defaults.set(activity.id, forKey: activityIdKey)
  }

  @available(iOS 16.1, *)
  private func endCurrentActivities() async -> Bool {
    let activities = Activity<DoggylogLiveActivityAttributes>.activities
    guard !activities.isEmpty else {
      defaults.removeObject(forKey: activityIdKey)
      return true
    }
    for activity in activities {
      if #available(iOS 16.2, *) {
        let content = ActivityContent(
          state: activity.content.state,
          staleDate: Date()
        )
        await activity.end(content, dismissalPolicy: .immediate)
      } else {
        await activity.end(using: activity.contentState, dismissalPolicy: .immediate)
      }
    }
    defaults.removeObject(forKey: activityIdKey)
    return true
  }

  @available(iOS 16.1, *)
  private func currentActivity() -> Activity<DoggylogLiveActivityAttributes>? {
    if let storedId = defaults.string(forKey: activityIdKey),
       let storedActivity = Activity<DoggylogLiveActivityAttributes>.activities.first(where: { $0.id == storedId }) {
      return storedActivity
    }
    if let existing = Activity<DoggylogLiveActivityAttributes>.activities.first {
      defaults.set(existing.id, forKey: activityIdKey)
      return existing
    }
    return nil
  }
  #endif
}

struct DoggylogActivitySnapshot: Decodable {
  let generatedAt: Int
  let today: DoggylogActivityToday
  let pet: DoggylogActivityPet
  let countdown: DoggylogActivityCountdown?
  let recentTasks: [DoggylogActivityTask]
}

struct DoggylogActivityToday: Decodable {
  let pendingCount: Int
  let completedCount: Int
  let nextTaskTitle: String?
  let nextTaskTime: String?
}

struct DoggylogActivityPet: Decodable {
  let name: String
  let breed: String
  let mood: String
  let loyaltyLevel: Int
  let sceneMode: String
}

struct DoggylogActivityCountdown: Decodable {
  let title: String
  let dueAt: Int
  let daysRemaining: Int
}

struct DoggylogActivityTask: Decodable {
  let title: String
  let time: String
  let category: String
  let completed: Bool
}

#if canImport(ActivityKit)
@available(iOS 16.1, *)
struct DoggylogLiveActivityAttributes: ActivityAttributes {
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
#endif

final class DoggylogMotionService {
  private let manager = CMMotionManager()
  private let queue = OperationQueue()

  func start(onSample: @escaping ([String: Double]) -> Void) -> Bool {
    stop()
    guard manager.isDeviceMotionAvailable else {
      return false
    }
    queue.name = "com.timmy.doggylog.motion"
    queue.qualityOfService = .userInteractive
    manager.deviceMotionUpdateInterval = 1.0 / 30.0
    manager.startDeviceMotionUpdates(to: queue) { motion, _ in
      guard let motion else { return }
      let pitch = max(min(motion.attitude.pitch / (.pi / 3.0), 1), -1)
      let roll = max(min(motion.attitude.roll / (.pi / 3.0), 1), -1)
      let depth = max(min(motion.gravity.z, 1), -1)
      DispatchQueue.main.async {
        onSample([
          "x": roll,
          "y": pitch,
          "depth": depth
        ])
      }
    }
    return true
  }

  func stop() {
    if manager.isDeviceMotionActive {
      manager.stopDeviceMotionUpdates()
    }
  }
}

final class DoggylogEventKitService {
  private let eventStore = EKEventStore()
  private let userDefaults = UserDefaults.standard
  private let calendarIdentifierKey = "doggylog.eventkit.calendarIdentifier"
  private let localIdPrefix = "DoggyLogLocalID:"

  func isAvailable() -> Bool {
    if #available(iOS 17.0, *) {
      return EKEventStore.authorizationStatus(for: .event) == .fullAccess
    } else {
      return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
  }

  func requestAccess(completion: @escaping (Bool) -> Void) {
    if #available(iOS 17.0, *) {
      eventStore.requestFullAccessToEvents { granted, _ in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    } else {
      eventStore.requestAccess(to: .event) { granted, _ in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    }
  }

  func getSystemCalendars(completion: @escaping (String) -> Void) {
    requestAccess { [weak self] granted in
      guard let self, granted else {
        completion("[]")
        return
      }
      let payload = self.eventStore.calendars(for: .event)
        .sorted { lhs, rhs in
          if lhs.source.title == rhs.source.title {
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
          }
          return lhs.source.title.localizedCaseInsensitiveCompare(rhs.source.title) == .orderedAscending
        }
        .map { calendar in
          [
            "id": calendar.calendarIdentifier,
            "title": calendar.title,
            "sourceTitle": calendar.source.title,
            "colorHex": self.hexString(from: calendar.cgColor),
            "allowsContentModifications": calendar.allowsContentModifications
          ]
        }
      completion(self.jsonString(from: payload))
    }
  }

  func importCalendarItems(selectedCalendarIds: [String]?, completion: @escaping (String) -> Void) {
    requestAccess { [weak self] granted in
      guard let self, granted else {
        completion("[]")
        return
      }
      let calendars = self.filteredCalendars(selectedCalendarIds: selectedCalendarIds)
      let start = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
      let end = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
      let predicate = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
      let events = self.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
      let payload = events.map { self.serialize(event: $0) }
      completion(self.jsonString(from: payload))
    }
  }

  func syncCalendarDelta(
    updatedAfterMillis: Int?,
    selectedCalendarIds: [String]?,
    completion: @escaping (String) -> Void
  ) {
    requestAccess { [weak self] granted in
      guard let self, granted else {
        completion("")
        return
      }
      let calendars = self.filteredCalendars(selectedCalendarIds: selectedCalendarIds)
      let start = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
      let end = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
      let predicate = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
      let events = self.eventStore.events(matching: predicate)
      let cursor = updatedAfterMillis.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
      let changedEvents = events
        .filter { event in
          guard let cursor else { return true }
          let updatedAt = event.lastModifiedDate ?? event.creationDate ?? event.startDate ?? Date()
          return updatedAt >= cursor
        }
        .sorted { $0.startDate < $1.startDate }

      let payload: [String: Any] = [
        "items": changedEvents.map { self.serialize(event: $0) },
        "visibleSystemEntryIds": events.compactMap(\.eventIdentifier),
        "syncedAt": Int(Date().timeIntervalSince1970 * 1000)
      ]
      completion(self.jsonString(from: payload))
    }
  }

  func upsertCalendarItem(payloadJson: String, completion: @escaping (String?) -> Void) {
    requestAccess { [weak self] granted in
      guard let self, granted else {
        completion(nil)
        return
      }
      guard
        let data = payloadJson.data(using: .utf8),
        let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let calendar = try? self.ensureDoggylogCalendar()
      else {
        completion(nil)
        return
      }

      let systemEntryId = payload["systemEntryId"] as? String
      let localId = payload["id"] as? String
      let event = self.resolveEvent(systemEntryId: systemEntryId, localId: localId) ?? EKEvent(eventStore: self.eventStore)
      event.calendar = calendar
      event.title = payload["title"] as? String ?? "DoggyLog 任务"

      let startMs = payload["startAt"] as? Int ?? Int(Date().timeIntervalSince1970 * 1000)
      let endMs = payload["endAt"] as? Int ?? (startMs + 30 * 60 * 1000)
      event.startDate = Date(timeIntervalSince1970: TimeInterval(startMs) / 1000)
      event.endDate = Date(timeIntervalSince1970: TimeInterval(endMs) / 1000)

      let description = payload["description"] as? String ?? ""
      event.notes = self.notes(localId: localId, description: description)
      event.isAllDay = false
      event.alarms = []
      if let reminders = payload["reminders"] as? [[String: Any]] {
        for reminder in reminders {
          let minutes = reminder["offsetMinutes"] as? Int ?? 15
          event.addAlarm(EKAlarm(relativeOffset: TimeInterval(-minutes * 60)))
        }
      }

      do {
        try self.eventStore.save(event, span: .thisEvent, commit: true)
        completion(event.eventIdentifier)
      } catch {
        completion(nil)
      }
    }
  }

  private func filteredCalendars(selectedCalendarIds: [String]?) -> [EKCalendar] {
    let calendars = eventStore.calendars(for: .event)
    guard let selectedCalendarIds else {
      return calendars
    }
    guard !selectedCalendarIds.isEmpty else {
      return []
    }
    let selectedIds = Set(selectedCalendarIds)
    return calendars.filter { selectedIds.contains($0.calendarIdentifier) }
  }

  func deleteCalendarItem(systemEntryId: String?, localId: String?, completion: @escaping (Bool) -> Void) {
    requestAccess { [weak self] granted in
      guard let self, granted else {
        completion(false)
        return
      }
      guard let event = self.resolveEvent(systemEntryId: systemEntryId, localId: localId) else {
        completion(false)
        return
      }
      do {
        try self.eventStore.remove(event, span: .thisEvent, commit: true)
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  private func ensureDoggylogCalendar() throws -> EKCalendar {
    if
      let identifier = userDefaults.string(forKey: calendarIdentifierKey),
      let calendar = eventStore.calendar(withIdentifier: identifier)
    {
      return calendar
    }

    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = "DoggyLog"
    calendar.cgColor = UIColor.systemOrange.cgColor
    calendar.source = eventStore.defaultCalendarForNewEvents?.source ?? preferredSource()
    try eventStore.saveCalendar(calendar, commit: true)
    userDefaults.set(calendar.calendarIdentifier, forKey: calendarIdentifierKey)
    return calendar
  }

  private func preferredSource() -> EKSource {
    if let source = eventStore.sources.first(where: { $0.sourceType == .calDAV }) {
      return source
    }
    if let source = eventStore.sources.first(where: { $0.sourceType == .local }) {
      return source
    }
    return eventStore.sources.first!
  }

  private func resolveEvent(systemEntryId: String?, localId: String?) -> EKEvent? {
    if let systemEntryId, let event = eventStore.event(withIdentifier: systemEntryId) {
      return event
    }
    guard let localId else {
      return nil
    }
    let start = Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date()
    let end = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
    let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: eventStore.calendars(for: .event))
    return eventStore.events(matching: predicate).first(where: { ($0.notes ?? "").contains("\(localIdPrefix)\(localId)") })
  }

  private func serialize(event: EKEvent) -> [String: Any] {
    let startAt = Int(event.startDate.timeIntervalSince1970 * 1000)
    let endAt = Int(event.endDate.timeIntervalSince1970 * 1000)
    let description = normalizedDescription(notes: event.notes)
    let reminders = (event.alarms ?? []).compactMap { alarm -> [String: Any]? in
      guard alarm.relativeOffset != 0 else { return nil }
      return [
        "offsetMinutes": Int(abs(alarm.relativeOffset) / 60),
        "channels": ["inApp", "push"]
      ]
    }

    return [
      "id": UUID().uuidString,
      "title": event.title ?? "系统日历事件",
      "description": description,
      "startAt": startAt,
      "endAt": endAt,
      "category": inferCategory(title: event.title ?? "", description: description),
      "petId": NSNull(),
      "reminders": reminders,
      "source": "iosCalendar",
      "createdAt": Int((event.creationDate ?? event.startDate).timeIntervalSince1970 * 1000),
      "updatedAt": Int((event.lastModifiedDate ?? event.startDate).timeIntervalSince1970 * 1000),
      "systemEntryId": event.eventIdentifier ?? NSNull(),
      "isCompleted": false,
      "isDeleted": false
    ]
  }

  private func inferCategory(title: String, description: String) -> String {
    let text = "\(title) \(description)".lowercased()
    if text.contains("遛") || text.contains("狗") || text.contains("宠") || text.contains("疫苗") {
      return "pet"
    }
    if text.contains("生日") || text.contains("纪念") {
      return "anniversary"
    }
    if text.contains("会议") || text.contains("工作") || text.contains("评审") {
      return "work"
    }
    return "daily"
  }

  private func notes(localId: String?, description: String) -> String {
    var parts: [String] = []
    if let localId {
      parts.append("\(localIdPrefix)\(localId)")
    }
    if !description.isEmpty {
      parts.append(description)
    }
    return parts.joined(separator: "\n")
  }

  private func normalizedDescription(notes: String?) -> String {
    guard let notes, !notes.isEmpty else {
      return ""
    }
    return notes
      .split(separator: "\n")
      .filter { !$0.hasPrefix(localIdPrefix) }
      .joined(separator: "\n")
  }

  private func hexString(from color: CGColor) -> String {
    let converted = UIColor(cgColor: color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return "#C7CDD8"
    }
    return String(
      format: "#%02X%02X%02X",
      Int(red * 255),
      Int(green * 255),
      Int(blue * 255)
    )
  }

  private func jsonString(from object: Any) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: object) else {
      return "[]"
    }
    return String(data: data, encoding: .utf8) ?? "[]"
  }
}
