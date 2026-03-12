import Flutter
import ImageIO
import UIKit
import XCTest
@testable import Runner

final class RunnerTests: XCTestCase {

  func testSnapshotStorePublishReturnsFalseWhenSharedContainerUnavailable() {
    let store = DoggylogSnapshotStore(
      containerURLProvider: { _ in nil },
      reloadTimelines: {}
    )

    XCTAssertFalse(store.publish(payloadJson: #"{"pet":"mochi"}"#))
  }

  func testSnapshotStorePublishWritesSnapshotIntoSharedContainer() throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let payload = #"{"pet":"mochi","today":{"pendingCount":1}}"#
    let store = DoggylogSnapshotStore(
      containerURLProvider: { _ in tempDirectory },
      reloadTimelines: {}
    )

    XCTAssertTrue(store.publish(payloadJson: payload))

    let fileURL = tempDirectory.appendingPathComponent("doggylog_widget_snapshot.json")
    let storedPayload = try String(contentsOf: fileURL, encoding: .utf8)
    XCTAssertEqual(storedPayload, payload)
  }

  func testSnapshotStorePublishFallsBackToApplicationSupportWhenSharedContainerUnavailable() throws {
    let appSupport = try FileManager.default.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let fallbackDirectory = appSupport.appendingPathComponent("DoggyLogShared", isDirectory: true)
    let fileURL = fallbackDirectory.appendingPathComponent("doggylog_widget_snapshot.json")
    try? FileManager.default.removeItem(at: fallbackDirectory)

    let payload = #"{"pet":"mochi","today":{"pendingCount":1}}"#
    let store = DoggylogSnapshotStore(
      containerURLProvider: { _ in nil },
      reloadTimelines: {}
    )

    XCTAssertTrue(store.publish(payloadJson: payload))

    let storedPayload = try String(contentsOf: fileURL, encoding: .utf8)
    XCTAssertEqual(storedPayload, payload)
  }

  func testWidgetDogImageStaysWithinWidgetSnapshotLimits() throws {
    let imageFileNames = [
      "calendar_dog_timeline",
      "calendar_dog1_timeline",
      "calendar_dog2_timeline",
      "calendar_dog3_timeline",
    ]

    for imageFileName in imageFileNames {
      let imageURL = widgetAssetURL(named: imageFileName)

      let source = try XCTUnwrap(CGImageSourceCreateWithURL(imageURL as CFURL, nil))
      let properties = try XCTUnwrap(
        CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
      )
      let width = try XCTUnwrap(properties[kCGImagePropertyPixelWidth] as? Int)
      let height = try XCTUnwrap(properties[kCGImagePropertyPixelHeight] as? Int)

      XCTAssertLessThanOrEqual(width, 640, "\(imageFileName) should stay within widget archive limits")
      XCTAssertLessThanOrEqual(height, 640, "\(imageFileName) should stay within widget archive limits")
    }
  }

  func testLiveActivityPresentationRequiresCountdown() {
    let snapshotWithoutCountdown = DoggylogActivitySnapshot(
      generatedAt: 1,
      today: DoggylogActivityToday(
        pendingCount: 2,
        completedCount: 0,
        nextTaskTitle: "疫苗到期提醒",
        nextTaskTime: "01:27",
        nextTaskId: "task-1"
      ),
      pet: DoggylogActivityPet(
        name: "Mochi",
        breed: "Shiba",
        mood: "calm",
        loyaltyLevel: 3,
        sceneMode: "home"
      ),
      countdown: nil,
      recentTasks: []
    )
    let snapshotWithCountdown = DoggylogActivitySnapshot(
      generatedAt: 1,
      today: DoggylogActivityToday(
        pendingCount: 5,
        completedCount: 0,
        nextTaskTitle: "去长隆乐园",
        nextTaskTime: "12:00",
        nextTaskId: "task-2"
      ),
      pet: DoggylogActivityPet(
        name: "Mochi",
        breed: "Shiba",
        mood: "excited",
        loyaltyLevel: 3,
        sceneMode: "walking"
      ),
      countdown: DoggylogActivityCountdown(
        title: "Mochi 生日",
        dueAt: 1,
        daysRemaining: 28
      ),
      recentTasks: []
    )

    XCTAssertFalse(DoggylogLiveActivityPresentation.shouldPresent(snapshotWithoutCountdown))
    XCTAssertTrue(DoggylogLiveActivityPresentation.shouldPresent(snapshotWithCountdown))
  }

  func testLiveActivitySelectionPrefersStoredActivityIdAndMarksDuplicates() {
    let selection = DoggylogLiveActivitySelection.resolve(
      storedId: "activity-b",
      activityIds: ["activity-a", "activity-b", "activity-c"]
    )

    XCTAssertEqual(selection.primaryId, "activity-b")
    XCTAssertEqual(selection.staleIds, ["activity-a", "activity-c"])
  }

  func testLiveActivitySelectionFallsBackToFirstActivityWhenStoredIdMissing() {
    let selection = DoggylogLiveActivitySelection.resolve(
      storedId: "activity-missing",
      activityIds: ["activity-a", "activity-b"]
    )

    XCTAssertEqual(selection.primaryId, "activity-a")
    XCTAssertEqual(selection.staleIds, ["activity-b"])
  }

  private func widgetAssetURL(named imageFileName: String) -> URL {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let iosDirectory = testFileURL
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    return iosDirectory
      .appendingPathComponent("DoggyLogWidgets/Assets.xcassets/\(imageFileName).imageset/\(imageFileName).png")
  }
}
