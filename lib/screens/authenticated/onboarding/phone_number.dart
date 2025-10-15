import '../../../exports.dart';
import 'dart:io';

class OnboardingPhoneNumberScreen extends AuthenticatedScreen {
  OnboardingPhoneNumberScreen({super.key}) : super(pin_code_protected: false);
  static final log = scopedLogger(LogCategory.gui);

  static Future<OnboardingPhoneNumberScreen> create() async {
    final screen = OnboardingPhoneNumberScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackAction(WidgetRef ref, String action, {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = <String, dynamic>{
      'action': action,
      'screen': 'onboarding_phone_number',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (properties != null) {
      eventData.addAll(properties);
    }
    analytics.track('onboarding_phone_number_$action', eventData);
  }

  void _showAddPhoneNumberModal(BuildContext context, WidgetRef ref) {
    _trackAction(ref, 'add_phone_modal_opened');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPhoneNumberModal(
        trackAction: (action, {properties}) => _trackAction(ref, action, properties: properties),
      ),
    );
  }

  Future<String> _decryptAndFormatPhoneNumber(String encryptedPhoneNumber, WidgetRef ref) async {
    try {
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        return 'Error: No token available';
      }

      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, token);
      return _formatPhoneNumber(decryptedPhoneNumber);
    } catch (e) {
      log('[onboarding_phone_number.dart][_decryptAndFormatPhoneNumber] Error decrypting phone number: $e');
      return 'Error decrypting phone number';
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    String digits = phoneNumber.substring(1);
    if (digits.isEmpty) return phoneNumber;

    String? countryCode = _findCountryCode(digits);

    if (countryCode != null) {
      String restOfNumber = digits.substring(countryCode.length);
      return '(+$countryCode) $restOfNumber';
    }

    if (digits.length > 1 && _isValidSingleDigitCode(digits[0])) {
      return '(+${digits[0]}) ${digits.substring(1)}';
    }

    if (digits.length > 2) {
      return '(+${digits.substring(0, 2)}) ${digits.substring(2)}';
    }

    return phoneNumber;
  }

  String? _findCountryCode(String digits) {
    Map<String, int> knownCodes = {
      '1473': 4,
      '1767': 4,
      '1809': 4,
      '1829': 4,
      '1849': 4,
      '1868': 4,
      '1869': 4,
      '1876': 4,
      '1939': 4,
      '1345': 4,
      '1441': 4,
      '1664': 4,
      '1721': 4,
      '1758': 4,
      '1784': 4,
      '1787': 4,
      '1671': 4,
      '358': 3,
      '372': 3,
      '370': 3,
      '371': 3,
      '374': 3,
      '375': 3,
      '376': 3,
      '377': 3,
      '378': 3,
      '380': 3,
      '381': 3,
      '382': 3,
      '383': 3,
      '385': 3,
      '386': 3,
      '387': 3,
      '389': 3,
      '420': 3,
      '421': 3,
      '423': 3,
      '590': 3,
      '591': 3,
      '592': 3,
      '593': 3,
      '594': 3,
      '595': 3,
      '596': 3,
      '597': 3,
      '598': 3,
      '599': 3,
      '500': 3,
      '501': 3,
      '502': 3,
      '503': 3,
      '504': 3,
      '505': 3,
      '506': 3,
      '507': 3,
      '508': 3,
      '509': 3,
      '240': 3,
      '241': 3,
      '242': 3,
      '243': 3,
      '244': 3,
      '245': 3,
      '246': 3,
      '248': 3,
      '249': 3,
      '250': 3,
      '251': 3,
      '252': 3,
      '253': 3,
      '254': 3,
      '255': 3,
      '256': 3,
      '257': 3,
      '258': 3,
      '260': 3,
      '261': 3,
      '262': 3,
      '263': 3,
      '264': 3,
      '265': 3,
      '266': 3,
      '267': 3,
      '268': 3,
      '269': 3,
      '290': 3,
      '291': 3,
      '297': 3,
      '298': 3,
      '299': 3,
      '350': 3,
      '351': 3,
      '352': 3,
      '353': 3,
      '354': 3,
      '355': 3,
      '356': 3,
      '357': 3,
      '45': 2,
      '46': 2,
      '47': 2,
      '48': 2,
      '49': 2,
      '30': 2,
      '31': 2,
      '32': 2,
      '33': 2,
      '34': 2,
      '35': 2,
      '36': 2,
      '37': 2,
      '38': 2,
      '39': 2,
      '40': 2,
      '41': 2,
      '42': 2,
      '43': 2,
      '44': 2,
      '51': 2,
      '52': 2,
      '53': 2,
      '54': 2,
      '55': 2,
      '56': 2,
      '57': 2,
      '58': 2,
      '60': 2,
      '61': 2,
      '62': 2,
      '63': 2,
      '64': 2,
      '65': 2,
      '66': 2,
      '81': 2,
      '82': 2,
      '84': 2,
      '86': 2,
      '90': 2,
      '91': 2,
      '92': 2,
      '93': 2,
      '94': 2,
      '95': 2,
      '98': 2,
      '20': 2,
      '27': 2,
      '1': 1,
      '7': 1,
    };

    for (int length = 4; length >= 1; length--) {
      if (digits.length >= length) {
        String candidate = digits.substring(0, length);
        if (knownCodes[candidate] == length) {
          return candidate;
        }
      }
    }

    return null;
  }

  bool _isValidSingleDigitCode(String digit) {
    return ['1', '7'].contains(digit);
  }

  void handleSkip(BuildContext context, WidgetRef ref) {
    _trackAction(ref, 'skip_pressed');
    context.go(RoutePaths.profileImage);
  }

  void handleNext(BuildContext context, WidgetRef ref) {
    _trackAction(ref, 'next_pressed');
    context.go(RoutePaths.profileImage);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_onboarding_phone_number.header', fallback: 'Phone Number'),
        backRoutePath: RoutePaths.personalInfo,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_onboarding_phone_number.step', fallback: 'Step 4 of 5'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_onboarding_phone_number.title', fallback: 'Add Phone Number'),
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_onboarding_phone_number.description', fallback: 'If you want to receive pre-calls, we need your phone number.'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),

            // Phone number display or add button
            phoneNumbersAsync.when(
              data: (responses) {
                final hasPhoneNumber = responses.isNotEmpty && responses.first.data.payload.isNotEmpty;

                if (hasPhoneNumber) {
                  final phoneNumber = responses.first.data.payload.first;
                  return FutureBuilder<String>(
                    future: _decryptAndFormatPhoneNumber(phoneNumber.encryptedPhoneNumber, ref),
                    builder: (context, snapshot) {
                      String displayText = 'Loading...';
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          displayText = 'Error loading phone number';
                        } else {
                          displayText = snapshot.data ?? 'Unknown number';
                        }
                      }

                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 48,
                                  color: AppColors.primaryColor(context),
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomText(
                                  text: displayText,
                                  type: CustomTextType.cardHead,
                                  alignment: CustomTextAlignment.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // No phone number - show add button
                  return GestureDetector(
                    key: const Key('add_phone_number_card'),
                    onTap: () => _showAddPhoneNumberModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor(context).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 64,
                            color: AppColors.primaryColor(context),
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          CustomText(
                            text: I18nService().t('screen_onboarding_phone_number.add_phone_number', fallback: 'Tap to add phone number'),
                            type: CustomTextType.cardHead,
                            alignment: CustomTextAlignment.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => CustomText(
                text: I18nService().t('screen_onboarding_phone_number.error_loading', fallback: 'Error loading phone numbers'),
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
            ),

            const Spacer(),
            Builder(
              builder: (context) {
                final phoneNumberButtons = Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensionsTheme.getMedium(context),
                    vertical: AppDimensionsTheme.getLarge(context),
                  ),
                  child: Column(
                    children: [
                      CustomButton(
                        key: const Key('onboarding_phone_number_next_button'),
                        onPressed: () => handleNext(context, ref),
                        text: I18nService().t('screen_onboarding_phone_number.next_button', fallback: 'Next'),
                        buttonType: CustomButtonType.primary,
                      ),
                      // Gap(AppDimensionsTheme.getMedium(context)),
                      // CustomButton(
                      //   key: const Key('onboarding_phone_number_skip_button'),
                      //   onPressed: () => handleSkip(context, ref),
                      //   text: I18nService().t('screen_onboarding_phone_number.skip_button', fallback: 'Skip'),
                      //   buttonType: CustomButtonType.secondary,
                      // ),
                    ],
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: phoneNumberButtons) : phoneNumberButtons;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Created: 2024-10-15 (Onboarding step 5 - Add phone number)
