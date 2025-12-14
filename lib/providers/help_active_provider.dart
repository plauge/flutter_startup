import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../core/constants/storage_constants.dart';

part 'generated/help_active_provider.g.dart';

/// Provider for managing help mode active/inactive state
/// Used to control whether help texts should be displayed throughout the app
/// Default is false (inactive) for new users, persists user preference
@riverpod
class HelpActive extends _$HelpActive {
  static final log = scopedLogger(LogCategory.provider);

  @override
  Future<bool> build() async {
    // Læs gemt værdi fra storage
    final savedValue = await ref.read(storageProvider.notifier).getBool(StorageConstants.helpActive);

    // Hvis der ikke er en gemt værdi, returner false (inaktivt som default) og gem værdien
    // Hvis der er en gemt værdi, returner den
    final value = savedValue ?? false;

    // Hvis der ikke var en gemt værdi (ny bruger), så gem default værdien false
    if (savedValue == null) {
      log('[providers/help_active_provider.dart][build] No saved value found - initializing helpActive to false for new user');
      await _saveToStorage(false);
    }

    log('[providers/help_active_provider.dart][build] Loaded help active state: $value (saved: $savedValue)');
    return value;
  }

  /// Toggles the help active state and saves to storage
  Future<void> toggle() async {
    final newValue = !state.value!;
    log('[providers/help_active_provider.dart][toggle] Toggling help active state from ${state.value} to $newValue');
    state = AsyncData(newValue);
    await _saveToStorage(newValue);
  }

  /// Sets the help active state to a specific value and saves to storage
  Future<void> setActive(bool active) async {
    log('[providers/help_active_provider.dart][setActive] Setting help active state to $active');
    state = AsyncData(active);
    await _saveToStorage(active);
  }

  /// Saves the help active state to persistent storage
  Future<void> _saveToStorage(bool value) async {
    try {
      await ref.read(storageProvider.notifier).saveBool(StorageConstants.helpActive, value);
      log('[providers/help_active_provider.dart][_saveToStorage] Saved help active state to storage: $value');
    } catch (e) {
      log('[providers/help_active_provider.dart][_saveToStorage] Error saving to storage: $e');
    }
  }
}

// Created: 2025-11-11 10:58:24
