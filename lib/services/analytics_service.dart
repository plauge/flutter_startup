import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../core/constants/analytics_constants.dart';
import '../utils/app_logger.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static final log = scopedLogger(LogCategory.service);

  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Mixpanel? _mixpanel;
  bool _isInitialized = false;

  Future<void> initialize() async {
    log('lib/services/analytics_service.dart - initialize() called, _isInitialized: $_isInitialized');

    if (_isInitialized) {
      log('lib/services/analytics_service.dart - initialize() already initialized, returning early');
      return;
    }

    // RYD AL CACHE FØRST for at sikre ren start
    if (_mixpanel != null) {
      log('lib/services/analytics_service.dart - initialize() clearing existing MixPanel cache...');
      _clearAllMixPanelCache();
    }

    try {
      log('lib/services/analytics_service.dart - kDebugMode: $kDebugMode, sendToAnalyticsWhileInDebug: ${AnalyticsConstants.sendToAnalyticsWhileInDebug}');

      if (kDebugMode && !AnalyticsConstants.sendToAnalyticsWhileInDebug) {
        log('lib/services/analytics_service.dart - Skipping analytics in debug mode');
        _isInitialized = true;
        return;
      }

      final token = kDebugMode
          ? AnalyticsConstants.mixpanelDevToken.isNotEmpty
              ? AnalyticsConstants.mixpanelDevToken
              : AnalyticsConstants.mixpanelToken
          : AnalyticsConstants.mixpanelToken;

      log('lib/services/analytics_service.dart - Token selected: ${token.isEmpty ? 'EMPTY' : 'PROVIDED'} (length: ${token.length})');

      if (token.isEmpty) {
        log('lib/services/analytics_service.dart - Token is empty, marking as initialized but without Mixpanel');
        _isInitialized = true;
        return;
      }

      log('lib/services/analytics_service.dart - Initializing MixPanel with CLEAN STATE...');
      _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: false);
      log('lib/services/analytics_service.dart - Mixpanel initialized successfully with clean state');
      _isInitialized = true;
    } catch (error) {
      log('lib/services/analytics_service.dart - Failed to initialize: $error');
      _isInitialized = true;
    }
  }

  String _saltedHash(String data) {
    final combined = AnalyticsConstants.saltKey + data.toLowerCase().trim();
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    log('lib/services/analytics_service.dart - _saltedHash() generated hash for data');
    return digest.toString();
  }

  void identify(String email, [Map<String, dynamic>? properties]) {
    log('lib/services/analytics_service.dart - identify() called with email, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - identify() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      final hashedUserId = _saltedHash(email);
      log('lib/services/analytics_service.dart - identify() calling _mixpanel.identify()');
      _mixpanel!.identify(hashedUserId);

      if (properties != null) {
        log('lib/services/analytics_service.dart - identify() setting ${properties.length} user properties');
        final sanitizedProperties = _sanitizeProperties(properties);
        for (final entry in sanitizedProperties.entries) {
          _mixpanel!.getPeople().set(entry.key, entry.value);
        }
        log('lib/services/analytics_service.dart - identify() user properties set successfully');
      }
    } catch (error) {
      log('lib/services/analytics_service.dart - Identify error: $error');
    }
  }

  void track(String eventName, [Map<String, dynamic>? properties]) {
    log('lib/services/analytics_service.dart - track() called with event: $eventName, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - track() early return - not initialized or mixpanel is null');
      log('lib/services/analytics_service.dart - track() detailed state: _isInitialized=$_isInitialized, _mixpanel is ${_mixpanel?.runtimeType ?? 'null'}');

      // Prøv at re-initialisere hvis noget gik galt
      log('lib/services/analytics_service.dart - track() attempting re-initialization...');
      _forceReinitialize();

      // Tjek igen efter re-initialization
      if (!_isInitialized || _mixpanel == null) {
        log('lib/services/analytics_service.dart - track() re-initialization failed, giving up');
        return;
      }
      log('lib/services/analytics_service.dart - track() re-initialization successful, continuing with track');
    }

    try {
      final sanitizedProperties = properties != null ? _sanitizeProperties(properties) : <String, dynamic>{};
      log('lib/services/analytics_service.dart - track() calling _mixpanel.track() with ${sanitizedProperties.length} properties');

      _mixpanel!.track(eventName, properties: sanitizedProperties);
      log('lib/services/analytics_service.dart - track() event sent successfully: $eventName');
    } catch (error) {
      log('lib/services/analytics_service.dart - Track error: $error');
    }
  }

  /// Force re-initialization (emergency fallback)
  void _forceReinitialize() {
    log('lib/services/analytics_service.dart - _forceReinitialize() called');
    _clearAllMixPanelCache();
    _isInitialized = false;
    _mixpanel = null;
    initialize(); // This will run synchronously for the check parts
  }

  /// Ryd AL MixPanel cache og data
  void _clearAllMixPanelCache() {
    log('lib/services/analytics_service.dart - _clearAllMixPanelCache() called');

    try {
      if (_mixpanel != null) {
        log('lib/services/analytics_service.dart - Clearing MixPanel data...');

        // Reset bruger data
        _mixpanel!.reset();
        log('lib/services/analytics_service.dart - MixPanel reset() called');

        // Flush alle pending events
        _mixpanel!.flush();
        log('lib/services/analytics_service.dart - MixPanel flush() called');

        // Nulstil instans
        _mixpanel = null;
        log('lib/services/analytics_service.dart - MixPanel instance nullified');
      }

      // Nulstil vores egen state
      _isInitialized = false;
      log('lib/services/analytics_service.dart - Internal state reset');
    } catch (error) {
      log('lib/services/analytics_service.dart - Error during cache clear: $error');
      // Force reset even if there's an error
      _mixpanel = null;
      _isInitialized = false;
    }
  }

  /// Public metode til at rydde al cache (til debugging)
  void clearAllCache() {
    log('lib/services/analytics_service.dart - clearAllCache() PUBLIC method called');
    _clearAllMixPanelCache();
  }

  void setUserProperty(String property, dynamic value) {
    log('lib/services/analytics_service.dart - setUserProperty() called with property: $property, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - setUserProperty() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      final sanitizedValue = _isSensitiveProperty(property) && value is String ? _saltedHash(value) : value;
      log('lib/services/analytics_service.dart - setUserProperty() calling _mixpanel.getPeople().set()');
      _mixpanel!.getPeople().set(property, sanitizedValue);
      log('lib/services/analytics_service.dart - setUserProperty() property set successfully: $property');
    } catch (error) {
      log('lib/services/analytics_service.dart - Set property error: $error');
    }
  }

  void incrementUserProperty(String property, [int value = 1]) {
    log('lib/services/analytics_service.dart - incrementUserProperty() called with property: $property, value: $value, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - incrementUserProperty() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      log('lib/services/analytics_service.dart - incrementUserProperty() calling _mixpanel.getPeople().increment()');
      _mixpanel!.getPeople().increment(property, value.toDouble());
      log('lib/services/analytics_service.dart - incrementUserProperty() property incremented successfully: $property');
    } catch (error) {
      log('lib/services/analytics_service.dart - Increment error: $error');
    }
  }

  void timeEvent(String eventName) {
    log('lib/services/analytics_service.dart - timeEvent() called with event: $eventName, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - timeEvent() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      log('lib/services/analytics_service.dart - timeEvent() calling _mixpanel.timeEvent()');
      _mixpanel!.timeEvent(eventName);
      log('lib/services/analytics_service.dart - timeEvent() started successfully: $eventName');
    } catch (error) {
      log('lib/services/analytics_service.dart - Time event error: $error');
    }
  }

  void reset() {
    log('lib/services/analytics_service.dart - reset() called, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - reset() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      log('lib/services/analytics_service.dart - reset() calling _mixpanel.reset()');
      _mixpanel!.reset();
      log('lib/services/analytics_service.dart - reset() completed successfully');
    } catch (error) {
      log('lib/services/analytics_service.dart - Reset error: $error');
    }
  }

  void flush() {
    log('lib/services/analytics_service.dart - flush() called, _isInitialized: $_isInitialized, _mixpanel != null: ${_mixpanel != null}');

    if (!_isInitialized || _mixpanel == null) {
      log('lib/services/analytics_service.dart - flush() early return - not initialized or mixpanel is null');
      return;
    }

    try {
      log('lib/services/analytics_service.dart - flush() calling _mixpanel.flush()');
      _mixpanel!.flush();
      log('lib/services/analytics_service.dart - flush() completed successfully');
    } catch (error) {
      log('lib/services/analytics_service.dart - Flush error: $error');
    }
  }

  Map<String, dynamic> _sanitizeProperties(Map<String, dynamic> properties) {
    log('lib/services/analytics_service.dart - _sanitizeProperties() called with ${properties.length} properties');
    final sanitized = <String, dynamic>{};

    for (final entry in properties.entries) {
      final key = entry.key;
      final value = entry.value;

      if (_isSensitiveProperty(key) && value is String) {
        sanitized[key] = _saltedHash(value);
        log('lib/services/analytics_service.dart - _sanitizeProperties() hashed sensitive property: $key');
      } else {
        sanitized[key] = value;
        log('lib/services/analytics_service.dart - _sanitizeProperties() kept property as-is: $key');
      }
    }

    log('lib/services/analytics_service.dart - _sanitizeProperties() returning ${sanitized.length} sanitized properties');
    return sanitized;
  }

  bool _isSensitiveProperty(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('email') || lowerKey.contains('ip') || lowerKey.contains('address') || lowerKey.contains('phone') || lowerKey.contains('user_id') || lowerKey.contains('userid');
  }
}

// Created on 2024-12-30 at 16:30
