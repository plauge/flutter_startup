// === RESUMÉ ===
// validateMasterKeyStatus tjekker om brugeren har den rigtige security key gemt lokalt på
// telefonen, når de forsøger at tilgå PIN-beskyttede sider.
//
// HVORFOR: Brugerens security key gemmes KUN lokalt (sikkerhed). Vi kan derfor ikke tjekke key'en
// direkte. I stedet gemmer vi i Supabase en KRYPTERET kopi af en kendt tekst (AppConstants.masterkeyCheckValue).
// Hvis brugerens lokale key kan dekryptere den til den rigtige tekst, har vi den rigtige key.
//
// FLOW: (1) Hent encryptedMasterkeyCheckValue fra Supabase user_extra. (2) Hent brugerens lokale
// token (security key) fra telefonens secure storage. (3) Dekrypter med lokal key. (4) Sammenlign
// med AppConstants.masterkeyCheckValue. Matcher → adgang. Matcher ikke → redirect til updateSecurityKey.
//
// Kaldes fra: AuthenticatedScreen.build() inden PIN-beskyttede sider vises.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/user_extra.dart';
import '../../../../providers/user_extra_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/storage/storage_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../utils/app_logger.dart';
import '../../../../utils/aes_gcm_encryption_utils.dart';

final log = scopedLogger(LogCategory.security);

// _debugSensitiveLogs: sæt til true hvis du debugger og vil se fulde token/encrypted værdier i logs. VÆR FORSIGTIG.
const bool _debugSensitiveLogs = true;

/// Maskerer sensitiv tekst i logs – viser kun start og slut (fx "abc***xyz") for at undgå at lække keys.
String _maskSensitive(String value, {int showStart = 6, int showEnd = 4}) {
  if (value.isEmpty) return '';
  if (value.length <= showStart + showEnd) {
    return '*' * value.length;
  }
  final String start = value.substring(0, showStart);
  final String end = value.substring(value.length - showEnd);
  return '$start***$end';
}

/// Henter user_extra fra Riverpod og returnerer record med encryptedValue hvis tilgængelig.
/// Returnerer null hvis userExtra ikke er klar (loading/fejl) ELLER hvis encryptedMasterkeyCheckValue er null.
({UserExtra userExtra, String encryptedValue})? _getUserExtraWithEncryptedValue(WidgetRef ref) {
  log('PIN-beskyttet side: henter user_extra fra Riverpod (kommer fra Supabase user_extra tabel)');
  final userExtraAsync = ref.watch(userExtraNotifierProvider);
  if (!userExtraAsync.hasValue || userExtraAsync.value == null) {
    return null;
  }
  final userExtra = userExtraAsync.value!;
  final String? encryptedValueRaw = userExtra.encryptedMasterkeyCheckValue;
  log('user_extra hentet: tjekker om encryptedMasterkeyCheckValue findes i DB (bruger har sat security key op)', {
    'hasEncryptedMasterkeyCheckValue': encryptedValueRaw != null,
    'encryptedValueLength': encryptedValueRaw?.length,
    'expectedValue': AppConstants.masterkeyCheckValue,
  });
  if (encryptedValueRaw == null) {
    log('encryptedMasterkeyCheckValue er null i Supabase – bruger har aldrig sat security key op. Redirecter til updateSecurityKey');
    return null;
  }
  return (userExtra: userExtra, encryptedValue: encryptedValueRaw);
}

/// Henter current user fra Supabase auth og returnerer email. Null hvis ingen currentUser.
String? _getCurrentUserEmail() {
  log('Henter currentUser fra Supabase auth – skal bruge email til at slå brugerens lokale token op');
  final user = Supabase.instance.client.auth.currentUser;
  final userEmail = user?.email;
  if (userEmail == null) {
    log('Ingen currentUser i Supabase auth – logger ud');
    return null;
  }
  return userEmail;
}

