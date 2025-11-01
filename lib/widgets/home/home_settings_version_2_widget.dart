import '../../exports.dart';

class HomeSettingsVersion2Widget extends ConsumerWidget {
  const HomeSettingsVersion2Widget({super.key});

  void _trackButtonPressed(WidgetRef ref, String buttonType) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_button_pressed', {
      'button_type': buttonType,
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Settings Button
            GestureDetector(
              key: const Key('home_settings_button_v2'),
              onTap: () {
                _trackButtonPressed(ref, 'settings');
                context.go(RoutePaths.settings);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings,
                      color: const Color(0xFF014459),
                      size: 32,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Text(
                      I18nService().t('screen_home.settings_button', fallback: 'Settings'),
                      style: const TextStyle(
                        color: Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Contacts Button
            GestureDetector(
              key: const Key('home_contacts_button_v2'),
              onTap: () {
                _trackButtonPressed(ref, 'contacts');
                context.go(RoutePaths.contacts);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: const Color(0xFF014459),
                      size: 32,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Text(
                      I18nService().t('screen_home.contacts_button', fallback: 'Contacts'),
                      style: const TextStyle(
                        color: Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Created on 2025-01-16 at 17:25

