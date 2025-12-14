import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';
import '../core/constants/storage_constants.dart';

part 'generated/showcase_completed_provider.g.dart';

/// Provider for managing showcase completion state
/// Used to control whether the home screen showcase should be displayed
/// Default is false (show showcase by default for new users), persists user preference
/// VIGTIGT: Nøglen er bruger-specifik, så hver bruger har sin egen showcase-status
@riverpod
class ShowcaseCompleted extends _$ShowcaseCompleted {
  static final log = scopedLogger(LogCategory.provider);

  /// Henter bruger-specifik storage-nøgle
  String _getStorageKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      log('[providers/showcase_completed_provider.dart][_getStorageKey] No user ID found, using default key');
      return StorageConstants.showcaseCompleted;
    }
    return '${StorageConstants.showcaseCompleted}_$userId';
  }

  @override
  Future<bool> build() async {
    final storageKey = _getStorageKey();
    log('[providers/showcase_completed_provider.dart][build] Using storage key: $storageKey');

    // Læs gemt værdi fra storage med bruger-specifik nøgle
    final savedValue = await ref.read(storageProvider.notifier).getBool(storageKey);

    // VIKTIGT: Default er false for nye brugere (vis showcase)
    // Hvis der ikke er en gemt værdi, returner false (vis showcase som default) og gem værdien
    if (savedValue == null) {
      log('[providers/showcase_completed_provider.dart][build] No saved value found for key $storageKey - initializing showcaseCompleted to false for new user');
      await _saveToStorage(false);
      return false;
    }

    // Hvis der er en gemt værdi, returner den
    log('[providers/showcase_completed_provider.dart][build] Loaded showcase completed state: $savedValue (saved: $savedValue) for key $storageKey');
    return savedValue;
  }

  /// Sets the showcase completed state to a specific value and saves to storage
  Future<void> setCompleted([bool completed = true]) async {
    log('[providers/showcase_completed_provider.dart][setCompleted] Setting showcase completed state to $completed');
    state = AsyncData(completed);
    await _saveToStorage(completed);
  }

  /// Resets the showcase completed state to false (for new users or testing)
  Future<void> reset() async {
    log('[providers/showcase_completed_provider.dart][reset] Resetting showcase completed state to false');
    state = AsyncData(false);
    await _saveToStorage(false);
  }

  /// Clears the showcase completed state from storage (for testing or reset)
  Future<void> clear() async {
    final storageKey = _getStorageKey();
    log('[providers/showcase_completed_provider.dart][clear] Clearing showcase completed state from storage for key $storageKey');
    try {
      await ref.read(storageProvider.notifier).remove(storageKey);
      state = AsyncData(false);
      log('[providers/showcase_completed_provider.dart][clear] Cleared showcase completed state from storage');
    } catch (e) {
      log('[providers/showcase_completed_provider.dart][clear] Error clearing from storage: $e');
    }
  }

  /// Saves the showcase completed state to persistent storage with user-specific key
  Future<void> _saveToStorage(bool value) async {
    final storageKey = _getStorageKey();
    try {
      await ref.read(storageProvider.notifier).saveBool(storageKey, value);
      log('[providers/showcase_completed_provider.dart][_saveToStorage] Saved showcase completed state to storage: $value for key $storageKey');
    } catch (e) {
      log('[providers/showcase_completed_provider.dart][_saveToStorage] Error saving to storage: $e');
    }
  }
}

// Created on 2025-12-14 at 04:50:00
