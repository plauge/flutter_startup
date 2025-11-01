import 'dart:io';

import '../../exports.dart';

class HomeSettingsVersion1Widget extends ConsumerWidget {
  const HomeSettingsVersion1Widget({super.key});

  void _trackSettingsButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_settings_button_pressed', {
      'button_type': 'settings',
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        final buttons = Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // FCM Token Button (Debug/Test only) - moved to HomeTestWidget
              // Settings Button
              CustomButton(
                key: const Key('home_settings_button'),
                text: I18nService().t('screen_home.settings_button', fallback: 'Settings'),
                onPressed: () {
                  _trackSettingsButtonPressed(ref);
                  context.go(RoutePaths.settings);
                },
                buttonType: CustomButtonType.secondary,
                icon: Icons.settings,
              ),
            ],
          ),
        );

        return Platform.isAndroid ? SafeArea(top: false, child: buttons) : buttons;
      },
    );
  }
}

// Created on 2025-01-16 at 17:20
