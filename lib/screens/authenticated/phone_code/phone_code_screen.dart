import 'dart:async';

import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';

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
      return I18nService().t('screen_phone_code.retry_message_initial', fallback: 'Forsøger automatisk igen om få sekunder...');
    } else if (_retryCount <= 20) {
      return I18nService().t('screen_phone_code.retry_message_fast', fallback: 'Forsøg $_retryCount/40 - Næste forsøg om 3 sekunder...', variables: {'attempt': _retryCount.toString()});
    } else if (_retryCount <= 40) {
      return I18nService().t('screen_phone_code.retry_message_slow', fallback: 'Forsøg $_retryCount/40 - Næste forsøg om 10 sekunder...', variables: {'attempt': _retryCount.toString()});
    } else {
      return I18nService().t('screen_phone_code.retry_message_final', fallback: 'For mange forsøg - sender dig til forsiden...');
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
        title: I18nService().t('screen_phone_code.title', fallback: 'Telefonopkald'),
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
                                return Column(
                                  children: [
                                    CustomText(
                                      text: I18nService().t('screen_phone_code.no_active_calls', fallback: 'Ingen aktive opkald'),
                                      type: CustomTextType.head,
                                      alignment: CustomTextAlignment.center,
                                    ),
                                    Gap(AppDimensionsTheme.getLarge(context)),
                                    const CustomText(
                                      text: '',
                                      type: CustomTextType.info,
                                      alignment: CustomTextAlignment.center,
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  CustomText(
                                    text: I18nService().t('screen_phone_code.active_calls', fallback: 'Aktive opkald'),
                                    type: CustomTextType.head,
                                    alignment: CustomTextAlignment.center,
                                  ),
                                  PhoneCallWidget(
                                    initiatorName: 'John Doe',
                                    confirmCode: '1234',
                                    createdAt: DateTime.now(),
                                  ),
                                  Gap(AppDimensionsTheme.getLarge(context)),
                                  ...phoneCodes.map((phoneCode) {
                                    return PhoneCodeItemWidget(
                                      phoneCode: phoneCode,
                                      showAll: true,
                                      swipeAction: true,
                                    );
                                  }).toList(),
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
                                    text: I18nService().t('screen_phone_code.loading_error', fallback: 'Fejl ved indlæsning'),
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
                child: CustomButton(
                  text: I18nService().t('screen_phone_code.history_button', fallback: 'Historik'),
                  onPressed: () => _navigateToHistory(context),
                  buttonType: CustomButtonType.primary,
                  icon: Icons.history,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:45:00
