import 'dart:io';
import '../../exports.dart';
import '../../providers/text_code_search_result_provider.dart';

class HomeSettingsVersion2Widget extends ConsumerStatefulWidget {
  const HomeSettingsVersion2Widget({super.key});

  @override
  ConsumerState<HomeSettingsVersion2Widget> createState() => _HomeSettingsVersion2WidgetState();
}

class _HomeSettingsVersion2WidgetState extends ConsumerState<HomeSettingsVersion2Widget> with WidgetsBindingObserver {
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
        final keyboardVisible = bottomInset > 0;
        if (_keyboardVisible != keyboardVisible) {
          setState(() {
            _keyboardVisible = keyboardVisible;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Called when keyboard shows/hides
    if (mounted) {
      final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
      final keyboardVisible = bottomInset > 0;
      if (_keyboardVisible != keyboardVisible) {
        setState(() {
          _keyboardVisible = keyboardVisible;
        });
      }
    }
  }

  void _trackButtonPressed(WidgetRef ref, String buttonType) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_button_pressed', {
      'button_type': buttonType,
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    final buttons = Padding(
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
    );

    return Platform.isAndroid ? SafeArea(top: false, child: buttons) : buttons;
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);
    final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);
    final hasSearchResult = ref.watch(textCodeSearchResultProvider);

    // Skjul knapperne når keyboardet er åbent
    if (_keyboardVisible) {
      return const SizedBox.shrink();
    }

    return phoneNumbersAsync.when(
      data: (phoneNumbersResponses) {
        final phoneNumbersCount = phoneNumbersResponses.isNotEmpty ? phoneNumbersResponses.first.data.payload.length : 0;

        // Check if there are active calls
        final hasActiveCalls = phoneCodesAsync.maybeWhen(
          data: (phoneCodes) => phoneCodes.isNotEmpty,
          orElse: () => false,
        );

        // Only show buttons if phoneNumbersCount == 0 OR if there are no active calls AND no search result
        if (phoneNumbersCount > 0 && hasActiveCalls) {
          return const SizedBox.shrink();
        }

        // Don't show buttons if there's a search result
        if (hasSearchResult) {
          return const SizedBox.shrink();
        }

        return _buildButtons(context, ref);
      },
      loading: () => _buildButtons(context, ref),
      error: (error, stack) => _buildButtons(context, ref),
    );
  }
}

// Created on 2025-01-16 at 17:25
