import '../../exports.dart';
import '../text_code/custom_text_code_search_widget.dart';
import '../../../widgets/phone_code/phone_code_content_widget.dart';
import '../../widgets/contacts/contact_list_widget.dart';

class HomeContentVersion3Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeContentVersion3Widget({super.key});

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

        log('[home_content_version_3_widget.dart][build] phoneNumbersCount: $phoneNumbersCount, hasActiveCalls: $hasActiveCalls, hasSearchResult: $hasSearchResult');

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show PhoneCodeContentWidget only if phoneNumbersCount > 0 AND there are active calls, otherwise show CustomTextCodeSearchWidget with ContactListWidget
            if (phoneNumbersCount > 0 && hasActiveCalls)
              const PhoneCodeContentWidget()
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextCodeSearchWidget(),
                  if (!hasSearchResult) const ContactListWidget(),
                ],
              ),
          ],
        );
      },
      loading: () {
        // In loading state, check if we already have phoneCodes data to show the right content
        return phoneCodesAsync.maybeWhen(
          data: (phoneCodes) {
            // We have phoneCodes data - check if there are active calls
            final hasActiveCalls = phoneCodes.isNotEmpty;
            // If there are active calls, show PhoneCodeContentWidget (which will handle its own loading)
            // Otherwise show the normal content structure
            if (hasActiveCalls) {
              return const PhoneCodeContentWidget();
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextCodeSearchWidget(),
                  if (!hasSearchResult) const ContactListWidget(),
                ],
              );
            }
          },
          orElse: () {
            // No phoneCodes data yet - show normal content structure (will show loading inside if needed)
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextCodeSearchWidget(),
                if (!hasSearchResult) const ContactListWidget(),
              ],
            );
          },
        );
      },
      error: (error, stack) => CustomText(
        text: I18nService().t(
          'screen_home.error_loading_phone_numbers',
          fallback: 'Error loading phone numbers: $error',
          variables: {'error': error.toString()},
        ),
        type: CustomTextType.info,
      ),
    );
  }
}

// Created on 2025-01-16 at 18:15
