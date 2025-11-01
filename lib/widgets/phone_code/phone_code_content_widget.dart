import 'dart:async';

import '../../exports.dart';
import '../../widgets/phone_codes/phone_call_widget.dart';
import '../../widgets/phone_codes/phone_call_user_widget.dart' as UserWidget;
import '../../widgets/custom/custom_invite_trusted_companies_link.dart';
import '../../providers/contact_provider.dart';
import 'package:flutter_svg/svg.dart';

class PhoneCodeContentWidget extends ConsumerStatefulWidget {
  const PhoneCodeContentWidget({
    super.key,
  });

  @override
  ConsumerState<PhoneCodeContentWidget> createState() => _PhoneCodeContentWidgetState();
}

class _PhoneCodeContentWidgetState extends ConsumerState<PhoneCodeContentWidget> {
  static final log = scopedLogger(LogCategory.gui);
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    log('_navigateToHome: Too many retry attempts, navigating to home from lib/widgets/phone_code/phone_code_content_widget.dart');
    context.go(RoutePaths.home);
  }

  void _handleRetry(WidgetRef ref, BuildContext context) {
    _retryCount++;
    log('_handleRetry: Starting retry attempt $_retryCount/40 from lib/widgets/phone_code/phone_code_content_widget.dart');

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
    log('_resetRetryCount: Resetting retry count from lib/widgets/phone_code/phone_code_content_widget.dart');
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        // Realtime phone codes liste med dynamisk header
        Consumer(
          builder: (context, ref, child) {
            final phoneCodesAsync = ref.watch(phoneCodesRealtimeStreamProvider);
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
                        Gap(AppDimensionsTheme.getLarge(context)),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        // Link: Invite trusted companies (test key dokumenteret)
                        const CustomInviteTrustedCompaniesLink(),
                      ],
                    ),
                  );
                }

                // Telefonnumre findes - vis normal funktionalitet
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
                            Gap(AppDimensionsTheme.getLarge(context)),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            // Link: Invite trusted companies (test key dokumenteret)
                            const CustomInviteTrustedCompaniesLink(),
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

                            Widget widget;
                            // Vælg widget baseret på phone_codes_type
                            if (phoneCode.phoneCodesType == 'user') {
                              final contactId = phoneCode.initiatorInfo['contact_id'];
                              if (contactId != null) {
                                // Real data - use Consumer to load contact
                                log('Building UserWidget with contactId: $contactId');
                                log('initiatorInfo data: ${phoneCode.initiatorInfo}');

                                widget = Consumer(
                                  builder: (context, ref, child) {
                                    final contactState = ref.watch(contactNotifierProvider);

                                    // Call loadContactLight when the widget builds, but only if not already loading
                                    if (!contactState.isLoading && contactState.value == null) {
                                      Future.microtask(() {
                                        ref.read(contactNotifierProvider.notifier).loadContactLight(contactId);
                                      });
                                    }

                                    return contactState.when(
                                      data: (contact) {
                                        if (contact != null) {
                                          log('Loaded contact from loadContactLight: ${contact.toJson()}');
                                          return UserWidget.PhoneCallUserWidget(
                                            initiatorName: '${contact.firstName} ${contact.lastName}',
                                            initiatorCompany: contact.company,
                                            initiatorPhone: null,
                                            createdAt: DateTime.now(),
                                            history: false,
                                            action: phoneCode.action,
                                            phoneCodesId: phoneCode.phoneCodesId,
                                            viewType: UserWidget.ViewType.Phone,
                                            onConfirm: null,
                                            onReject: null,
                                            customerUserId: phoneCode.customerUserId,
                                            profileImage: contact.profileImage,
                                          );
                                        } else {
                                          return const CustomText(text: 'No contact found', type: CustomTextType.info);
                                        }
                                      },
                                      loading: () => const CustomText(text: 'Loading contact...', type: CustomTextType.info),
                                      error: (error, stackTrace) {
                                        log('Error loading contact: $error');
                                        return CustomText(text: 'Error: $error', type: CustomTextType.info);
                                      },
                                    );
                                  },
                                );
                              } else {
                                log('No contactId found in initiatorInfo');
                                widget = const SizedBox.shrink();
                              }
                            } else if (phoneCode.phoneCodesType == 'customer') {
                              widget = PhoneCallWidget(
                                initiatorName: phoneCode.initiatorInfo['name'],
                                confirmCode: phoneCode.confirmCode,
                                initiatorCompany: phoneCode.initiatorInfo['company'],
                                initiatorEmail: phoneCode.initiatorInfo['email'],
                                initiatorPhone: phoneCode.initiatorInfo['phone'],
                                initiatorAddress: phoneCode.initiatorInfo['address'],
                                createdAt: DateTime.now(),
                                lastControlDateAt: DateTime.tryParse(phoneCode.initiatorInfo['last_control'] ?? '') ?? DateTime.now(),
                                history: false,
                                action: phoneCode.action,
                                phoneCodesId: phoneCode.phoneCodesId,
                                logoPath: phoneCode.initiatorInfo['logo_path'],
                                websiteUrl: phoneCode.initiatorInfo['website_url'],
                                viewType: ViewType.Phone,
                                onConfirm: null,
                                onReject: null,
                              );
                            } else {
                              widget = const SizedBox.shrink();
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < phoneCodes.length - 1 ? AppDimensionsTheme.getMedium(context) : 0,
                              ),
                              child: widget,
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
    );
  }
}

// Created on 2025-01-16 at 16:50
