import '../../exports.dart';
import '../../providers/security_provider.dart';
import '../../providers/phone_code_realtime_provider.dart';
import '../../services/i18n_service.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.gui);

  // Static create method - den eneste måde at instantiere siden
  static Future<HomePage> create() async {
    final page = HomePage();
    //log('HomePage created ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️');
    return AuthenticatedScreen.create(page);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);
    AppLogger.log(LogCategory.security, 'HomePage buildAuthenticatedWidget');

    return Scaffold(
      appBar: const AuthenticatedAppBar(showSettings: false),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.webCode),
                    //   icon: CardIcon.trash,
                    //   headerText: 'Hjemmeside / Webshop',
                    //   bodyText: 'Tjek hvem som ejer hjemmesiden',
                    //   backgroundColor: CardBackgroundColor.blue,
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.qrCodeScanning),
                    //   icon: CardIcon.qrCode,
                    //   headerText: 'QR-kode',
                    //   bodyText: 'Scan QR-koder på en sikker måde',
                    //   backgroundColor: CardBackgroundColor.green,
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),

                    CustomCard(
                      onPressed: () => context.go(RoutePaths.contacts),
                      icon: CardIcon.contacts,
                      headerText: I18nService().t('screen_home.contacts_header', fallback: 'Contacts'),
                      bodyText: I18nService().t('screen_home.contacts_description', fallback: 'Validate contacts, family, friends and network'),
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.textCode),
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
                                  onPressed: () => context.go(RoutePaths.phoneCode),
                                  icon: CardIcon.phone,
                                  headerText: I18nService().t('screen_home.phone_number_header', fallback: 'Phone number'),
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
                            onPressed: () => context.go(RoutePaths.textCode),
                            icon: CardIcon.email,
                            headerText: I18nService().t('screen_home.text_code_header', fallback: 'Email & Text Messages'),
                            bodyText: I18nService().t('screen_home.text_code_description', fallback: 'Check if the sender is who they say they are'),
                            backgroundColor: CardBackgroundColor.green,
                          ),
                        );
                      },
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),

                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.contacts),
                    //   icon: CardIcon.email,
                    //   headerText: 'Email & Text Messages',
                    //   bodyText: 'Validate an email or SMS/text message',
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.contacts),
                    //   icon: CardIcon.phone,
                    //   headerText: 'Phone Calls',
                    //   bodyText: 'Check the ID of who you are talking with',
                    // ),

                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // CustomCard(
                    //   onPressed: () => context.go(RoutePaths.invalidSecureKey),
                    //   icon: CardIcon.dots,
                    //   headerText: 'Invalid Secure Key',
                    //   bodyText: 'Invalid secure key screen',
                    // ),
                    // Gap(AppDimensionsTheme.getLarge(context)),
                    // if (kDebugMode)
                    //   CustomCard(
                    //     onPressed: () => context.go(RoutePaths.routeExplorer),
                    //     icon: CardIcon.dots,
                    //     headerText: 'Route Explorer',
                    //     bodyText: 'View all available routes in the app',
                    //     backgroundColor: CardBackgroundColor.blue,
                    //   ),
                    // if (kDebugMode) Gap(AppDimensionsTheme.getLarge(context)),
                    if (false) ...[
                      CustomButton(
                        text: 'Create PIN Code',
                        onPressed: () => context.go(RoutePaths.onboardingBegin),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.pin,
                      ),
                      CustomCard(
                        onPressed: () => context.go(RoutePaths.enterPincode),
                        icon: CardIcon.dots,
                        headerText: 'Enter PIN Code',
                        bodyText: 'Verify your identity with your PIN code',
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      FutureBuilder<List<dynamic>>(
                        future: ref.read(securityVerificationProvider.notifier).doCaretaking(AppVersionConstants.appVersionInt.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                CustomText(
                                  text: snapshot.data.toString(),
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.left,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                              ],
                            );
                          }
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                CustomText(
                                  text: 'Error: ${snapshot.error}',
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.left,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                              ],
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                      CustomButton(
                        text: 'Create PIN Code',
                        onPressed: () => context.go(RoutePaths.onboardingBegin),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.pin,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      StorageTestWidget(),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      const StorageTestToken(),
                      CustomButton(
                        text: 'Personal Information',
                        onPressed: () => context.go(RoutePaths.personalInfo),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.person,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomButton(
                        text: 'Onboarding Complete',
                        onPressed: () => context.go(RoutePaths.onboardingComplete),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.check_circle,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomButton(
                        text: 'Test Form',
                        onPressed: () => context.go(RoutePaths.testForm),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.edit_document,
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(counterProvider.notifier).increment();
                        },
                        child: Container(
                          color: AppColors.primaryColor(context),
                          child: Column(
                            children: [
                              Text(
                                'Klik på mig',
                                style: AppTheme.getBodyMedium(context),
                              ),
                              Text(
                                'Antal klik: $count',
                                style: AppTheme.getBodyMedium(context),
                              ),
                              Gap(AppDimensionsTheme.getMedium(context)),
                              Text(
                                'Bruger: ${auth.user.email}',
                                style: AppTheme.getBodyMedium(context),
                              ),
                              const FaceIdButton(),
                            ],
                          ),
                          padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                        ),
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      StorageTestWidget(),
                    ],
                    // if (kDebugMode) ...[
                    //   Gap(AppDimensionsTheme.getLarge(context)),
                    //   const StorageTestToken(),
                    // ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                text: I18nService().t('screen_home.settings_button', fallback: 'Settings'),
                onPressed: () => context.go(RoutePaths.settings),
                buttonType: CustomButtonType.secondary,
                icon: Icons.settings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
