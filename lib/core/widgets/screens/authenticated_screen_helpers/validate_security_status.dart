import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Added for Platform detection
import '../../../../exports.dart'; // Adjusted import path
import '../../../../providers/security_validation_provider.dart'; // Adjusted import path
import '../../../../providers/security_provider.dart'; // Added import for securityVerificationProvider
import '../../../constants/navigation_state_constants.dart'; // Added import for navigation state
// import '../../../../core/constants/route_paths.dart'; // Already in exports.dart

class SecurityValidationError implements Exception {
  final String message;
  SecurityValidationError(this.message);
}

Future<void> validateSecurityStatus(BuildContext context, WidgetRef ref, bool pin_code_protected) async {
  AppLogger.log(LogCategory.security, 'validateSecurityStatus');
  try {
    // Brug location for at få hele URL'en inklusive parametre
    final currentPath = GoRouter.of(context).routeInformationProvider.value.location;

    final response = await ref.read(securityVerificationProvider.notifier).doCaretaking((Platform.isIOS ? AppVersionConstants.appVersionIntIOS : AppVersionConstants.appVersionIntAndroid).toString());

    if (response.isEmpty) {
      throw SecurityValidationError('No response from security validation');
    }

    final firstResponse = response.first;
    // Save for later use
    // final statusCode = firstResponse['status_code'] as int;

    final data = firstResponse['data'] as Map<String, dynamic>;
    final payload = data['payload'] as String;

    switch (payload.toLowerCase()) {
      case 'pin_code_login':
        if ((context.mounted && currentPath != RoutePaths.enterPincode)) {
          if (pin_code_protected) {
            // Gem den nuværende sti før vi sender brugeren til PIN-kode siden
            NavigationStateConstants.savePreviousRoute(currentPath);
            context.go(RoutePaths.enterPincode);
          }
        } else {}
        break;

      case 'terms_confirm':
        if (context.mounted && currentPath != RoutePaths.termsOfService) {
          context.go(RoutePaths.termsOfService);
        }
        break;

      case 'maintenance_mode':
        if (context.mounted && currentPath != RoutePaths.maintenance) {
          context.go(RoutePaths.maintenance);
        }
        break;

      case 'minimum_required_version':
        if (context.mounted && currentPath != RoutePaths.updateApp) {
          context.go(RoutePaths.updateApp);
        }
        break;

      case 'expired':
        if (context.mounted) {
          AppLogger.log(LogCategory.security, 'validateSecurityStatus - Session expired, signing out');
          ref.read(authProvider.notifier).signOut();
          context.go(RoutePaths.login);
        }
        break;

      case 'ok':
        ref.read(securityValidationNotifierProvider.notifier).setValidated();
        break;

      default:
        throw SecurityValidationError('Unknown security payload: $payload');
    }
  } catch (e, stackTrace) {
    AppLogger.log(LogCategory.security, 'validateSecurityStatus FAILED: $e');
    AppLogger.log(LogCategory.security, 'validateSecurityStatus - pin_code_protected: $pin_code_protected, error type: ${e.runtimeType}');
    if (!context.mounted) return;
    // SecurityValidationError er en forventet fejl (f.eks. ny bruger uden security data)
    // Skal IKKE forårsage signout på ikke-PIN-beskyttede sider
    if (e is SecurityValidationError) {
      if (pin_code_protected) {
        AppLogger.log(LogCategory.security, 'validateSecurityStatus - SecurityValidationError on PIN-protected page, redirecting to PIN');
        final currentPath = GoRouter.of(context).routeInformationProvider.value.location;
        NavigationStateConstants.savePreviousRoute(currentPath);
        context.go(RoutePaths.enterPincode);
      } else {
        AppLogger.log(LogCategory.security, 'validateSecurityStatus - SecurityValidationError on non-PIN page, allowing access (new user or missing data)');
      }
      return;
    }
    // Network errors: send to PIN code (user might just have bad connection)
    final bool isNetworkError = e.toString().contains('SocketException') ||
        e.toString().contains('TimeoutException') ||
        e.toString().contains('Connection');
    if (isNetworkError && pin_code_protected) {
      AppLogger.log(LogCategory.security, 'validateSecurityStatus - Network error on PIN-protected page, redirecting to PIN');
      final currentPath = GoRouter.of(context).routeInformationProvider.value.location;
      NavigationStateConstants.savePreviousRoute(currentPath);
      context.go(RoutePaths.enterPincode);
    } else if (isNetworkError) {
      AppLogger.log(LogCategory.security, 'validateSecurityStatus - Network error on non-PIN page, allowing access');
    } else {
      // Unknown/unexpected errors: sign out for safety (fail-closed)
      AppLogger.log(LogCategory.security, 'validateSecurityStatus - Unknown error (${e.runtimeType}), signing out for safety: $e');
      ref.read(authProvider.notifier).signOut();
      context.go(RoutePaths.login);
    }
  }
}

// Created on: 2024-07-18 10:00
