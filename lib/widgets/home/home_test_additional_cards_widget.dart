import '../../exports.dart';
import 'package:flutter/foundation.dart';

class HomeTestAdditionalCardsWidget extends ConsumerWidget {
  const HomeTestAdditionalCardsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomCard(
          onPressed: () => context.go(RoutePaths.contacts),
          icon: CardIcon.email,
          headerText: 'Email & Text Messages',
          bodyText: 'Validate an email or SMS/text message',
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomCard(
          onPressed: () => context.go(RoutePaths.contacts),
          icon: CardIcon.phone,
          headerText: 'Phone Calls',
          bodyText: 'Check the ID of who you are talking with',
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomCard(
          onPressed: () => context.go(RoutePaths.invalidSecureKey),
          icon: CardIcon.dots,
          headerText: 'Invalid Secure Key',
          bodyText: 'Invalid secure key screen',
        ),
        if (kDebugMode) ...[
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomCard(
            onPressed: () => context.go(RoutePaths.routeExplorer),
            icon: CardIcon.dots,
            headerText: 'Route Explorer',
            bodyText: 'View all available routes in the app',
            backgroundColor: CardBackgroundColor.blue,
          ),
        ],
        if (kDebugMode) ...[
          Gap(AppDimensionsTheme.getLarge(context)),
          const StorageTestToken(),
        ],
      ],
    );
  }
}

// Created on 2025-01-16 at 17:10

