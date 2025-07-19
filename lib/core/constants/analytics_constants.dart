abstract class AnalyticsConstants {
  const AnalyticsConstants._();

  // Analytics configuration
  static const String saltKey = 'analytics_salt_key_secure_2024';
  static const bool sendToAnalyticsWhileInDebug = true;

  // MixPanel configuration (environment-specific)
  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '9982a060adb28f99fb278a97291cbfe8', // Empty default - must be provided via environment
  );
}

// Created on 2024-12-30 at 16:30
