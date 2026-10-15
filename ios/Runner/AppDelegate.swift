import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Keep personal records and downloaded content on this device. Exported
    // copies are handed to the user's chosen share destination separately.
    do {
      try LocalDataBackupPolicy.apply()
    } catch {
      NSLog("Quran Haven: unable to exclude internal storage from backup: %@", String(describing: error))
    }
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

enum LocalDataBackupPolicy {
  static func storageDirectories(fileManager: FileManager = .default) throws -> [URL] {
    let documents = try fileManager.url(
      for: .documentDirectory, in: .userDomainMask,
      appropriateFor: nil, create: true)
    let library = try fileManager.url(
      for: .libraryDirectory, in: .userDomainMask,
      appropriateFor: nil, create: true)
    // Excluding the parent directories also covers future GetStorage, audio,
    // text-resource and UserDefaults files without changing existing paths.
    return [documents, library]
  }

  static func apply(fileManager: FileManager = .default) throws {
    for var directory in try storageDirectories(fileManager: fileManager) {
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try directory.setResourceValues(values)
    }
  }
}
