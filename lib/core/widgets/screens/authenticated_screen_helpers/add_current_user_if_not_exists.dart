import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../models/user_storage_data.dart'; // Direct import for UserStorageData

Future<void> addCurrentUserIfNotExists(
    BuildContext context, WidgetRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  final storage = ref.read(storageProvider.notifier);
  final existingUser =
      await storage.getUserStorageDataByEmail(user?.email ?? '');

  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  //print('user: $existingUser');
  print('user: ${existingUser?.token}');
  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');

  if (existingUser != null) {
    // Lav tjek om token er gyldigt - Skal være AppConstants.masterkeyCheckValue
    // Hvis ikke, så send bruger til secretkey siden
    return;
  }

  final tokenKey = AESGCMEncryptionUtils.generateSecureTestKey();

  final newUserData = UserStorageData(
    email: user?.email ?? '',
    token: tokenKey,
    testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
  );

  final currentData = await storage.getUserStorageData();
  final updatedData = [...currentData, newUserData];
  await storage.saveString(
    kUserStorageKey,
    jsonEncode(updatedData.map((e) => e.toJson()).toList()),
    secure: true,
  );

  // TODO: nu skal vi opdatere user_extra med ny encrypted_masterkey_check_value
  // Det er så en krypteret version af AppConstants.masterkeyCheckValue
}

// Created on: 2024-07-18 10:30
