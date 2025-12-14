import '../../exports.dart';
import '../../widgets/contacts/add_contact_button.dart';

class HomeSettingsVersion3Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);
  final GlobalKey? addContactButtonKey;
  final bool isLastShowcase;
  final VoidCallback? onShowcaseComplete;

  const HomeSettingsVersion3Widget({
    super.key,
    this.addContactButtonKey,
    this.isLastShowcase = false,
    this.onShowcaseComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);
    final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);
    final hasSearchResult = ref.watch(textCodeSearchResultProvider);

    return phoneNumbersAsync.when(
      data: (phoneNumbersResponses) {
        final phoneNumbersCount = phoneNumbersResponses.isNotEmpty ? phoneNumbersResponses.first.data.payload.length : 0;

        // Check if there are active phone calls
        final hasActiveCalls = phoneCodesAsync.maybeWhen(
          data: (phoneCodes) => phoneCodes.isNotEmpty,
          orElse: () => false,
        );

        log('[home_settings_version_3_widget.dart][build] phoneNumbersCount: $phoneNumbersCount, hasActiveCalls: $hasActiveCalls, hasSearchResult: $hasSearchResult');

        // Don't show anything if there are active calls or if there's a search result
        if (phoneNumbersCount > 0 && hasActiveCalls) {
          return const SizedBox.shrink();
        }

        // Don't show anything if there's a search result
        if (hasSearchResult) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.bottomRight,
          child: Builder(
            builder: (context) {
              final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

              final Widget paddedButton = Padding(
                padding: EdgeInsets.only(
                  right: AppDimensionsTheme.getMedium(context),
                  // Lift the button ~10px higher than current placement
                  bottom: AppDimensionsTheme.getSmall(context) + 10.0,
                ),
                child: AddContactButton(
                  onTap: () => context.go(RoutePaths.connect),
                  showcaseKey: addContactButtonKey,
                  isLast: isLastShowcase,
                  onShowcaseComplete: onShowcaseComplete,
                ),
              );

              // Only wrap with SafeArea on Android to avoid misplacement on iOS
              // (workspace memory rule).
              return isAndroid ? SafeArea(top: false, child: paddedButton) : paddedButton;
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

// Created on 2025-01-27 at 12:00:00
