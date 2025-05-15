import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../models/user_storage_data.dart'; // Direct import for UserStorageData

Future<void> addCurrentUserIfNotExists(WidgetRef ref) async {
  final user = ref.read(authProvider);
  if (user == null) return;

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  final storage = ref.read(storageProvider.notifier);
  final existingUser = await storage.getUserStorageDataByEmail(user.email);

  if (existingUser != null) {
    return;
  }

  final newUserData = UserStorageData(
    email: user.email,
    token: AESGCMEncryptionUtils.generateSecureToken(),
    testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
  );

  final currentData = await storage.getUserStorageData();
  final updatedData = [...currentData, newUserData];
  await storage.saveString(
    kUserStorageKey,
    jsonEncode(updatedData.map((e) => e.toJson()).toList()),
    secure: true,
  );
}

// Created on: 2024-07-18 10:30
