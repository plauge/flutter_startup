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
    final statusCode = firstResponse['status_code'] as int;

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
          // ref.read(authProvider.notifier).signOut();
          // context.go(RoutePaths.login);
        }
        break;

      case 'ok':
        ref.read(securityValidationNotifierProvider.notifier).setValidated();
        break;

      default:
        throw SecurityValidationError('Unknown security payload: $payload');
    }
  } catch (e, stackTrace) {
    // Remove the logout logic here since we want to handle 401 properly
    // if (context.mounted) {
    //   //ref.read(authProvider.notifier).signOut();
    //   //context.go(RoutePaths.login);
    // }
  }
}

// Created on: 2024-07-18 10:00
