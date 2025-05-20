// Denne kode bruges ikke endnu!

abstract class AppConstants {
  const AppConstants._();

  // App-wide constants (rarely change)
  static const String appName = 'FlutterStartup';
  static const String supportEmail = 'support@example.com';
  static const int apiTimeoutSeconds = 30;
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';

  // API related
  static const int maxRetryAttempts = 3;
  static const int defaultPageSize = 20;

  // UI related
  static const int animationDurationMs = 300;
  static const double minPasswordLength = 8;
}
