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
    if (_isInitialized) return;

    try {
      if (kDebugMode && !AnalyticsConstants.sendToAnalyticsWhileInDebug) {
        _isInitialized = true;
        return;
      }

      final token = kDebugMode
          ? AnalyticsConstants.mixpanelDevToken.isNotEmpty
              ? AnalyticsConstants.mixpanelDevToken
              : AnalyticsConstants.mixpanelToken
          : AnalyticsConstants.mixpanelToken;

      if (token.isEmpty) {
        _isInitialized = true;
        return;
      }

      _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: false);
      _isInitialized = true;
    } catch (error) {
      log('Failed to initialize: $error');
      _isInitialized = true;
    }
  }

  String _saltedHash(String data) {
    final combined = AnalyticsConstants.saltKey + data.toLowerCase().trim();
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void identify(String email, [Map<String, dynamic>? properties]) {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      final hashedUserId = _saltedHash(email);
      _mixpanel!.identify(hashedUserId);

      if (properties != null) {
        final sanitizedProperties = _sanitizeProperties(properties);
        for (final entry in sanitizedProperties.entries) {
          _mixpanel!.getPeople().set(entry.key, entry.value);
        }
      }
    } catch (error) {
      log('Identify error: $error');
    }
  }

  void track(String eventName, [Map<String, dynamic>? properties]) {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      final sanitizedProperties = properties != null ? _sanitizeProperties(properties) : <String, dynamic>{};

      _mixpanel!.track(eventName, properties: sanitizedProperties);
    } catch (error) {
      log('Track error: $error');
    }
  }

  void setUserProperty(String property, dynamic value) {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      final sanitizedValue = _isSensitiveProperty(property) && value is String ? _saltedHash(value) : value;
      _mixpanel!.getPeople().set(property, sanitizedValue);
    } catch (error) {
      log('Set property error: $error');
    }
  }

  void incrementUserProperty(String property, [int value = 1]) {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      _mixpanel!.getPeople().increment(property, value.toDouble());
    } catch (error) {
      log('Increment error: $error');
    }
  }

  void timeEvent(String eventName) {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      _mixpanel!.timeEvent(eventName);
    } catch (error) {
      log('Time event error: $error');
    }
  }

  void reset() {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      _mixpanel!.reset();
    } catch (error) {
      log('Reset error: $error');
    }
  }

  void flush() {
    if (!_isInitialized || _mixpanel == null) return;

    try {
      _mixpanel!.flush();
    } catch (error) {
      log('Flush error: $error');
    }
  }

  Map<String, dynamic> _sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, dynamic>{};

    for (final entry in properties.entries) {
      final key = entry.key;
      final value = entry.value;

      if (_isSensitiveProperty(key) && value is String) {
        sanitized[key] = _saltedHash(value);
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  bool _isSensitiveProperty(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('email') || lowerKey.contains('ip') || lowerKey.contains('address') || lowerKey.contains('phone') || lowerKey.contains('user_id') || lowerKey.contains('userid');
  }
}

// Created on 2024-12-30 at 16:30
