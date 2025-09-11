import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let timestamp = Date().timeIntervalSince1970
    print("🚀 iOS App [\(timestamp)]: didFinishLaunchingWithOptions called")
    logBuildConfiguration()
    
    // CRITICAL: Configure Firebase FIRST - FCM v1 requirement
    FirebaseApp.configure()
    print("🔥 iOS App [\(timestamp)]: Firebase configured for FCM v1 API")
    
    // CRITICAL: Push notifications setup - ONLY in Release builds (production)
    #if !DEBUG
    // CRITICAL: Set UNUserNotificationCenter delegate BEFORE requesting permissions
    UNUserNotificationCenter.current().delegate = self
    print("📨 iOS App [\(timestamp)]: UNUserNotificationCenter delegate set (PRODUCTION)")
    
    // CRITICAL: Set FCM messaging delegate for token handling
    Messaging.messaging().delegate = self
    print("📨 iOS App [\(timestamp)]: Firebase Messaging delegate set (PRODUCTION)")
    
    // Ensure APNs token registration happens ASAP (works even if alerts are disabled)
    DispatchQueue.main.async {
      application.registerForRemoteNotifications()
      NSLog("REGISTER_FOR_REMOTE_NOTIFICATIONS: invoked at launch (PRODUCTION)")
    }
    
    // CRITICAL: Request notification permissions with proper iOS settings for FCM v1
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        let ts = Date().timeIntervalSince1970
        print("🔔 iOS App [\(ts)]: Notification permission granted: \(granted) (PRODUCTION)")
        if let error = error {
          print("❌ iOS App [\(ts)]: Notification permission error: \(error)")
        }
        
        // Attempt registration again after permission flow for safety
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
          print("📱 iOS App [\(ts)]: Registered for remote notifications (post-permission attempt) (PRODUCTION)")
        }
      }
    )
    #else
    print("🚫 iOS App [\(timestamp)]: Push notifications DISABLED in DEBUG mode")
    #endif
    
    // Check if app was launched from notification (critical for analytics)
    if let notificationOption = launchOptions?[.remoteNotification] {
      print("🚀 iOS App [\(timestamp)]: Launched from notification: \(notificationOption)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    print("✅ iOS App [\(timestamp)]: App delegate setup completed")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // CRITICAL: Handle APNs token registration - FCM v1 requirement
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let timestamp = Date().timeIntervalSince1970
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    
    print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢")
    print("📱 iOS App [\(timestamp)]: APNs token SUCCESS! 📱")
    print("📱 APNs Token: \(token)")
    print("📱 Token Length: \(token.count) characters")
    print("📱 Token Starts: \(String(token.prefix(20)))...")
    print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢")
    
    // CRITICAL: Set APNs token to Firebase Messaging for FCM v1 API
    Messaging.messaging().apnsToken = deviceToken
    print("🔥 iOS App [\(timestamp)]: APNs token set to Firebase Messaging")
    
    // Force FCM token refresh after APNs token is set
    Messaging.messaging().deleteToken { [weak self] error in
      if let error = error {
        print("❌ iOS App: Error deleting FCM token: \(error)")
      } else {
        print("✅ iOS App: FCM token deleted, will regenerate with new APNs token")
        // Token will automatically regenerate via MessagingDelegate
      }
    }
  }
  
  // CRITICAL: Handle APNs token registration failure
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    let timestamp = Date().timeIntervalSince1970
    print("🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴")
    print("❌ iOS App [\(timestamp)]: APNs REGISTRATION FAILED! ❌")
    print("❌ Error: \(error)")
    print("❌ Error Code: \((error as NSError).code)")
    print("❌ Error Domain: \((error as NSError).domain)")
    print("🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴")
  }
  
  // CRITICAL: Handle remote notification received
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    print("📨 iOS App: didReceiveRemoteNotification called")
    print("📨 iOS App: Notification payload: \(userInfo)")
  }
  
  // CRITICAL: Handle remote notification with completion handler
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let timestamp = Date().timeIntervalSince1970
    print("📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨")
    print("📨 iOS App [\(timestamp)]: BACKGROUND/KILLED NOTIFICATION 📨")
    print("📨 UserInfo: \(userInfo)")
    print("📨 Application State: \(application.applicationState.rawValue)")
    print("📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨📨")
    
    // CRITICAL: Tell Firebase Messaging about this notification
    Messaging.messaging().appDidReceiveMessage(userInfo)
    
    completionHandler(.newData)
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let timestamp = Date().timeIntervalSince1970
    
    print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥")
    print("🔥 iOS App [\(timestamp)]: FCM TOKEN RECEIVED (v1 API)! 🔥")
    print("🔥 FCM Token: \(fcmToken ?? "NIL")")
    if let token = fcmToken {
      print("🔥 Token Length: \(token.count) characters")
      print("🔥 Token Starts: \(String(token.prefix(30)))...")
    }
    print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥")
    
    // Also use NSLog for production logging
    if let token = fcmToken {
      NSLog("FCM_TOKEN_IOS: %@", token)
    }
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
    
    print("✅ iOS App [\(timestamp)]: FCM token notification posted to Flutter")
  }
  
  // NOTE: MessagingDelegate doesn't have a didReceive method for direct messages
  // FCM messages are handled through the standard APNs system and UNUserNotificationCenter
  // This delegate is only for token registration
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Log current build configuration (use external codesign check for entitlements)
  private func logBuildConfiguration() {
    #if DEBUG
      NSLog("BUILD_CONFIGURATION: DEBUG")
    #else
      NSLog("BUILD_CONFIGURATION: RELEASE")
    #endif
  }
  // CRITICAL: Override willPresent to show notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let timestamp = Date().timeIntervalSince1970
    let userInfo = notification.request.content.userInfo
    
    print("📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱")
    print("📱 iOS App [\(timestamp)]: FOREGROUND NOTIFICATION 📱")
    print("📱 Title: \(notification.request.content.title)")
    print("📱 Body: \(notification.request.content.body)")
    print("📱 Badge: \(notification.request.content.badge ?? 0)")
    print("📱 Sound: \(notification.request.content.sound != nil ? "custom" : "default")")
    print("📱 UserInfo: \(userInfo)")
    print("📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱")
    
    // CRITICAL: Show notifications with all presentation options in foreground
    // This ensures notifications are visible even when app is active
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound, .list])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }
  
  // CRITICAL: Override didReceive to handle notification taps
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let timestamp = Date().timeIntervalSince1970
    let userInfo = response.notification.request.content.userInfo
    
    print("🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀")
    print("🚀 iOS App [\(timestamp)]: NOTIFICATION TAPPED! 🚀")
    print("🚀 Action ID: \(response.actionIdentifier)")
    print("🚀 Title: \(response.notification.request.content.title)")
    print("🚀 Body: \(response.notification.request.content.body)")
    print("🚀 UserInfo: \(userInfo)")
    print("🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀")
    
    // Handle different action types
    switch response.actionIdentifier {
    case UNNotificationDefaultActionIdentifier:
      print("🚀 iOS App: Default action (tap) performed")
    case UNNotificationDismissActionIdentifier:
      print("🚀 iOS App: Notification dismissed")
    default:
      print("🚀 iOS App: Custom action performed: \(response.actionIdentifier)")
    }
    
    completionHandler()
  }
}
