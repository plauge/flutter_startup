import 'dart:async';
import 'dart:math';
import 'dart:io'; // Added for Platform detection

import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';
import '../../../widgets/phone_codes/phone_code_item_widget.dart';
import '../../../widgets/custom/custom_invite_trusted_companies_link.dart';

import 'package:flutter/services.dart'; // Clipboard import
import 'package:flutter_svg/svg.dart';

// Demo state notifier for managing demo phone codes
class DemoPhoneCodeNotifier extends StateNotifier<List<PhoneCode>> {
  static final log = scopedLogger(LogCategory.provider);

  DemoPhoneCodeNotifier() : super([]);

  void createDemo() {
    log('createDemo: Creating demo phone code data');

    // Generer 4 tilfældige cifre (0-9)
    final random = Random();
    final confirmCode = List.generate(4, (index) => random.nextInt(10)).join();

    final demoPhoneCode = PhoneCode(
      phoneCodesId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      customerUserId: 'demo-customer-user-id',
      receiverUserId: 'demo-receiver-user-id',
      customerEmployeeId: 'demo-employee-id',
      confirmCode: confirmCode,
      initiatorInfo: {
        'name': 'Demo Company A/S',
        'company': 'Demo Company A/S',
        'email': 'support@idtruster.com',
        'phone': '+45 12 34 56 78',
        'address': {
          'street': 'Demo Vej 123',
          'postal_code': '1234',
          'city': 'Demo By',
          'region': 'Hovedstaden',
          'country': 'Danmark',
        },
        'last_control': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'logo_path': null,
        'website_url': 'https://idtruster.com/',
      },
    );

    state = [demoPhoneCode];
  }

  void clearDemo() {
    log('clearDemo: Clearing demo phone code data');
    state = [];
  }
}

