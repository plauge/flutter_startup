import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'dart:io';
import '../../../../exports.dart';

/// Set to true to force Face ID authentication even in debug mode
///
/// **To enable Face ID in debug mode:**
/// Change line 15 in this file from `false` to `true`:
/// `lib/core/widgets/screens/authenticated_screen_helpers/validate_face_id_status.dart`
///
/// **Line 15:** Change `const bool _forceFaceIdInDebugMode = false;` to `const bool _forceFaceIdInDebugMode = true;`
///
/// When set to `true`, Face ID will be required even when running in debug mode.
/// When set to `false` (default), Face ID is skipped in debug mode for easier development.
const bool _forceFaceIdInDebugMode = false;

/// Tracks Face ID authentication attempts for analytics
void _trackAuthenticationAttempt(WidgetRef ref, String result, String screenName) {
  try {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('face_id_auth_attempt', {
      'result': result,
      'screen': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    // Analytics fejl påvirker ikke app funktionalitet
  }
}

/// Shows alert dialog when Face ID authentication fails
void _showAuthenticationFailedAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        I18nService().t('screen_contact_verification.auth_failed_title', fallback: 'Authentication Failed'),
        style: AppTheme.getBodyMedium(context),
      ),
      content: Text(
        I18nService().t('screen_contact_verification.auth_failed_message', fallback: 'Biometric authentication failed. Redirecting to contacts.'),
        style: AppTheme.getBodyMedium(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
        ),
      ],
    ),
  );
}

/// Shows alert dialog when biometric authentication is not available
void _showAuthenticationNotAvailableAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        I18nService().t('screen_contact_verification.auth_not_available_title', fallback: 'Biometric Authentication Not Available'),
        style: AppTheme.getBodyMedium(context),
      ),
      content: Text(
        I18nService().t('screen_contact_verification.auth_not_available_message', fallback: 'Biometric authentication is not available on your device.'),
        style: AppTheme.getBodyMedium(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
        ),
      ],
    ),
  );
}

/// Shows alert dialog when biometric authentication is not enrolled
void _showBiometricNotEnrolledAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        I18nService().t('screen_contact_verification.auth_not_enrolled_title', fallback: 'Biometric Authentication Not Set Up'),
        style: AppTheme.getBodyMedium(context),
      ),
      content: Text(
        I18nService().t('screen_contact_verification.auth_not_enrolled_message', fallback: 'Biometric authentication is not set up on your device. Please enable it in Settings > Security.'),
        style: AppTheme.getBodyMedium(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
        ),
      ],
    ),
  );
}

/// Validates Face ID/biometric authentication status
/// Returns true if authentication succeeded or was skipped, false if it failed
///
/// This function handles:
/// - Debug mode (skips authentication unless forceFaceIdInDebug is true)
/// - Demo users (skips authentication)
/// - Biometric availability checks
/// - Face ID authentication with proper error handling
///
/// Parameters:
/// - [forceFaceIdInDebug]: If true, forces Face ID authentication even in debug mode (default: false)
/// - [handleNavigation]: If true, handles navigation on failure (default: false)
///
/// Note: Navigation on failure should be handled by the caller
Future<bool> validateFaceIdStatus(BuildContext context, WidgetRef ref, String screenName, {bool handleNavigation = false, bool forceFaceIdInDebug = false}) async {
  final log = scopedLogger(LogCategory.security);
  log('validateFaceIdStatus CALLED - lib/core/widgets/screens/authenticated_screen_helpers/validate_face_id_status.dart', {
    'screenName': screenName,
    'handleNavigation': handleNavigation,
    'forceFaceIdInDebug': forceFaceIdInDebug,
  });

  // Check if in debug mode
  bool isDebugMode = false;
  assert(() {
    isDebugMode = true;
    return true;
  }());

  // Skip authentication in debug mode (unless forceFaceIdInDebug is true or _forceFaceIdInDebugMode is true)
  if (isDebugMode && !forceFaceIdInDebug && !_forceFaceIdInDebugMode) {
    _trackAuthenticationAttempt(ref, 'debug_mode_skipped', screenName);
    return true;
  }

  // Skip authentication if user is demo user
  try {
    final userExtraAsync = await ref.read(userExtraNotifierProvider.future);
    if (userExtraAsync?.userType == 'demo') {
      _trackAuthenticationAttempt(ref, 'demo_user_skipped', screenName);
      return true;
    }
  } catch (e) {
    // If we can't check user type, continue with authentication
  }

  // Normal authentication flow for non-debug mode
  final LocalAuthentication auth = ref.read(localAuthProvider);
  try {
    // Check if biometric authentication is available
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();

    print('DEBUG: canCheckBiometrics: $canCheckBiometrics');
    print('DEBUG: isDeviceSupported: $isDeviceSupported');
    print('DEBUG: Platform.isAndroid: ${Platform.isAndroid}');

    if (!canCheckBiometrics || !isDeviceSupported) {
      print('DEBUG: Biometric authentication not available');
      _trackAuthenticationAttempt(ref, 'biometric_not_available', screenName);
      if (context.mounted && handleNavigation) {
        _showAuthenticationNotAvailableAlert(context);
        context.go(RoutePaths.home);
      }
      return false;
    }

    // Check available biometrics
    final availableBiometrics = await auth.getAvailableBiometrics();
    print('DEBUG: Available biometrics: $availableBiometrics');

    final bool didAuthenticate = await auth.authenticate(
      localizedReason: Platform.isIOS ? 'Godkend venligst med Face ID' : 'Godkend venligst med biometric authentication',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
        useErrorDialogs: true,
      ),
    );

    if (!didAuthenticate) {
      _trackAuthenticationAttempt(ref, 'authentication_failed', screenName);
      if (context.mounted && handleNavigation) {
        _showAuthenticationFailedAlert(context);
        context.go(RoutePaths.home);
      }
      return false;
    }

    _trackAuthenticationAttempt(ref, 'authentication_success', screenName);
    return true;
  } catch (e) {
    print('DEBUG: Authentication exception: $e');
    if (e is PlatformException) {
      print('DEBUG: PlatformException code: ${e.code}');
      print('DEBUG: PlatformException message: ${e.message}');
      print('DEBUG: PlatformException details: ${e.details}');

      if (context.mounted && handleNavigation) {
        if (e.code == auth_error.notAvailable) {
          _trackAuthenticationAttempt(ref, 'biometric_not_available_exception', screenName);
          _showAuthenticationNotAvailableAlert(context);
        } else if (e.code == auth_error.notEnrolled) {
          _trackAuthenticationAttempt(ref, 'biometric_not_enrolled', screenName);
          _showBiometricNotEnrolledAlert(context);
        } else {
          _trackAuthenticationAttempt(ref, 'authentication_exception', screenName);
          _showAuthenticationFailedAlert(context);
        }
        context.go(RoutePaths.home);
      }
      return false;
    } else if (context.mounted && handleNavigation) {
      _trackAuthenticationAttempt(ref, 'authentication_exception', screenName);
      _showAuthenticationFailedAlert(context);
      context.go(RoutePaths.home);
      return false;
    }
    return false;
  }
}

// Created: 2025-01-27
