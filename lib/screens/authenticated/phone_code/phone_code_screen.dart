import 'dart:async';

import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';

import 'package:flutter_svg/svg.dart';

class PhoneCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  int _retryCount = 0;
  Timer? _retryTimer;

  PhoneCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneCodeScreen> create() async {
    final screen = PhoneCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void dispose() {
    _retryTimer?.cancel();
  }

  void _navigateToHistory(BuildContext context) {
    log('_navigateToHistory: Navigating to phone code history from lib/screens/authenticated/phone_code/phone_code_screen.dart');
    context.go(RoutePaths.phoneCodeHistory);
  }

  void _navigateToHome(BuildContext context) {
    log('_navigateToHome: Too many retry attempts, navigating to home from lib/screens/authenticated/phone_code/phone_code_screen.dart');
    context.go(RoutePaths.home);
  }

  void _handleRetry(WidgetRef ref, BuildContext context) {
    _retryCount++;
    log('_handleRetry: Starting retry attempt $_retryCount/40 from lib/screens/authenticated/phone_code/phone_code_screen.dart');

    // Hvis vi har prøvet 40 gange, så send brugeren til Home
    if (_retryCount > 40) {
      log('_handleRetry: Max retry attempts reached, navigating to home');
      _navigateToHome(context);
      return;
    }

    // Bestem delay baseret på retry count
    int delaySeconds;
    if (_retryCount <= 20) {
      delaySeconds = 3; // De første 20 gange: hvert 3. sekund
    } else {
      delaySeconds = 10; // De næste 20 gange: hvert 10. sekund
    }

    log('_handleRetry: Scheduling retry in $delaySeconds seconds (attempt $_retryCount/40)');

    // Annuller eksisterende timer hvis der er en
    _retryTimer?.cancel();

    // Start ny timer
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      log('_handleRetry: Executing retry attempt $_retryCount - refreshing phoneCodesRealtimeStreamProvider');
      ref.refresh(phoneCodesRealtimeStreamProvider);
    });
  }

  void _resetRetryCount() {
    log('_resetRetryCount: Resetting retry count from lib/screens/authenticated/phone_code/phone_code_screen.dart');
    _retryCount = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  String _buildRetryMessage() {
    if (_retryCount == 0) {
      return I18nService().t('screen_phone_code.retry_message_initial', fallback: 'Trying again in 3 seconds...');
    } else if (_retryCount <= 20) {
      return I18nService().t('screen_phone_code.retry_message_fast', fallback: 'Try $_retryCount/40 - Next try in 3 seconds...', variables: {'attempt': _retryCount.toString()});
    } else if (_retryCount <= 40) {
      return I18nService().t('screen_phone_code.retry_message_slow', fallback: 'Try $_retryCount/40 - Next try in 10 seconds...', variables: {'attempt': _retryCount.toString()});
    } else {
      return I18nService().t('screen_phone_code.retry_message_final', fallback: 'Too many tries - sending you to home...');
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_code.title', fallback: 'Phone calls'),
        backRoutePath: RoutePaths.home,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gap(AppDimensionsTheme.getLarge(context)),
                      // Realtime phone codes liste med dynamisk header
                      Consumer(
                        builder: (context, ref, child) {
                          final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);

                          return phoneCodesAsync.maybeWhen(
                            data: (phoneCodes) {
                              // Data loadet succesfuldt - nulstil retry count
                              _resetRetryCount();

                              if (phoneCodes.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.6, // 60% af skærmhøjden
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/phone/phone_alert.svg',
                                        width: 60,
                                        height: 60,
                                      ),
                                      Gap(AppDimensionsTheme.getLarge(context)),
                                      CustomText(
                                        text: I18nService().t('screen_phone_code.no_active_calls', fallback: 'No active calls'),
                                        type: CustomTextType.head,
                                        alignment: CustomTextAlignment.center,
                                      ),
                                      Gap(AppDimensionsTheme.getLarge(context)),
                                      CustomText(
                                        text: I18nService().t('screen_phone_code.no_active_calls_description', fallback: 'Here we will list all the phone calls that have been made to you.'),
                                        type: CustomTextType.bread,
                                        alignment: CustomTextAlignment.center,
                                      ),
                                      Gap(AppDimensionsTheme.getLarge(context)),
                                      const CustomText(
                                        text: '',
                                        type: CustomTextType.info,
                                        alignment: CustomTextAlignment.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  CustomText(
                                    text: I18nService().t('screen_phone_code.active_calls', fallback: 'Active calls'),
                                    type: CustomTextType.head,
                                    alignment: CustomTextAlignment.center,
                                  ),
                                  Gap(AppDimensionsTheme.getLarge(context)),
                                  // Vis alle phone codes i stedet for kun den første
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: phoneCodes.length,
                                    itemBuilder: (context, index) {
                                      final phoneCode = phoneCodes[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index < phoneCodes.length - 1 ? AppDimensionsTheme.getMedium(context) : 0,
                                        ),
                                        child: PhoneCallWidget(
                                          initiatorName: phoneCode.initiatorInfo['name'],
                                          confirmCode: phoneCode.confirmCode,
                                          initiatorCompany: phoneCode.initiatorInfo['company'],
                                          initiatorEmail: phoneCode.initiatorInfo['email'],
                                          initiatorPhone: phoneCode.initiatorInfo['phone'],
                                          initiatorAddress: phoneCode.initiatorInfo['address'],
                                          createdAt: DateTime.now(),
                                          lastControlDateAt: DateTime(2024, 12, 24),
                                          history: false,
                                          isConfirmed: true,
                                          phoneCodesId: phoneCode.phoneCodesId,
                                          logoPath: phoneCode.initiatorInfo['logo_path'],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                            error: (error, stack) {
                              // Start retry-mekanismen automatisk
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _handleRetry(ref, context);
                              });

                              return Column(
                                children: [
                                  CustomText(
                                    text: I18nService().t('screen_phone_code.loading_error', fallback: 'Loading error'),
                                    type: CustomTextType.head,
                                    alignment: CustomTextAlignment.center,
                                  ),
                                  Gap(AppDimensionsTheme.getLarge(context)),
                                  SelectableText.rich(
                                    TextSpan(
                                      text: _buildRetryMessage(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  Gap(AppDimensionsTheme.getMedium(context)),
                                  const CircularProgressIndicator(),
                                ],
                              );
                            },
                            orElse: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                    ],
                  ),
                ),
              ),
              // Fast knap i bunden
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppDimensionsTheme.getLarge(context),
                ),
                child: CustomButton(text: I18nService().t('screen_phone_code.history_button', fallback: 'History'), onPressed: () => _navigateToHistory(context), buttonType: CustomButtonType.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:45:00
