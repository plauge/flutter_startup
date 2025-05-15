import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../exports.dart'; // Path to main exports file. Adjusted path if needed.
import '../../../../providers/auth_validation_provider.dart'; // Direct import for authValidationProvider

Widget? validateAuthSession(BuildContext context, WidgetRef ref) {
  final authValidation = ref.watch(authValidationProvider);
  return authValidation.when(
    loading: () => const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
    error: (error, stack) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).signOut();
        GoRouter.of(context).go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
    data: (response) {
      // Assuming response is dynamic or has a statusCode field.
      // If response is a specific type, cast it or access statusCode directly.
      if (response.statusCode != 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).signOut();
          GoRouter.of(context).go('/login');
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return null;
    },
  );
}

// Created on: 2024-07-18 10:45
