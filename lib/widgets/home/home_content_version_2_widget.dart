import '../../exports.dart';
import '../text_code/custom_text_code_search_widget.dart';
import '../../../widgets/phone_code/phone_code_content_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeContentVersion2Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeContentVersion2Widget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);
    final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);

    return phoneNumbersAsync.when(
      data: (phoneNumbersResponses) {
        final phoneNumbersCount = phoneNumbersResponses.isNotEmpty ? phoneNumbersResponses.first.data.payload.length : 0;

        // Only show PhoneCodeContentWidget if phoneNumbersCount > 0 AND there are active calls
        final hasActiveCalls = phoneCodesAsync.maybeWhen(
          data: (phoneCodes) => phoneCodes.isNotEmpty,
          orElse: () => false,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              'assets/images/id-truster-badge.svg',
              height: 80,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            // Show CustomTextCodeSearchWidget if no active calls OR no phone numbers
            if (!hasActiveCalls || phoneNumbersCount == 0) CustomTextCodeSearchWidget(),
            // Only show PhoneCodeContentWidget if phoneNumbersCount > 0 AND there are active calls
            if (phoneNumbersCount > 0 && hasActiveCalls) const PhoneCodeContentWidget(),
          ],
        );
      },
      loading: () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SvgPicture.asset(
            'assets/images/id-truster-badge.svg',
            height: 80,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stack) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SvgPicture.asset(
            'assets/images/id-truster-badge.svg',
            height: 80,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomText(
            text: I18nService().t(
              'screen_home.error_loading_phone_numbers',
              fallback: 'Error loading phone numbers: $error',
              variables: {'error': error.toString()},
            ),
            type: CustomTextType.info,
          ),
        ],
      ),
    );
  }
}

// Created on 2025-01-16 at 17:30
