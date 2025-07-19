abstract class AnalyticsConstants {
  const AnalyticsConstants._();

  // Analytics configuration
  static const String saltKey = 'analytics_salt_key_secure_2024';
  static const bool sendToAnalyticsWhileInDebug = false;

  // MixPanel configuration (environment-specific)
  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '', // Empty default - must be provided via environment
  );

  // Backup token for development (if needed)
  static const String mixpanelDevToken = String.fromEnvironment(
    'MIXPANEL_DEV_TOKEN',
    defaultValue: '',
  );
}

// Created on 2024-12-30 at 16:30
