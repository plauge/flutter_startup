import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/authenticated_state.dart';
import '../../../core/auth/authenticated_state_provider.dart';
import '../../../providers/auth_provider.dart';
import 'base_screen.dart';

class SecurityValidationError implements Exception {
  final String message;
  SecurityValidationError(this.message);
}

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();

  @protected
  AuthenticatedScreen({super.key}) {
    (() async {
      final isValid = await _validateAccess();
      if (!isValid) {
        _container.read(authProvider.notifier).signOut();
        throw SecurityValidationError('Security validation failed');
      }
    })();
  }

  static Future<T> create<T extends AuthenticatedScreen>(T screen) async {
    final isValid = await _validateAccess();
    if (!isValid) {
      screen._container.read(authProvider.notifier).signOut();
      throw SecurityValidationError('Security validation failed');
    }
    return screen;
  }

  static Future<bool> _validateAccess() async {
    return true; // Currently always returns false
  }

  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authenticatedStateProvider);
    return buildAuthenticatedWidget(context, ref, auth);
  }
}
