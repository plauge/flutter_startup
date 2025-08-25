import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../models/user_storage_data.dart'; // Direct import for UserStorageData
import '../../../../providers/user_extra_provider.dart'; // Add import for userExtraProvider
import '../../../../utils/aes_gcm_encryption_utils.dart'; // Add import for AESGCMEncryptionUtils

// Scoped logger for security-related flows in this helper
final log = scopedLogger(LogCategory.security);

/// Generate a new per-user token, persist it to secure storage,
/// and update user_extra with encrypted masterkey check value.
///
/// This function handles the token generation and storage persistence
/// that was previously part of addCurrentUserIfNotExists.
Future<void> generateAndPersistUserToken(WidgetRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  final storage = ref.read(storageProvider.notifier); // storageProvider: access to secure local storage

  // Generate a new per-user token (do not log secrets)
  final tokenKey = AESGCMEncryptionUtils.generateSecureToken(); // AES-GCM utility: generate per-user crypto token (do not log)
  log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] Generated new per-user token');

  final newUserData = UserStorageData(
    // model: shape persisted in secure storage
    email: (user?.email ?? ''), //  + "XXX"
    token: tokenKey,
    testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
  );

  final currentData = await storage.getUserStorageData(); // read all local user records (secure storage)

  // Check if a record with this email already exists
  final userEmail = user?.email ?? '';
  final updatedData = currentData.map((item) {
    // If we find an item with matching email, return the new data instead
    if (item.email == userEmail) {
      return newUserData;
    }
    return item;
  }).toList();

  // If no matching email was found, add the new item
  if (!updatedData.any((item) => item.email == userEmail)) {
    updatedData.add(newUserData);
  }

  await storage.saveString(
    // persist updated list to secure storage
    kUserStorageKey,
    jsonEncode(updatedData.map((e) => e.toJson()).toList()),
    secure: true,
  );
  log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] Persisted user token to secure storage for email: \'${user?.email ?? ''}\'');

  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('tokenKey: $tokenKey');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print(
  //     'AppConstants.masterkeyCheckValue: ${AppConstants.masterkeyCheckValue}');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');

  // TODO: nu skal vi opdatere user_extra med ny encrypted_masterkey_check_value
  // Det er så en krypteret version af AppConstants.masterkeyCheckValue
  try {
    // Create encrypted masterkey check value using the freshly generated token
    final encryptedMasterkeyCheckValue = await AESGCMEncryptionUtils.encryptString(
      // encrypt constant with per-user token
      AppConstants.masterkeyCheckValue,
      tokenKey,
    );
    log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] Encrypted masterkey check value generated');

    await ref.read(userExtraNotifierProvider.notifier).updateEncryptedMasterkeyCheckValue(encryptedMasterkeyCheckValue); // provider call: update Supabase user_extra; refresh provider state
    log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] user_extra updated with encrypted masterkey check value');
  } catch (e, st) {
    log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] Error updating user_extra: $e');
    log(st.toString());
    rethrow;
  }

  log('[authenticated_screen_helpers/generate_and_persist_user_token.dart][generateAndPersistUserToken] Completed');
  return;
}

// Created on: 2024-12-30 12:00:00
