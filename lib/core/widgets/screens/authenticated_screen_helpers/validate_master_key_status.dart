import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../providers/user_extra_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/storage/storage_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../utils/app_logger.dart';
import '../../../../utils/aes_gcm_encryption_utils.dart';

final log = scopedLogger(LogCategory.security);

Future<void> validateMasterKeyStatus(BuildContext context, WidgetRef ref, bool pinCodeProtected) async {
  log('validateMasterKeyStatus - lib/core/widgets/screens/authenticated_screen_helpers/validate_master_key_status.dart', {'pinCodeProtected': pinCodeProtected});

  if (pinCodeProtected) {
    log('Pin code protection disabled, checking master key status');

    final userExtraAsync = ref.watch(userExtraNotifierProvider);
    if (userExtraAsync.hasValue && userExtraAsync.value != null) {
      final userExtra = userExtraAsync.value!;
      log('UserExtra loaded, checking master key', {'hasEncryptedMasterkeyCheckValue': userExtra.encryptedMasterkeyCheckValue != null, 'encryptedValue': userExtra.encryptedMasterkeyCheckValue, 'expectedValue': AppConstants.masterkeyCheckValue});

      // Check if master key check value exists
      if (userExtra.encryptedMasterkeyCheckValue == null) {
        log('No encrypted master key check value found, redirecting to security key screen');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //context.go(RoutePaths.home);
          // sign out user
          ref.read(authProvider.notifier).signOut();
        });
        return;
      }

      try {
        // Get current user email to find the token key
        final user = Supabase.instance.client.auth.currentUser;
        final userEmail = user?.email;
        if (userEmail == null) {
          log('No current user found, signing out');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authProvider.notifier).signOut();
          });
          return;
        }

        log('Found current user', {'email': userEmail});

        // Get token key from storage
        final storage = ref.read(storageProvider.notifier);
        final existingUser = await storage.getUserStorageDataByEmail(userEmail);

        if (existingUser?.token == null) {
          log('No token key found for user, signing out');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authProvider.notifier).signOut();
          });
          return;
        }

        final tokenKey = existingUser!.token!;
        final encryptedValue = userExtra.encryptedMasterkeyCheckValue!;
        log('Retrieved token key', {'tokenKeyLength': tokenKey.length, 'encryptedValueLength': encryptedValue.length});

        // Debug: Check encrypted value format
        final parts = encryptedValue.split(':');
        log('Encrypted value format check', {'fullValue': encryptedValue, 'partsCount': parts.length, 'parts': parts.map((p) => '${p.length} chars').toList()});

        // Decrypt the encrypted master key check value
        final decryptedValue = await AESGCMEncryptionUtils.decryptString(
          encryptedValue,
          tokenKey,
        );

        log('Decrypted master key check value', {'decryptedValue': decryptedValue, 'expectedValue': AppConstants.masterkeyCheckValue});

        // Now compare the decrypted value with the expected value
        if (decryptedValue != AppConstants.masterkeyCheckValue) {
          log('Master key check value mismatch after decryption, redirecting to home');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RoutePaths.updateSecurityKey);
          });
          return;
        }

        log('Master key validation successful');
      } catch (e) {
        log('Error during master key validation: $e, signing out');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //ref.read(authProvider.notifier).signOut();
          context.go(RoutePaths.updateSecurityKey);
        });
        return;
      }
    } else {
      log('UserExtra not available, redirecting to security key screen');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RoutePaths.updateSecurityKey);
      });
    }
  } else {
    log('Pin code protection enabled, skipping master key validation');
  }
}

// File created on 2025-01-01 at 17:30 (UTC+1)
