import 'dart:io';

import '../../exports.dart';

class PhoneCodeHistoryButton extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const PhoneCodeHistoryButton({super.key});

  void _navigateToHistory(BuildContext context) {
    log('_navigateToHistory: Navigating to phone code history from lib/widgets/phone_code/phone_code_history_button.dart');
    context.go(RoutePaths.phoneCodeHistory);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);
    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);

    return phoneNumbersAsync.when(
      data: (phoneNumbersResponses) {
        // Tjek antallet af telefonnumre
        final phoneNumbersCount = phoneNumbersResponses.isNotEmpty ? phoneNumbersResponses.first.data.payload.length : 0;

        // Skjul History knap hvis ingen telefonnumre
        if (phoneNumbersCount == 0) {
          return const SizedBox.shrink();
        }

        return phoneCodesAsync.maybeWhen(
          data: (phoneCodes) {
            // Vis kun History knap hvis der ikke er aktive opkald
            if (phoneCodes.isEmpty) {
              return Builder(
                builder: (context) {
                  final historyButton = Padding(
                    padding: EdgeInsets.only(
                      bottom: AppDimensionsTheme.getLarge(context),
                    ),
                    child: CustomButton(
                      key: const Key('phone_code_history_button'),
                      text: I18nService().t('screen_phone_code.history_button', fallback: 'History'),
                      onPressed: () => _navigateToHistory(context),
                      buttonType: CustomButtonType.primary,
                    ),
                  );

                  return Platform.isAndroid ? SafeArea(top: false, child: historyButton) : historyButton;
                },
              );
            }
            return const SizedBox.shrink(); // Skjul knappen hvis der er aktive opkald
          },
          orElse: () => const SizedBox.shrink(), // Skjul under loading/error
        );
      },
      loading: () => const SizedBox.shrink(), // Skjul under loading
      error: (error, stack) => const SizedBox.shrink(), // Skjul ved fejl
    );
  }
}

// Created on 2025-01-16 at 16:45

