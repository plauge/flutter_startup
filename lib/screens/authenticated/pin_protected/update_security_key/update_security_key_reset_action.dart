// === RESUMÉ ===
// executeUpdateSecurityKeyReset nulstiller brugerens security token via Supabase RPC
// security_reset_security_token_data. Ved succes: sletter contacts-data, genererer ny token,
// opdaterer user_extra, viser succes-SnackBar og navigerer til home.
// Kaldes fra: update_security_key_screen.dart når bruger bekræfter reset i dialogen.

import '../../../../exports.dart';
import '../../../../providers/security_reset_provider.dart';
import '../../../../core/widgets/screens/authenticated_screen_helpers/generate_and_persist_user_token.dart';

final log = scopedLogger(LogCategory.gui);

/// Kalder Supabase RPC security_reset_security_token_data. Ved succes genereres ny token
/// og user_extra opdateres. Returnerer true hvis reset lykkedes.
Future<bool> _callResetRpcAndGenerateToken(WidgetRef ref) async {
  log('[executeUpdateSecurityKeyReset] Kalder RPC security_reset_security_token_data');
  final securityResetNotifier = ref.read(securityResetProvider.notifier);
  final success = await securityResetNotifier.resetSecurityTokenData();
  log('[executeUpdateSecurityKeyReset] RPC svar modtaget', {'success': success});
  if (success) {
    log('[executeUpdateSecurityKeyReset] Genererer ny token og opdaterer user_extra');
    await generateAndPersistUserToken(ref);
    log('[executeUpdateSecurityKeyReset] Token og user_extra opdateret');
  }
  return success;
}

/// Viser succes-SnackBar og navigerer til home. Forudsætter context.mounted.
void _showSuccessSnackBarAndNavigateHome(BuildContext context) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.reset_success_message',
      fallback: 'Security key reset successfully. All contacts have been deleted.',
    ),
    variant: CustomSnackBarVariant.success,
  );
  log('[executeUpdateSecurityKeyReset] Viser succes, navigerer til home');
  try {
    context.go('/home');
    log('[executeUpdateSecurityKeyReset] Navigation til home lykkedes');
  } catch (navError) {
    log('[executeUpdateSecurityKeyReset] Navigation fejl', {'navError': navError.toString()});
  }
}

/// Viser SnackBar når RPC returnerede ikke-succes (fx status_code != 200).
void _showFailedSnackBar(BuildContext context) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.reset_failed_message',
      fallback: 'Failed to reset security key. Please try again.',
    ),
    variant: CustomSnackBarVariant.error,
  );
}

/// Viser SnackBar ved exception under reset (fx netværksfejl).
void _showErrorSnackBar(BuildContext context, String errorText) {
  CustomSnackBar.show(
    context: context,
    text: I18nService().t(
      'screen_update_security_key.reset_error_message',
      fallback: 'Error during reset: $errorText',
      variables: {'error': errorText},
    ),
    variant: CustomSnackBarVariant.error,
  );
}

Future<void> executeUpdateSecurityKeyReset({
  required WidgetRef ref,
  required BuildContext context,
  required void Function(bool) setLoadingState,
  required bool Function() isMounted,
}) async {
  log('[executeUpdateSecurityKeyReset] START');
  setLoadingState(true);

  try {
    final success = await _callResetRpcAndGenerateToken(ref);
    log('[executeUpdateSecurityKeyReset] RPC + token generation færdig', {'success': success});

    if (isMounted() && context.mounted) {
      if (success) {
        _showSuccessSnackBarAndNavigateHome(context);
      } else {
        _showFailedSnackBar(context);
      }
    }
  } catch (e, st) {
    log('[executeUpdateSecurityKeyReset] FEJL', {'error': e.toString(), 'stackTrace': st.toString()});
    if (isMounted() && context.mounted) {
      _showErrorSnackBar(context, e.toString());
    }
  } finally {
    if (isMounted()) {
      setLoadingState(false);
    }
    log('[executeUpdateSecurityKeyReset] Færdig');
  }
}

// File created on 2026-02-10
