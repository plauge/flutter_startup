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

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: AppDimensionsTheme.getMedium(context)),
                itemCount: phoneCodes.length,
                itemBuilder: (context, index) {
                  final phoneCode = phoneCodes[index];

                  // Vælg widget baseret på phone_codes_type
                  if (phoneCode.phoneCodesType == 'user') {
                    final contactId = phoneCode.initiatorInfo['contact_id'];
                    if (contactId != null) {
                      // Use cached provider with 5 minute cache
                      return Consumer(
                        builder: (context, ref, child) {
                          final contactState = ref.watch(contactLightCachedProvider(contactId));

                          return contactState.when(
                            data: (contact) {
                              if (contact != null) {
                                return UserWidget.PhoneCallUserWidget(
                                  initiatorName: '${contact.firstName} ${contact.lastName}',
                                  initiatorCompany: contact.company,
                                  initiatorPhone: null,
                                  createdAt: phoneCode.createdAt,
                                  history: true,
                                  action: phoneCode.action,
                                  phoneCodesId: phoneCode.phoneCodesId,
                                  viewType: UserWidget.ViewType.Phone,
                                  customerUserId: phoneCode.customerUserId,
                                  profileImage: contact.profileImage,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                            loading: () => const SizedBox(
                              height: 50,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            error: (error, stackTrace) => const SizedBox.shrink(),
                            skipLoadingOnReload: true,
                          );
                        },
                      );
                    } else {
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
                },
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
