import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';
import '../providers/user_extra_provider.dart';

enum MasterKeyStatus { validated, invalid, noLocalToken, noEncryptedValue }

final masterKeyValidationProvider = AsyncNotifierProvider<MasterKeyValidationNotifier, MasterKeyStatus>(() {
  return MasterKeyValidationNotifier();
});

class MasterKeyValidationNotifier extends AsyncNotifier<MasterKeyStatus> {
  static final log = scopedLogger(LogCategory.security);

  void markValidated() {
    log('[providers/master_key_validation_provider.dart][markValidated] Setting state to validated');
    state = const AsyncData(MasterKeyStatus.validated);
  }

  @override
  Future<MasterKeyStatus> build() async {
    final userExtra = await ref.watch(userExtraNotifierProvider.future);
    if (userExtra == null) {
      log('[providers/master_key_validation_provider.dart][build] user_extra is null');
      return MasterKeyStatus.noEncryptedValue;
    }
    final encryptedValue = userExtra.encryptedMasterkeyCheckValue;
    if (encryptedValue == null || encryptedValue.isEmpty) {
      log('[providers/master_key_validation_provider.dart][build] encryptedMasterkeyCheckValue is null/empty');
      return MasterKeyStatus.noEncryptedValue;
    }
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email;
    if (userEmail == null || userEmail.isEmpty) {
      log('[providers/master_key_validation_provider.dart][build] No authenticated user email');
      return MasterKeyStatus.invalid;
    }
    final storage = ref.read(storageProvider.notifier);
    final existingUser = await storage.getUserStorageDataByEmail(userEmail);
    if (existingUser == null) {
      log('[providers/master_key_validation_provider.dart][build] No local token found for $userEmail');
      return MasterKeyStatus.noLocalToken;
    }
    final tokenKey = existingUser.token;
    try {
      final decryptedValue = await AESGCMEncryptionUtils.decryptString(
        encryptedValue,
        tokenKey,
      );
      final bool match = decryptedValue == AppConstants.masterkeyCheckValue;
      if (match) {
        log('[providers/master_key_validation_provider.dart][build] Master key validated successfully');
        return MasterKeyStatus.validated;
      }
      log('[providers/master_key_validation_provider.dart][build] Decrypted value does not match expected');
      return MasterKeyStatus.invalid;
    } catch (e) {
      log('[providers/master_key_validation_provider.dart][build] Decryption failed: $e');
      return MasterKeyStatus.invalid;
    }
  }
}

// Created: 2026-02-25 08:00:00
