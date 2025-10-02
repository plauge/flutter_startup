import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';
import '../../../widgets/phone_codes/phone_call_user_widget.dart' as UserWidget;
import '../../../providers/contact_provider.dart';

class PhoneCodeHistoryScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  PhoneCodeHistoryScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneCodeHistoryScreen> create() async {
    final screen = PhoneCodeHistoryScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final phoneCodesLogAsync = ref.watch(getPhoneCodesLogProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_code_history.title', fallback: 'History'),
        backRoutePath: RoutePaths.phoneCode,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: phoneCodesLogAsync.when(
            data: (phoneCodesResponses) {
              log('PhoneCodeHistoryScreen: Received ${phoneCodesResponses.length} responses');

              if (phoneCodesResponses.isEmpty) {
                return Center(
                  child: CustomText(
                    text: I18nService().t('screen_phone_code_history.no_history_found', fallback: 'No history found'),
                    type: CustomTextType.head,
                    alignment: CustomTextAlignment.center,
                  ),
                );
              }

              // Tag det første response (der skulle kun være ét)
              final response = phoneCodesResponses.first;
              final phoneCodes = response.data.payload.phoneCodes;

              if (phoneCodes.isEmpty) {
                return Center(
                  child: CustomText(
                    text: I18nService().t('screen_phone_code_history.no_phone_codes_found', fallback: 'No phone codes found'),
                    type: CustomTextType.head,
                    alignment: CustomTextAlignment.center,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Gap(AppDimensionsTheme.getMedium(context)),
                    // CustomText(
                    //   text: 'Antal codes: ${response.data.payload.count}',
                    //   type: CustomTextType.bread,
                    //   alignment: CustomTextAlignment.center,
                    // ),

                    Gap(AppDimensionsTheme.getMedium(context)),
                    ...phoneCodes.map((phoneCode) {
                      // Vælg widget baseret på phone_codes_type
                      if (phoneCode.phoneCodesType == 'user') {
                        final contactId = phoneCode.initiatorInfo['contact_id'];
                        if (contactId != null) {
                          PhoneCodeHistoryScreen.log('Building UserWidget with contactId: $contactId');
                          PhoneCodeHistoryScreen.log('initiatorInfo data: ${phoneCode.initiatorInfo}');

                          // Use Consumer to listen for the contact data from loadContactLight
                          return Consumer(
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
                                    PhoneCodeHistoryScreen.log('Loaded contact from loadContactLight: ${contact.toJson()}');
                                    return UserWidget.PhoneCallUserWidget(
                                      initiatorName: '${contact.firstName} ${contact.lastName}',
                                      initiatorCompany: contact.company,
                                      initiatorPhone: null,
                                      createdAt: phoneCode.createdAt,
                                      history: true,
                                      action: phoneCode.action,
                                      phoneCodesId: phoneCode.phoneCodesId,
                                      viewType: UserWidget.ViewType.Phone,
                                    );
                                  } else {
                                    return const CustomText(text: 'No contact found', type: CustomTextType.info);
                                  }
                                },
                                loading: () => const CustomText(text: 'Loading contact...', type: CustomTextType.info),
                                error: (error, stackTrace) {
                                  PhoneCodeHistoryScreen.log('Error loading contact: $error');
                                  return CustomText(text: 'Error: $error', type: CustomTextType.info);
                                },
                              );
                            },
                          );
                        } else {
                          PhoneCodeHistoryScreen.log('No contactId found in initiatorInfo');
                          return const SizedBox.shrink();
                        }
                      }
                      if (phoneCode.phoneCodesType == 'customer') {
                        return PhoneCallWidget(
                          initiatorName: phoneCode.initiatorInfo['name'],
                          confirmCode: phoneCode.confirmCode,
                          initiatorCompany: phoneCode.initiatorInfo['company'],
                          initiatorEmail: phoneCode.initiatorInfo['email'],
                          initiatorPhone: phoneCode.initiatorInfo['phone'],
                          initiatorAddress: phoneCode.initiatorInfo['address'],
                          createdAt: phoneCode.createdAt,
                          lastControlDateAt: DateTime.tryParse(phoneCode.initiatorInfo['last_control'] ?? '') ?? DateTime.now(),
                          history: true,
                          action: phoneCode.action,
                          phoneCodesId: phoneCode.phoneCodesId,
                          logoPath: phoneCode.initiatorInfo['logo_path'],
                          websiteUrl: phoneCode.initiatorInfo['website_url'],
                          viewType: ViewType.Phone,
                        );
                      }
                      // Fallback hvis phone_codes_type ikke matcher
                      return const SizedBox.shrink();
                    }),
                    Gap(AppDimensionsTheme.getLarge(context)),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) {
              log('PhoneCodeHistoryScreen: Error loading data: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      I18nService().t('screen_phone_code_history.error_loading_history', fallback: 'Error loading history'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    SelectableText.rich(
                      TextSpan(
                        text: error.toString(),
                        style: AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:46:00
