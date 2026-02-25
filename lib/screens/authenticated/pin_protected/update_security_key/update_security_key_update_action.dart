// === RESUMÉ ===
// executeUpdateSecurityKey opdaterer brugerens security key (token) i lokalt secure storage
// med den værdi brugeren indtaster. Ved succes: viser succes-SnackBar og navigerer tilbage (pop),
// med fallback til home hvis pop fejler. Opdaterer eksisterende bruger-post eller opretter ny.
// Kaldes fra: update_security_key_screen.dart ved tryk på Update-knappen efter form-validering.

import 'dart:convert';
import '../../../../exports.dart';
import '../../../../models/user_storage_data.dart';

final log = scopedLogger(LogCategory.gui);

/// Bygger opdateret storage-data, gemmer til secure storage og verifierer.
/// Opdaterer eksisterende bruger-post (beholder testkey) eller opretter ny (genererer testkey).
/// Kast ved fejl (fx bruger ikke fundet efter save).
Future<void> _updateStorageWithNewKey(
  Storage storage,
  String userEmail,
  String newTokenKey,
) async {
  // --- Hent eksisterende data ---
  log('[executeUpdateSecurityKey] Henter currentData fra storage');
  final currentData = await storage.getUserStorageData();
  log('[executeUpdateSecurityKey] currentData hentet', {'itemCount': currentData.length});

  // --- Byg opdateret data ---
  // Findes brugeren allerede i storage: opdater token, behold testkey. Ellers: opret ny post med ny testkey.
  final existingUserIndex = currentData.indexWhere((item) => item.email == userEmail);
  final userExists = existingUserIndex >= 0;
  List<UserStorageData> updatedData;
  if (userExists) {
    log('[executeUpdateSecurityKey] Opdaterer eksisterende bruger');
    updatedData = currentData.map((item) {
      if (item.email == userEmail) {
        return UserStorageData(
          email: item.email,
          token: newTokenKey,
          testkey: item.testkey,
        );
      }
      return item;
    }).toList();
  } else {
    log('[executeUpdateSecurityKey] Opretter ny bruger-post');
    final newUserData = UserStorageData(
      email: userEmail,
      token: newTokenKey,
      testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
    );
    updatedData = [...currentData, newUserData];
  }

  // --- Gem og verificer ---
  log('[executeUpdateSecurityKey] Gemmer til secure storage');
  final jsonData = updatedData.map((e) => e.toJson()).toList();
  final jsonString = jsonEncode(jsonData);
  await storage.saveString(
    kUserStorageKey,
    jsonString,
    secure: true,
  );
  log('[executeUpdateSecurityKey] Verificerer save');
  final verificationData = await storage.getUserStorageData();
  verificationData.firstWhere(
    (item) => item.email == userEmail,
    orElse: () => throw Exception('User not found after save'),
  );
  log('[executeUpdateSecurityKey] Verifikation ok');
}

/// Viser succes-SnackBar og navigerer tilbage (pop). Ved pop-fejl: fallback til home.
void _showSuccessSnackBarAndNavigateBack(BuildContext context) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.success_message',
      fallback: 'Security key updated successfully',
    ),
    variant: CustomSnackBarVariant.success,
  );
  // --- Naviger tilbage ---
  // Pop til forrige skærm. Hvis pop fejler (fx ingen historik): prøv at gå til home.
  log('[executeUpdateSecurityKey] Viser succes, navigerer tilbage');
  try {
    context.pop();
    log('[executeUpdateSecurityKey] Pop lykkedes');
  } catch (navError) {
    log('[executeUpdateSecurityKey] Pop fejlede, prøver go(home)', {'navError': navError.toString()});
    try {
      context.go('/home');
      log('[executeUpdateSecurityKey] Fallback navigation til home lykkedes');
    } catch (fallbackError) {
      log('[executeUpdateSecurityKey] Fallback navigation fejlede', {'fallbackError': fallbackError.toString()});
    }
  }
}

/// Viser SnackBar ved exception under update.
void _showErrorSnackBar(BuildContext context, String errorText) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.error_message',
      fallback: 'Failed to update security key: $errorText',
      variables: {'error': errorText},
    ),
    variant: CustomSnackBarVariant.error,
  );
}

