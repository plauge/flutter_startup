import 'package:flutter/material.dart';
import '../../core/config/env_config.dart';

/// A banner widget that displays the current environment
/// Only visible in non-production environments (TEST or DEVELOPMENT)
class CustomEnvironmentBanner extends StatelessWidget {
  final Widget child;

  const CustomEnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show banner in production (based on actual database connection)
    if (EnvConfig.isActuallyProduction) {
      return child;
    }

    // Show banner based on actual database connection, not just configured environment
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        key: const Key('environment_banner'),
        message: EnvConfig.actualEnvironmentName,
        location: BannerLocation.topEnd,
        color: _getBannerColor(),
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        child: child,
      ),
    );
  }

  Color _getBannerColor() {
    // Use actual environment based on database connection
    switch (EnvConfig.actualEnvironment) {
      case Environment.test:
        return Colors.orange;
      case Environment.development:
        return Colors.purple;
      case Environment.production:
        return Colors.green; // Should never show, but just in case
    }
  }
}

// Created: 2025-12-17
