import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../models/user_storage_data.dart'; // Direct import for UserStorageData

/// Singleton class to manage session state across the app lifecycle
class AppSessionManager {
  static final AppSessionManager _instance = AppSessionManager._internal();

  factory AppSessionManager() => _instance;

  AppSessionManager._internal();

  bool hasRunAppStoreSetup = false;
}

/// Kører specielle opsætninger for App Store testere
Future<void> setupAppStoreReviewer(BuildContext context, WidgetRef ref) async {
  // Slett alle records i user_storage
  //await ref.read(storageProvider.notifier).deleteAllUserStorageData();

  // Return early if setup has already been run in this session
  if (AppSessionManager().hasRunAppStoreSetup) {
    debugPrint('🔄 App Store reviewer setup already done this session');
    return;
  }

  try {
    final user = Supabase.instance.client.auth.currentUser;

    final storage = ref.read(storageProvider.notifier);
    final existingUser = await storage
        .getUserStorageDataByEmail((user?.email ?? '')); //  + "XXX"

    if (user?.email != 'apple-reviewer@idtruster.com') {
      AppSessionManager().hasRunAppStoreSetup = true; // Mark as run
      return;
    }

    final tokenKey =
        '_QagN6y8mEaXX&4G2FGq@kYiBLill-vRDs^z_LQ7S3NW)N3B^wq*BpZvsb0Of6_i';

    debugPrint('🔑 Token length: ${tokenKey.length}');

    if (existingUser?.token != tokenKey) {
      final newUserData = UserStorageData(
        email: (user?.email ?? ''), //  + "XXX"
        token: tokenKey,
        testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
      );

      print('ℹ️ 1');

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

      print('ℹ️ 2');

      await storage.saveString(
        kUserStorageKey,
        jsonEncode(updatedData.map((e) => e.toJson()).toList()),
        secure: true,
      );

      print('ℹ️ 3');

      final encryptedMasterkeyCheckValue =
          await AESGCMEncryptionUtils.encryptString(
        AppConstants.masterkeyCheckValue,
        tokenKey,
      );

      print('ℹ️ 4');

      // Brug Supabase direkte i stedet for notifier-provideren for at undgå loop
      final supabaseClient = Supabase.instance.client;
      await supabaseClient.rpc(
        'user_extra_update_encrypted_masterkey_check_value',
        params: {
          'input_check_value': encryptedMasterkeyCheckValue,
        },
      );

      print('ℹ️ 5');
    }

    // Mark setup as completed for this session
    AppSessionManager().hasRunAppStoreSetup = true;

    return;
  } catch (e) {
    debugPrint('❌ Error setting up App Store reviewer environment: $e');
    // Don't mark as completed if there was an error
  }
}

// Created on: 2024-07-24 14:19
