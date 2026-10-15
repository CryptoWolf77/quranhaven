import Flutter
import UIKit
import UserNotifications
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testInternalStorageIsExcludedFromSystemBackup() throws {
    // Check the real app sandbox after AppDelegate launches, including the
    // parent of UserDefaults. This is metadata verification, not an iCloud
    // backup/restore claim.
    let directories = try LocalDataBackupPolicy.storageDirectories()
    XCTAssertEqual(directories.count, 2)
    for directory in directories {
      let values = try directory.resourceValues(forKeys: [.isExcludedFromBackupKey])
      XCTAssertEqual(values.isExcludedFromBackup, true, directory.lastPathComponent)
    }
    // Reapplying must preserve existing local records.
    let fixture = directories[0].appendingPathComponent("ios-backup-policy-test.json")
    defer { try? FileManager.default.removeItem(at: fixture) }
    let bytes = Data("{\"fixture\":true}".utf8)
    try bytes.write(to: fixture, options: .atomic)
    try LocalDataBackupPolicy.apply()
    XCTAssertEqual(try Data(contentsOf: fixture), bytes)
  }

  func testForegroundNotificationDelegateIsRegistered() {
    XCTAssertTrue(UNUserNotificationCenter.current().delegate === UIApplication.shared.delegate)
  }

}
