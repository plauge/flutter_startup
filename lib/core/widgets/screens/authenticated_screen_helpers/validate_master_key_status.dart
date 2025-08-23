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

// Toggle to true temporarily if you need to see full sensitive values in logs
const bool _debugSensitiveLogs = true;

String _maskSensitive(String value, {int showStart = 6, int showEnd = 4}) {
  if (value.isEmpty) return '';
  if (value.length <= showStart + showEnd) {
    return '*' * value.length;
  }
  final String start = value.substring(0, showStart);
  final String end = value.substring(value.length - showEnd);
  return '$start***$end';
}

Future<void> validateMasterKeyStatus(BuildContext context, WidgetRef ref, bool pinCodeProtected) async {
  log('validateMasterKeyStatus - lib/core/widgets/screens/authenticated_screen_helpers/validate_master_key_status.dart', {'pinCodeProtected': pinCodeProtected});

  final String currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
  log('Route context', {'currentPath': currentPath});

  if (pinCodeProtected) {
    log('Pin code protection enabled, checking master key status');

    final userExtraAsync = ref.watch(userExtraNotifierProvider);
    if (userExtraAsync.hasValue && userExtraAsync.value != null) {
      final userExtra = userExtraAsync.value!;
      final String? encryptedValueRaw = userExtra.encryptedMasterkeyCheckValue;
      log('UserExtra loaded, checking master key', {
        'hasEncryptedMasterkeyCheckValue': encryptedValueRaw != null,
        'encryptedValueLength': encryptedValueRaw?.length,
        'expectedValue': AppConstants.masterkeyCheckValue,
      });

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

        if (existingUser == null) {
          log('No token key found for user, signing out');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //ref.read(authProvider.notifier).signOut();
            context.go(RoutePaths.updateSecurityKey);
          });
          return;
        }

        final tokenKey = existingUser.token;
        final encryptedValue = userExtra.encryptedMasterkeyCheckValue!;

        final Map<String, dynamic> tokenLog = {
          'tokenKeyLength': tokenKey.length,
          'tokenMasked': _maskSensitive(tokenKey, showStart: 8, showEnd: 6),
          'encryptedValueLength': encryptedValue.length,
        };
        if (_debugSensitiveLogs) {
          tokenLog['tokenFull'] = tokenKey;
        }
        log('Retrieved token key', tokenLog);

        // Debug: Check encrypted value format
        final parts = encryptedValue.split(':');
        final Map<String, dynamic> encParts = {
          'partsCount': parts.length,
          'parts': parts.map((p) => '${p.length} chars').toList(),
        };
        if (_debugSensitiveLogs) {
          encParts['fullValue'] = encryptedValue;
          encParts['fullValueMasked'] = _maskSensitive(encryptedValue, showStart: 12, showEnd: 8);
        } else {
          encParts['fullValueMasked'] = _maskSensitive(encryptedValue, showStart: 12, showEnd: 8);
        }
        log('Encrypted value format check', encParts);

        // Decrypt the encrypted master key check value
        final decryptedValue = await AESGCMEncryptionUtils.decryptString(
          encryptedValue,
          tokenKey,
        );

        log('Decrypted master key check value', {
          'decryptedValue': decryptedValue,
          'decryptedLength': decryptedValue.length,
          'expectedValue': AppConstants.masterkeyCheckValue,
          'expectedLength': AppConstants.masterkeyCheckValue.length,
        });

        // Now compare the decrypted value with the expected value
        final bool match = decryptedValue == AppConstants.masterkeyCheckValue;
        log('Master key comparison', {'match': match});
        if (!match) {
          log('Master key check value mismatch after decryption, navigating', {'to': RoutePaths.updateSecurityKey, 'from': currentPath});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RoutePaths.updateSecurityKey);
          });
          return;
        }

        log('Master key validation successful');
      } catch (e) {
        log('Error during master key validation, navigating to updateSecurityKey', {'error': e.toString(), 'from': currentPath, 'to': RoutePaths.updateSecurityKey});
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
    log('Pin code protection disabled, skipping master key validation');
  }
}

// File created on 2025-01-01 at 17:30 (UTC+1)
