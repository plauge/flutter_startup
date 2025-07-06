import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _onSearchPressed(String searchValue, WidgetRef ref, BuildContext context, ValueNotifier<TextCodesReadResponse?> resultNotifier, ValueNotifier<String?> errorNotifier) {
    log('_onSearchPressed: Search pressed with value: $searchValue from lib/screens/authenticated/text_code/text_code_screen.dart');

    ref.read(readTextCodeByConfirmCodeProvider(searchValue).future).then(
      (results) {
        log('_onSearchPressed: Received results: ${results.length} items');

        if (results.isNotEmpty && results.first.statusCode == 200) {
          log('_onSearchPressed: Success - status code 200');
          resultNotifier.value = results.first;
          errorNotifier.value = null;
        } else {
          log('_onSearchPressed: Failed - status code: ${results.isNotEmpty ? results.first.statusCode : 'no results'}');
          resultNotifier.value = null;
          errorNotifier.value = 'Koden er ikke kendt';
        }
      },
      onError: (error) {
        log('_onSearchPressed: Error occurred: $error');
        resultNotifier.value = null;
        errorNotifier.value = 'Koden kan ikke bruges og kan være svindel.';
      },
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<bool> isSearchEnabled = ValueNotifier<bool>(false);
    final ValueNotifier<TextCodesReadResponse?> searchResult = ValueNotifier<TextCodesReadResponse?>(null);
    final ValueNotifier<String?> searchError = ValueNotifier<String?>(null);

    // Lyt til ændringer i input feltet
    searchController.addListener(() {
      isSearchEnabled.value = searchController.text.trim().isNotEmpty;
    });

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_text_code.title', fallback: 'SMS / Email validation'),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomText(
                        text: I18nService().t('screen_text_code.heading', fallback: 'SMS / Email validation'),
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      // Input felt med søgeknap i en row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: searchController,
                              hintText: I18nService().t('screen_text_code.search_hint', fallback: 'Enter code to validate'),
                            ),
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          ValueListenableBuilder<bool>(
                            valueListenable: isSearchEnabled,
                            builder: (context, isEnabled, child) {
                              return SizedBox(
                                width: 75,
                                child: CustomButton(
                                  onPressed: () => _onSearchPressed(searchController.text, ref, context, searchResult, searchError),
                                  buttonType: CustomButtonType.primary,
                                  icon: Icons.search,
                                  enabled: isEnabled,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      // Resultat visning
                      ValueListenableBuilder<TextCodesReadResponse?>(
                        valueListenable: searchResult,
                        builder: (context, result, child) {
                          if (result != null) {
                            // Vis PhoneCallWidget når vi har et result
                            return PhoneCallWidget(
                              initiatorName: result.data.payload.initiatorInfo.name,
                              confirmCode: result.data.payload.confirmCode,
                              initiatorCompany: result.data.payload.initiatorInfo.company,
                              initiatorEmail: result.data.payload.initiatorInfo.email,
                              initiatorPhone: result.data.payload.initiatorInfo.phone,
                              initiatorAddress: {
                                'street': result.data.payload.initiatorInfo.address.street,
                                'postal_code': result.data.payload.initiatorInfo.address.postalCode,
                                'city': result.data.payload.initiatorInfo.address.city,
                                'region': result.data.payload.initiatorInfo.address.region,
                                'country': result.data.payload.initiatorInfo.address.country,
                              },
                              createdAt: result.data.payload.createdAt,
                              lastControlDateAt: result.data.payload.initiatorInfo.lastControl,
                              history: true,
                              isConfirmed: result.data.payload.receiverRead,
                              phoneCodesId: result.data.payload.textCodesId,
                              logoPath: result.data.payload.initiatorInfo.logoPath,
                              websiteUrl: null,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Fejl visning
                      ValueListenableBuilder<String?>(
                        valueListenable: searchError,
                        builder: (context, error, child) {
                          if (error != null && error.isNotEmpty) {
                            return CustomText(
                              text: error,
                              type: CustomTextType.info,
                              alignment: CustomTextAlignment.center,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created on 2024-12-19 at 14:00