/// Henter security key (token) fra telefonens secure storage for den givne bruger.
/// Returnerer null hvis bruger ikke findes i storage.
Future<String?> _getLocalTokenForUserEmail(WidgetRef ref, String userEmail, String encryptedValue) async {
  log('Har user email, læser nu brugerens security key (token) fra telefonens secure storage', {'email': userEmail});
  final storage = ref.read(storageProvider.notifier);
  final existingUser = await storage.getUserStorageDataByEmail(userEmail);
  if (existingUser == null) {
    log('Ingen token fundet i lokal storage for denne bruger – security key ikke gemt på denne enhed. Redirecter til updateSecurityKey');
    return null;
  }
  final tokenKey = existingUser.token;
  final Map<String, dynamic> tokenLog = {
    'tokenKeyLength': tokenKey.length,
    'tokenMasked': _maskSensitive(tokenKey, showStart: 8, showEnd: 6),
    'encryptedValueLength': encryptedValue.length,
  };
  if (_debugSensitiveLogs) {
    tokenLog['tokenFull'] = tokenKey;
  }
  log('Hentet security key (token) fra lokal storage – skal bruges til at dekryptere', tokenLog);
  return tokenKey;
}

/// Dekrypterer encryptedValue med tokenKey og sammenligner med AppConstants.masterkeyCheckValue.
/// Returnerer true hvis match, false hvis dekryptering lykkedes men værdi matcher ikke.
/// Kaster exception ved dekrypteringsfejl.
Future<bool> _decryptAndValidateMasterKey(String encryptedValue, String tokenKey) async {
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
  log('encryptedMasterkeyCheckValue er AES-GCM format (iv:tag:ciphertext), tjekker struktur', encParts);
  log('Dekrypterer encryptedMasterkeyCheckValue fra Supabase med den lokale token');
  final decryptedValue = await AESGCMEncryptionUtils.decryptString(
    encryptedValue,
    tokenKey,
  );
  log('Dekryptering færdig: sammenligner nu det dekrypterede resultat med AppConstants.masterkeyCheckValue', {
    'decryptedValue': decryptedValue,
    'decryptedLength': decryptedValue.length,
    'expectedValue': AppConstants.masterkeyCheckValue,
    'expectedLength': AppConstants.masterkeyCheckValue.length,
  });
  final bool match = decryptedValue == AppConstants.masterkeyCheckValue;
  if (!match) {
    log('MATCH FEJL: dekrypteret værdi matcher ikke forventet – forkert security key. Redirecter til updateSecurityKey');
  } else {
    log('validateMasterKeyStatus OK: dekrypteret værdi matcher – bruger har korrekt security key, adgang tillades');
  }
  return match;
}

void _redirectToUpdateSecurityKey(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.go(RoutePaths.updateSecurityKey);
  });
}

Future<void> validateMasterKeyStatus(BuildContext context, WidgetRef ref, bool pinCodeProtected) async {
  // --- TRIN 1: Forberedelse ---
  // currentPath bruges til at redirecte til updateSecurityKey hvis noget fejler (vi navigerer væk fra nuværende side)
  log('validateMasterKeyStatus START: vil tjekke om bruger har korrekt security key for PIN-beskyttet side', {'pinCodeProtected': pinCodeProtected});
  final String currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
  log('Henter currentPath til redirect ved fejl', {'currentPath': currentPath});

  if (!pinCodeProtected) {
    log('Siden er ikke PIN-beskyttet, springer master key validering over');
    return;
  }

  // --- TRIN 2: Hent user_extra + encryptedValue ---
  final userExtraResult = _getUserExtraWithEncryptedValue(ref);
  if (userExtraResult == null) {
    log('user_extra ikke tilgængelig (loading eller fejl) eller encryptedMasterkeyCheckValue er null. Redirecter til updateSecurityKey');
    _redirectToUpdateSecurityKey(context);
    return;
  }

  // --- TRIN 3: Hent currentUser email ---
  final userEmail = _getCurrentUserEmail();
  if (userEmail == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).signOut();
    });
    return;
  }

  // --- TRIN 4: Hent lokal token ---
  final tokenKey = await _getLocalTokenForUserEmail(ref, userEmail, userExtraResult.encryptedValue);
  if (tokenKey == null) {
    if (context.mounted) _redirectToUpdateSecurityKey(context);
    return;
  }

  // --- TRIN 5: Dekrypter og valider ---
  try {
    final isValid = await _decryptAndValidateMasterKey(userExtraResult.encryptedValue, tokenKey);
    if (!isValid) {
      if (context.mounted) _redirectToUpdateSecurityKey(context);
    }
  } catch (e) {
    log('FEJL under master key validering (dekryptering eller andet). Redirecter til updateSecurityKey', {'error': e.toString(), 'from': currentPath, 'to': RoutePaths.updateSecurityKey});
    if (context.mounted) _redirectToUpdateSecurityKey(context);
  }
}

// File created on 2025-01-01 at 17:30 (UTC+1)
