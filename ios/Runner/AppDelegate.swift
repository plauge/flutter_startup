import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("🚀 iOS App: didFinishLaunchingWithOptions called")
    
    // Configure Firebase
    FirebaseApp.configure()
    print("🔥 iOS App: Firebase configured")
    
    // Set messaging delegate
    Messaging.messaging().delegate = self
    print("📨 iOS App: Messaging delegate set")
    
    // Request notification permissions
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        print("🔔 iOS App: Notification permission granted: \(granted), error: \(String(describing: error))")
      }
    )
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    print("📱 iOS App: Registered for remote notifications")
    
    // Check if app was launched from notification
    if let notificationOption = launchOptions?[.remoteNotification] {
      print("🚀 iOS App: Launched from notification: \(notificationOption)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNs token registration
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("📱 iOS App: APNs token registered successfully: \(token)")
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // Handle APNs token registration failure
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ iOS App: Failed to register for remote notifications: \(error)")
  }
  
  // CRITICAL: Handle remote notification received
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    print("📨 iOS App: didReceiveRemoteNotification called")
    print("📨 iOS App: Notification payload: \(userInfo)")
  }
  
  // CRITICAL: Handle remote notification with completion handler
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("📨 iOS App: didReceiveRemoteNotification with completion handler called")
    print("📨 iOS App: Notification payload: \(userInfo)")
    completionHandler(.newData)
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 iOS App: FCM registration token received: \(fcmToken ?? "nil")")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Override willPresent to show notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    print("📱 iOS App: Will present notification (FOREGROUND)")
    print("📱 iOS App: Title: \(notification.request.content.title)")
    print("📱 iOS App: Body: \(notification.request.content.body)")
    print("📱 iOS App: UserInfo: \(userInfo)")
    
    // Show notifications even when app is in foreground
    completionHandler([[.banner, .badge, .sound]])
  }
  
  // Override didReceive to handle notification taps
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    print("🚀 iOS App: Did receive notification response (TAPPED)")
    print("🚀 iOS App: UserInfo: \(userInfo)")
    
    completionHandler()
  }
}
