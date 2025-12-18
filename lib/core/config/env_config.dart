import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../constants/environment_constants.dart';
import '../../utils/app_logger.dart';

/// Environment types for the app
enum Environment {
  production,
  test,
  development,
}

class EnvConfig {
  static final log = scopedLogger(LogCategory.service);

  /// The currently loaded environment
  static Environment _currentEnvironment = Environment.development;

  /// Get the current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Check if app is running in production environment
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Check if app is running in test or development environment
  static bool get isTestOrDev => _currentEnvironment == Environment.test || _currentEnvironment == Environment.development;

  /// Get a display name for the current environment
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.production:
        return 'PRODUCTION';
      case Environment.test:
        return 'TEST';
      case Environment.development:
        return 'DEVELOPMENT';
    }
  }

  static Future<void> load() async {
    AppLogger.logSeparator('EnvConfig.load');

    // Læs miljø fra EnvironmentConstants (den variabel du ændrer i koden)
    final envName = _getEnvNameFromConstant();
    log('📋 EnvironmentConstants.activeEnvironment: ${EnvironmentConstants.activeEnvironment.name}');
    log('📋 Resolved env name: $envName');

    // Set the current environment
    _currentEnvironment = _parseEnvironment(envName);

    final fileName = '.env.$envName';

    log('🔧 Loading environment file: $fileName');
    log('🌍 Environment: ${_currentEnvironment.name.toUpperCase()}');

    try {
      await dotenv.load(fileName: fileName);
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      log('✅ Environment loaded successfully');
      log('🔑 Supabase URL: $supabaseUrl');
      log('🔑 Supabase Anon Key (first 30 chars): ${anonKey.length > 30 ? anonKey.substring(0, 30) + '...' : anonKey}');

      // Verify which database we're pointing to
      if (supabaseUrl.contains('iehraurjkiqqjmemrfdl')) {
        log('✅ Verified: Pointing to TEST database');
      } else if (supabaseUrl.contains('nzggkotdqyyefjsynhlm')) {
        log('⚠️ WARNING: Pointing to PRODUCTION database!');
      } else {
        log('❓ Unknown database URL');
      }

      // Safety check: Prevent release builds with non-production environment
      if (kReleaseMode && _currentEnvironment != Environment.production) {
        throw StateError(
          '🚨 FATAL: Cannot run release build with ${_currentEnvironment.name.toUpperCase()} environment! '
          'Release builds MUST use production environment. '
          'Ændre EnvironmentConstants.activeEnvironment til AppEnvironment.production',
        );
      }
    } catch (e) {
      log('❌ Error loading environment: $e');
      rethrow;
    }
  }

  /// Get environment name from the constant in EnvironmentConstants
  static String _getEnvNameFromConstant() {
    switch (EnvironmentConstants.activeEnvironment) {
      case AppEnvironment.production:
        return 'production';
      case AppEnvironment.test:
        return 'test';
      case AppEnvironment.development:
        return 'development';
    }
  }

  /// Parse environment string to Environment enum
  static Environment _parseEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'production':
        return Environment.production;
      case 'test':
        return Environment.test;
      case 'development':
      default:
        return Environment.development;
    }
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Get the actual environment based on the current Supabase URL
  /// This ensures the banner always shows the correct environment based on actual database connection
  static Environment get actualEnvironment {
    final url = supabaseUrl;
    if (url.contains('nzggkotdqyyefjsynhlm')) {
      return Environment.production;
    } else if (url.contains('iehraurjkiqqjmemrfdl')) {
      // Both test and development use the same TEST database
      // Use the configured environment to distinguish between test and development
      return _currentEnvironment;
    }
    // Fallback to configured environment if URL doesn't match known databases
    return _currentEnvironment;
  }

  /// Get display name based on actual database connection
  static String get actualEnvironmentName {
    switch (actualEnvironment) {
      case Environment.production:
        return 'PRODUCTION';
      case Environment.test:
        return 'TEST';
      case Environment.development:
        return 'DEVELOPMENT';
    }
  }

  /// Check if actually connected to production (based on URL)
  static bool get isActuallyProduction => actualEnvironment == Environment.production;
}

// Created: 2025-12-17
