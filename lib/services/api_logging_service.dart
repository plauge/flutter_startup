import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import 'dart:convert';

/// Service for logging API calls in a structured format for test generation
class ApiLoggingService {
  static final ApiLoggingService _instance = ApiLoggingService._internal();
  factory ApiLoggingService() => _instance;
  ApiLoggingService._internal();

  int _sequence = 0;

  /// Log an API call
  void logApiCall({
    required String type, // 'rpc' or 'auth'
    required String method,
    Map<String, dynamic>? params,
    bool success = true,
    dynamic response,
    String? error,
  }) {
    // Only log in development mode and when api_call category is enabled
    if (kReleaseMode) return;
    if (!LogConfig.isEnabled(LogCategory.api_call)) return;

    _sequence++;
    final logEntry = <String, dynamic>{
      'sequence': _sequence,
      'type': type,
      'method': method,
      'success': success,
    };

    if (params != null && params.isNotEmpty) {
      logEntry['params'] = params;
    }

    if (success && response != null) {
      logEntry['response'] = response;
    }

    if (!success && error != null) {
      logEntry['error'] = error;
    }

    // Log as structured JSON to console
    final jsonString = jsonEncode(logEntry);
    if (LogConfig.isEnabled(LogCategory.api_call)) {
      // Print newline first to create empty line before flutter: output
      print('\n');
      // Then print JSON with flutter: prefix
      print(jsonString);
    }
  }

  /// Reset sequence counter (called when user clears terminal and starts fresh)
  void resetSequence() {
    _sequence = 0;
  }
}

// Created: 2025-01-15 14:30:00