final demoPhoneCodeProvider = StateNotifierProvider<DemoPhoneCodeNotifier, List<PhoneCode>>((ref) {
  return DemoPhoneCodeNotifier();
});

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

  void _createDemoPhoneCode(WidgetRef ref) {
    log('_createDemoPhoneCode: Creating demo phone code from lib/screens/authenticated/phone_code/phone_code_screen.dart');
    ref.read(demoPhoneCodeProvider.notifier).createDemo();
  }

  void _handleDemoConfirm(WidgetRef ref) {
    log('_handleDemoConfirm: Demo phone code confirmed, clearing demo data');
    ref.read(demoPhoneCodeProvider.notifier).clearDemo();
  }

  void _handleDemoReject(WidgetRef ref) {
    log('_handleDemoReject: Demo phone code rejected, clearing demo data');
    ref.read(demoPhoneCodeProvider.notifier).clearDemo();
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
    // Clear demo når screen loader
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(demoPhoneCodeProvider.notifier).clearDemo();
    });
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
                          final demoPhoneCodes = ref.watch(demoPhoneCodeProvider);
                          final phoneNumbersAsync = ref.watch(phoneNumbersProvider);

                          return phoneNumbersAsync.when(
                            data: (phoneNumbersResponses) {
                              // Tjek antallet af telefonnumre
                              final phoneNumbersCount = phoneNumbersResponses.isNotEmpty ? phoneNumbersResponses.first.data.payload.length : 0;

                              // Hvis ingen telefonnumre er oprettet
                              if (phoneNumbersCount == 0) {
                                return Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.6,
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
                                        text: I18nService().t('screen_phone_code.no_active_phone_number', fallback: 'No active phone number'),
                                        type: CustomTextType.head,
                                        alignment: CustomTextAlignment.center,
                                      ),
                                      Gap(AppDimensionsTheme.getLarge(context)),
                                      CustomText(
                                        text: I18nService().t('screen_phone_code.no_phone_number_description', fallback: 'You need to add a phone number to receive verification calls.'),
                                        type: CustomTextType.bread,
                                        alignment: CustomTextAlignment.center,
                                      ),
                                      Gap(AppDimensionsTheme.getLarge(context)),
                                      CustomButton(
                                        key: const Key('add_phone_number_button'),
                                        text: I18nService().t('screen_phone_code.add_phone_number', fallback: 'Add Phone number'),
                                        onPressed: () => context.go('/phone-numbers'),
                                        buttonType: CustomButtonType.primary,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Telefonnumre findes - vis normal funktionalitet
                              return phoneCodesAsync.maybeWhen(
                                data: (phoneCodes) {
                                  // Data loadet succesfuldt - nulstil retry count
                                  _resetRetryCount();

                                  // Kombiner rigtige data med demo data
                                  final combinedPhoneCodes = [...phoneCodes, ...demoPhoneCodes];

                                  if (combinedPhoneCodes.isEmpty) {
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
                                          CustomButton(
                                            key: const Key('demo_phone_code_button'),
                                            text: I18nService().t('screen_phone_code.demo_button', fallback: 'Try the demo'),
                                            onPressed: () => _createDemoPhoneCode(ref),
                                            buttonType: CustomButtonType.secondary,
                                          ),
                                          Gap(AppDimensionsTheme.getLarge(context)),
                                          // Link: Invite trusted companies (test key dokumenteret)
                                          const CustomInviteTrustedCompaniesLink(),
                                        ],
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      // CustomText(
                                      //   text: I18nService().t('screen_phone_code.active_calls', fallback: 'Active calls'),
                                      //   type: CustomTextType.head,
                                      //   alignment: CustomTextAlignment.center,
                                      // ),
                                      // Gap(AppDimensionsTheme.getLarge(context)),
                                      // Vis alle phone codes i stedet for kun den første
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: combinedPhoneCodes.length,
                                        itemBuilder: (context, index) {
                                          final phoneCode = combinedPhoneCodes[index];
                                          final isDemo = phoneCode.phoneCodesId.startsWith('demo-');

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: index < combinedPhoneCodes.length - 1 ? AppDimensionsTheme.getMedium(context) : 0,
                                            ),
                                            child: PhoneCallWidget(
                                              initiatorName: phoneCode.initiatorInfo['name'],
                                              confirmCode: phoneCode.confirmCode,
                                              initiatorCompany: phoneCode.initiatorInfo['company'],
                                              initiatorEmail: phoneCode.initiatorInfo['email'],
                                              initiatorPhone: phoneCode.initiatorInfo['phone'],
                                              initiatorAddress: phoneCode.initiatorInfo['address'],
                                              createdAt: DateTime.now(),
                                              lastControlDateAt: DateTime.tryParse(phoneCode.initiatorInfo['last_control'] ?? '') ?? DateTime.now(),
                                              history: false,
                                              isConfirmed: true,
                                              phoneCodesId: phoneCode.phoneCodesId,
                                              logoPath: phoneCode.initiatorInfo['logo_path'],
                                              websiteUrl: phoneCode.initiatorInfo['website_url'],
                                              viewType: ViewType.Phone,
                                              demo: isDemo,
                                              onConfirm: isDemo ? () => _handleDemoConfirm(ref) : null,
                                              onReject: isDemo ? () => _handleDemoReject(ref) : null,
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
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Column(
                              children: [
                                CustomText(
                                  text: I18nService().t('screen_phone_code.phone_numbers_error', fallback: 'Error loading phone numbers'),
                                  type: CustomTextType.head,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          );
                        },
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                    ],
                  ),
                ),
              ),
              // History knap - kun vis når der ikke er aktive opkald og telefonnumre findes
              Consumer(
                builder: (context, ref, child) {
                  final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);
                  final demoPhoneCodes = ref.watch(demoPhoneCodeProvider);
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
                          final combinedPhoneCodes = [...phoneCodes, ...demoPhoneCodes];
                          // Vis kun History knap hvis der ikke er aktive opkald
                          if (combinedPhoneCodes.isEmpty) {
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:45:00
