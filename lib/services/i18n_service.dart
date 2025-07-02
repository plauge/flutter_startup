import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../utils/json_flatten.dart';

/// Singleton service for handling internationalization (i18n) with caching.
///
/// Features:
/// - Fetches translations from Supabase via RPC
/// - Flattens nested JSON to dot-notation
/// - Caches translations in SharedPreferences with 24h TTL
/// - Provides simple access to translations via t() method
/// - Handles offline scenarios and errors gracefully
class I18nService {
  static final I18nService _instance = I18nService._internal();
  static final log = scopedLogger(LogCategory.service);

  factory I18nService() => _instance;

  I18nService._internal();

  static const String _cacheKey = 'i18n_translations';
  static const String _cacheTimestampKey = 'i18n_cache_timestamp';
  static const Duration _cacheTtl = Duration(minutes: 1); // Temporarily reduced for testing
  //static const Duration _cacheTtl = Duration(hours: 24);

  Map<String, String> _translations = {};
  bool _isInitialized = false;

  /// Initializes the i18n service with the given locale.
  ///
  /// [locale] The locale to fetch translations for
  ///
  /// This method:
  /// 1. Loads translations from cache if available and not expired
  /// 2. Fetches fresh translations from Supabase if cache is expired or missing
  /// 3. Updates cache with new translations
  /// 4. Falls back to cache-only in case of network errors
  Future<void> init(Locale locale) async {
    try {
      final localeString = locale.languageCode;
      log('Initializing I18nService for locale: $localeString (language: ${locale.languageCode}, country: ${locale.countryCode})');

      final prefs = await SharedPreferences.getInstance();
      final cachedTranslations = prefs.getString(_cacheKey);
      final cacheTimestamp = prefs.getInt(_cacheTimestampKey);

      // Check if cache is valid
      final bool isCacheValid = _isCacheValid(cacheTimestamp);

      if (cachedTranslations != null && isCacheValid) {
        // Load from cache
        log('Loading translations from valid cache');
        _loadFromCache(cachedTranslations);
        _isInitialized = true;

        // Optionally fetch fresh data in background if cache is getting old
        _fetchInBackground(locale, prefs);
      } else {
        // Cache is expired or missing, fetch fresh data
        log('Cache is expired or missing, fetching fresh translations');
        final bool success = await _fetchAndCache(locale, prefs);

        if (!success && cachedTranslations != null) {
          // Fallback to expired cache if fetch failed
          log('Using expired cache as fallback');
          _loadFromCache(cachedTranslations);
        }

        _isInitialized = true;
      }

      log('I18nService initialized with ${_translations.length} translations');
    } catch (e) {
      log('Error initializing I18nService: $e');
      _isInitialized = true; // Mark as initialized even on error to prevent blocking
    }
  }

  /// Returns the translation for the given key.
  ///
  /// [key] The dot-notation key for the translation
  /// [fallback] Optional fallback text if translation is not found
  /// [variables] Optional map of variables to substitute in the translation (e.g., {'email': 'test@example.com'})
  ///
  /// Returns the translation with variables substituted, fallback text, or the key itself if neither is available
  String t(String key, {String? fallback, Map<String, String>? variables}) {
    if (!_isInitialized) {
      log('I18nService not initialized, returning key: $key');
      return _substituteVariables(fallback ?? key, variables);
    }

    final translation = _translations[key];

    if (translation == null) {
      log('Missing translation for key: $key');
      return _substituteVariables(fallback ?? key, variables);
    }

    return _substituteVariables(translation, variables);
  }

  /// Substitutes variables in a string.
  ///
  /// [text] The text containing variables in format $variableName
  /// [variables] Map of variable names to their values
  ///
  /// Returns the text with variables substituted
  String _substituteVariables(String text, Map<String, String>? variables) {
    if (variables == null || variables.isEmpty) {
      return text;
    }

    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('\$$key', value);
    });

    return result;
  }

  /// Checks if the cache is still valid based on TTL.
  bool _isCacheValid(int? timestamp) {
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheTtl;
  }

  /// Loads translations from cached JSON string.
  void _loadFromCache(String cachedTranslations) {
    try {
      final Map<String, dynamic> decoded = json.decode(cachedTranslations);
      _translations = Map<String, String>.from(decoded);
    } catch (e) {
      log('Error loading from cache: $e');
      _translations = {};
    }
  }

  /// Fetches translations from Supabase and updates cache.
  Future<bool> _fetchAndCache(Locale locale, SharedPreferences prefs) async {
    try {
      final localeString = locale.languageCode;
      log('Fetching translations from Supabase for: $localeString');

      final response = await Supabase.instance.client.rpc('get_translations', params: {'input_language_code': localeString});

      if (response == null) {
        log('Received null response from get_translations');
        return false;
      }

      // Parse the response array format
      final List<dynamic> responseArray = response as List<dynamic>;
      if (responseArray.isEmpty) {
        log('Received empty response array from get_translations');
        return false;
      }

      final Map<String, dynamic> responseData = responseArray.first as Map<String, dynamic>;

      // Check status code
      final int statusCode = responseData['status_code'] ?? 0;
      if (statusCode != 200) {
        log('Non-200 status code from get_translations: $statusCode');
        return false;
      }

      // Extract payload from response
      final Map<String, dynamic>? data = responseData['data'] as Map<String, dynamic>?;
      if (data == null || !data.containsKey('payload')) {
        log('Invalid response structure: missing data.payload');
        return false;
      }

      final Map<String, dynamic> nestedTranslations = data['payload'] as Map<String, dynamic>;
      final Map<String, String> flatTranslations = flatten(nestedTranslations);

      // Update in-memory translations
      _translations = flatTranslations;

      // Update cache
      await prefs.setString(_cacheKey, json.encode(flatTranslations));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);

      log('Successfully cached ${flatTranslations.length} translations');
      return true;
    } catch (e) {
      log('Error fetching translations: $e');
      return false;
    }
  }

  /// Fetches fresh translations in background without blocking initialization.
  void _fetchInBackground(Locale locale, SharedPreferences prefs) {
    Future.delayed(const Duration(seconds: 1), () async {
      final localeString = locale.languageCode;
      log('Fetching fresh translations in background for: $localeString');
      await _fetchAndCache(locale, prefs);
    });
  }

  /// Returns whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Returns the current number of loaded translations (for debugging).
  int get translationCount => _translations.length;

  /// Clears the translation cache (useful for testing or forced refresh).
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      _translations.clear();
      log('Translation cache cleared');
    } catch (e) {
      log('Error clearing cache: $e');
    }
  }
}

// Created: 2024-12-30 at 10:05 AM
