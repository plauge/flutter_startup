import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeContentVersion1Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeContentVersion1Widget({super.key});

  void _trackCardNavigation(WidgetRef ref, String cardType, String destination) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('home_card_pressed', {
      'card_type': cardType,
      'destination': destination,
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getMedium(context)),
        SvgPicture.asset(
          'assets/images/id-truster-badge.svg',
          height: 100,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t('screen_home.what_to_check', fallback: 'What to check?'),
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomCard(
          onPressed: () {
            _trackCardNavigation(ref, 'contacts', 'contacts');
            context.go(RoutePaths.contacts);
          },
          icon: CardIcon.contacts,
          headerText: I18nService().t('screen_home.contacts_header', fallback: 'Contacts'),
          bodyText: I18nService().t('screen_home.contacts_description', fallback: 'Validate contacts, family, friends and network'),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomCard(
          onPressed: () {
            _trackCardNavigation(ref, 'text_code', 'text_code');
            context.go(RoutePaths.textCode);
          },
          icon: CardIcon.email,
          headerText: I18nService().t('screen_home.text_code_header', fallback: 'Email & Text Messages'),
          bodyText: I18nService().t('screen_home.text_code_description', fallback: 'Check if the sender is who they say they are'),
          backgroundColor: CardBackgroundColor.green,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Consumer(
          builder: (context, ref, child) {
            final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);

            return phoneCodesAsync.maybeWhen(
              data: (phoneCodes) {
                final hasActiveCalls = phoneCodes.isNotEmpty;
                final activeCallsCount = phoneCodes.length;

                return Stack(
                  children: [
                    CustomCard(
                      onPressed: () {
                        _trackCardNavigation(ref, 'phone_code', 'phone_code');
                        context.go(RoutePaths.home);
                      },
                      icon: CardIcon.phone,
                      headerText: I18nService().t('screen_home.phone_number_header', fallback: 'Phone calls'),
                      bodyText: I18nService().t('screen_home.phone_number_description', fallback: 'Check if you are talking to the right person'),
                      backgroundColor: CardBackgroundColor.green,
                    ),
                    if (hasActiveCalls)
                      Positioned(
                        top: 0,
                        left: 50,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            activeCallsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              orElse: () => CustomCard(
                onPressed: () {
                  _trackCardNavigation(ref, 'phone_code', 'phone_code');
                  context.go(RoutePaths.home);
                },
                icon: CardIcon.phone,
                headerText: I18nService().t('screen_home.phone_number_header', fallback: 'Phone calls'),
                bodyText: I18nService().t('screen_home.phone_number_description', fallback: 'Check if you are talking to the right person'),
                backgroundColor: CardBackgroundColor.green,
              ),
            );
          },
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        //const HomeTestAdditionalCardsWidget(),
        // if (true) ...[
        //   const HomeTestWidget(),
        // ],
      ],
    );
  }
}

// Created on 2025-01-16 at 17:15