/// Viser SnackBar når den indtastede sikkerhedsnøgle ikke kan dekryptere user_extra.
void _showVerificationFailedSnackBar(BuildContext context) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.verification_failed_message',
      fallback: 'The security key you entered does not match your account. Please enter your original security key from your backup.',
    ),
    variant: CustomSnackBarVariant.error,
  );
}

/// Viser SnackBar når kontoen ikke har encryptedMasterkeyCheckValue at verificere mod.
void _showNoEncryptedValueSnackBar(BuildContext context) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.no_encrypted_value_message',
      fallback: 'Your account has no security key to verify. Use Reset instead.',
    ),
    variant: CustomSnackBarVariant.error,
  );
}

Future<void> executeUpdateSecurityKey({
  required WidgetRef ref,
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController securityKeyController,
  required void Function(bool) setLoadingState,
  required bool Function() isMounted,
}) async {
  log('[executeUpdateSecurityKey] START');

  // --- Form-validering ---
  // Tjekker at brugeren har udfyldt security key-feltet korrekt. Returnerer tidligt hvis validering fejler.
  if (!formKey.currentState!.validate()) {
    log('[executeUpdateSecurityKey] Form-validering fejlede');
    return;
  }
  log('[executeUpdateSecurityKey] Form ok');
  setLoadingState(true);

  try {
    // --- Hent bruger og forbered data ---
    // Vi skal have den aktuelle brugeres email og den nye key fra inputfeltet.
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? '';
    if (userEmail.isEmpty) {
      throw Exception('No authenticated user found');
    }
    final storage = ref.read(storageProvider.notifier);
    final newTokenKey = securityKeyController.text.trim();

    // --- Verificer at newTokenKey kan dekryptere user_extra ---
    final userExtraAsync = ref.read(userExtraNotifierProvider);
    if (!userExtraAsync.hasValue || userExtraAsync.value == null) {
      log('[executeUpdateSecurityKey] userExtra ikke tilgængelig');
      if (isMounted() && context.mounted) {
        securityKeyController.clear();
        _showVerificationFailedSnackBar(context);
      }
      return;
    }
    final encryptedValue = userExtraAsync.value!.encryptedMasterkeyCheckValue;
    if (encryptedValue == null || encryptedValue.isEmpty) {
      log('[executeUpdateSecurityKey] encryptedMasterkeyCheckValue er null/empty');
      if (isMounted() && context.mounted) {
        securityKeyController.clear();
        _showNoEncryptedValueSnackBar(context);
      }
      return;
    }
    try {
      final decrypted = await AESGCMEncryptionUtils.decryptString(encryptedValue, newTokenKey);
      if (decrypted != AppConstants.masterkeyCheckValue) {
        log('[executeUpdateSecurityKey] Dekrypteret værdi matcher ikke masterkeyCheckValue');
        if (isMounted() && context.mounted) {
          securityKeyController.clear();
          _showVerificationFailedSnackBar(context);
        }
        return;
      }
    } catch (e) {
      log('[executeUpdateSecurityKey] Dekrypteringsfejl', {'error': e.toString()});
      if (isMounted() && context.mounted) {
        securityKeyController.clear();
        _showVerificationFailedSnackBar(context);
      }
      return;
    }

    // --- Opdater storage ---
    // Kun nået hvis verifikation OK. Bygger opdateret data, gemmer og verificerer.
    await _updateStorageWithNewKey(storage, userEmail, newTokenKey);
    ref.read(masterKeyValidationProvider.notifier).markValidated();
    log('[executeUpdateSecurityKey] masterKeyValidationProvider sat til validated');

    // --- Vis feedback og naviger ---
    // Kun hvis widget stadig er mounted: vis succes-SnackBar og naviger tilbage (eller til home).
    if (isMounted() && context.mounted) {
      _showSuccessSnackBarAndNavigateBack(context);
    }
  } catch (e, st) {
    // --- Fejlhåndtering ---
    log('[executeUpdateSecurityKey] FEJL', {'error': e.toString(), 'stackTrace': st.toString()});
    if (isMounted() && context.mounted) {
      _showErrorSnackBar(context, e.toString());
    }
  } finally {
    // --- Oprydning ---
    if (isMounted()) {
      setLoadingState(false);
    }
    log('[executeUpdateSecurityKey] Færdig');
  }
}

// File created on 2026-02-10
