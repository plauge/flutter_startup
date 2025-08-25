import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Path to main exports file
import '../../../../providers/user_extra_provider.dart'; // Add import for userExtraProvider
import 'generate_and_persist_user_token.dart'; // Import for token generation helper

// Scoped logger for security-related flows in this helper
final log = scopedLogger(LogCategory.security);

/// Ensure current user has a secure token stored locally and
/// propagate an encrypted masterkey check value to `user_extra`.
///
/// Flow:
/// 1) Read current auth user
/// 2) Look up user storage by email; if present and `user_extra.encrypted_masterkey_check_value` exists, exit early
/// 3) Otherwise generate a new per-user token and persist it in secure storage
/// 4) Encrypt `AppConstants.masterkeyCheckValue` with the token and update `user_extra`
Future<void> addCurrentUserIfNotExists(BuildContext context, WidgetRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Start - userEmail: \'${user?.email ?? ''}\'');

  // Slett alle records i user_storage
  //await ref.read(storageProvider.notifier).deleteAllUserStorageData();

  final storage = ref.read(storageProvider.notifier); // storageProvider: access to secure local storage
  final existingUser = await storage.getUserStorageDataByEmail((user?.email ?? '')); // lookup local user by email (secure storage)
  log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Local storage lookup completed - exists: ${existingUser != null}');

  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('user: $existingUser');
  // print('user: ${existingUser?.token}');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');
  // print('ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ℹ️ ');

  if (existingUser != null) {
    // Check if `user_extra` already has an encrypted masterkey check value; if so, nothing to do
    UserExtra? earlyCheckUserExtra;
    try {
      earlyCheckUserExtra = await ref.read(userExtraNotifierProvider.future); // Wait for data consistently
    } catch (error) {
      // If we can't load user_extra for early check, continue to main flow
      log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Early check failed, continuing to main flow: $error');
    }

    if (earlyCheckUserExtra?.encryptedMasterkeyCheckValue != null) {
      log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Encrypted masterkey check already present in user_extra - exiting early');
      return;
    }
    // If encrypted value is missing, continue to create a fresh token and propagate
    log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Missing encrypted masterkey check value - proceeding to generate token');
  }

  // HER: TODO: Hvis createdAt er ældre 10 minutter (toLocal()) - så er brugere allerede oprettet med key er i stykke. Så vi skal så retunere brugeren til context.go(RoutePaths.updateSecurityKey);

  // Wait for user_extra data to be loaded from Supabase (with 10min cache)
  log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Waiting for user_extra data from Supabase...');

  UserExtra? userExtra;
  try {
    userExtra = await ref.read(userExtraNotifierProvider.future); // Wait for data to load
    log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] user_extra data loaded successfully');
  } catch (error) {
    log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Error loading user_extra: $error - redirecting to updateSecurityKey');
    context.go(RoutePaths.updateSecurityKey);
    return;
  }

  // Security check: If user_extra data is null or corrupted
  if (userExtra == null) {
    log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] user_extra data is null - redirecting to updateSecurityKey for security');
    context.go(RoutePaths.updateSecurityKey);
    return;
  }
  // if (userExtra.encryptedMasterkeyCheckValue == null) {
  //   // Time math normalized to UTC for accurate comparison
  //   final isOlderThan10min = DateTime.now().toUtc().difference(userExtra.createdAt.toUtc()) > const Duration(minutes: 10);
  //   if (isOlderThan10min) {
  //     log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] user_extra older than 10 minutes without encrypted check - redirecting to updateSecurityKey');
  //     context.go(RoutePaths.updateSecurityKey);
  //     return;
  //   } else {
  //     log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] user_extra is fresh (<10 minutes) - proceeding to generate token');
  //     // Generate token and persist to storage (only for fresh accounts)
  //     await generateAndPersistUserToken(ref);
  //   }
  // }

  log('[authenticated_screen_helpers/add_current_user_if_not_exists.dart][addCurrentUserIfNotExists] Completed');
  return;
}

// Created on: 2024-07-18 10:30
