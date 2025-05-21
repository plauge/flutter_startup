import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../models/user_storage_data.dart'; // Direct import for UserStorageData
import '../../../../providers/user_extra_provider.dart'; // Add import for userExtraProvider
import '../../../../utils/aes_gcm_encryption_utils.dart'; // Add import for AESGCMEncryptionUtils

Future<void> addCurrentUserIfNotExists(
    BuildContext context, WidgetRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  // Slett alle records i user_storage
  //await ref.read(storageProvider.notifier).deleteAllUserStorageData();

  final storage = ref.read(storageProvider.notifier);
  final existingUser =
      await storage.getUserStorageDataByEmail((user?.email ?? '')); //  + "XXX"

  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('user: $existingUser');
  // print('user: ${existingUser?.token}');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');

  if (existingUser != null) {
    // Lav tjek om token er gyldigt - Skal være AppConstants.masterkeyCheckValue
    // Hvis ikke, så send bruger til secretkey siden
    return;
  }

  final tokenKey = AESGCMEncryptionUtils.generateSecureToken();

  final newUserData = UserStorageData(
    email: (user?.email ?? ''), //  + "XXX"
    token: tokenKey,
    testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
  );

  final currentData = await storage.getUserStorageData();

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
    kUserStorageKey,
    jsonEncode(updatedData.map((e) => e.toJson()).toList()),
    secure: true,
  );

  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('tokenKey: $tokenKey');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print(
  //     'AppConstants.masterkeyCheckValue: ${AppConstants.masterkeyCheckValue}');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');

  // TODO: nu skal vi opdatere user_extra med ny encrypted_masterkey_check_value
  // Det er så en krypteret version af AppConstants.masterkeyCheckValue
  final encryptedMasterkeyCheckValue =
      await AESGCMEncryptionUtils.encryptString(
    AppConstants.masterkeyCheckValue,
    tokenKey,
  );

  await ref
      .read(userExtraNotifierProvider.notifier)
      .updateEncryptedMasterkeyCheckValue(encryptedMasterkeyCheckValue);

  return;
}

// Created on: 2024-07-18 10:30
