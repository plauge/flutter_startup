import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';
import '../../../widgets/custom/custom_invite_trusted_companies_link.dart';

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return _TextCodeScreenContent();
  }
}

class _TextCodeScreenContent extends StatefulWidget {
  @override
  _TextCodeScreenContentState createState() => _TextCodeScreenContentState();
}

class _TextCodeScreenContentState extends State<_TextCodeScreenContent> {
  late final TextEditingController searchController;
  late final ValueNotifier<bool> isSearchEnabled;
  late final ValueNotifier<TextCodesReadResponse?> searchResult;
  late final ValueNotifier<String?> searchError;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    isSearchEnabled = ValueNotifier<bool>(false);
    searchResult = ValueNotifier<TextCodesReadResponse?>(null);
    searchError = ValueNotifier<String?>(null);

    // Lyt til ændringer i input feltet
    searchController.addListener(() {
      final text = searchController.text.trim();
      isSearchEnabled.value = text.isNotEmpty;

      // Nulstil søgeresultat og fejl når inputfeltet bliver tomt
      if (text.isEmpty) {
        searchResult.value = null;
        searchError.value = null;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    isSearchEnabled.dispose();
    searchResult.dispose();
    searchError.dispose();
    super.dispose();
  }

  void _onSearchPressed(String searchValue, WidgetRef ref, BuildContext context, ValueNotifier<TextCodesReadResponse?> resultNotifier, ValueNotifier<String?> errorNotifier) {
    TextCodeScreen.log('_onSearchPressed: Search pressed with value: $searchValue from lib/screens/authenticated/text_code/text_code_screen.dart');

    // Luk keyboardet når søgningen starter
    FocusScope.of(context).unfocus();

    // Valider at koden starter med "idt"
    if (!searchValue.toLowerCase().startsWith('idt')) {
      TextCodeScreen.log('_onSearchPressed: Code does not start with "idt"');
      resultNotifier.value = null;
      errorNotifier.value = I18nService().t('screen_text_code.error_code_invalid_format', fallback: 'The code is not valid');
      return;
    }

    ref.read(readTextCodeByConfirmCodeProvider(searchValue).future).then(
      (results) {
        TextCodeScreen.log('_onSearchPressed: Received results: ${results.length} items');

        if (results.isNotEmpty && results.first.statusCode == 200) {
          TextCodeScreen.log('_onSearchPressed: Success - status code 200');
          resultNotifier.value = results.first;
          errorNotifier.value = null;
        } else {
          TextCodeScreen.log('_onSearchPressed: Failed - status code: ${results.isNotEmpty ? results.first.statusCode : 'no results'}');
          resultNotifier.value = null;
          errorNotifier.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
        }
      },
      onError: (error) {
        TextCodeScreen.log('_onSearchPressed: Error occurred: $error');
        resultNotifier.value = null;
        errorNotifier.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AuthenticatedAppBar(
            title: I18nService().t('screen_text_code.title', fallback: 'Email & Text Messages'),
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
                          // Gap(AppDimensionsTheme.getLarge(context)),
                          // CustomText(
                          //   text: I18nService().t('screen_text_code.heading', fallback: 'SMS / Email validation'),
                          //   type: CustomTextType.head,
                          //   alignment: CustomTextAlignment.center,
                          // ),
                          // Gap(AppDimensionsTheme.getLarge(context)),
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
                                    width: 100,
                                    child: CustomButton(
                                      onPressed: () => _onSearchPressed(searchController.text, ref, context, searchResult, searchError),
                                      buttonType: CustomButtonType.primary,
                                      //icon: Icons.search,
                                      text: I18nService().t('screen_text_code.search_button', fallback: 'Verify'),
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
                              return ValueListenableBuilder<String?>(
                                valueListenable: searchError,
                                builder: (context, error, child) {
                                  if (result != null) {
                                    // Vis CustomText og PhoneCallWidget når vi har et result
                                    return Column(
                                      children: [
                                        CustomCodeValidation(
                                          content: I18nService().t('screen_text_code.error_code_box_valid', fallback: 'The code is valid'),
                                          state: ValidationState.valid,
                                        ),
                                        Gap(AppDimensionsTheme.getLarge(context)),
                                        Text(
                                          I18nService().t('screen_text_code.result_found', fallback: 'This code is send to you personaly from:'),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF014459),
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Gap(AppDimensionsTheme.getLarge(context)),
                                        PhoneCallWidget(
                                          initiatorName: result.data.payload.initiatorInfo.name,
                                          confirmCode: result.data.payload.confirmCode,
                                          initiatorCompany: result.data.payload.initiatorInfo.company,
                                          initiatorEmail: result.data.payload.initiatorInfo.email,
                                          initiatorPhone: result.data.payload.initiatorInfo.phone,
                                          viewType: ViewType.Text,
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
                                          websiteUrl: result.data.payload.initiatorInfo.websiteUrl,
                                        ),
                                      ],
                                    );
                                  } else if (searchController.text.isEmpty && (error == null || error.isEmpty)) {
                                    // Vis CustomHelpText når inputfeltet er tomt som hjælpetekst (og ingen fejl)
                                    return Column(
                                      children: [
                                        CustomHelpText(text: I18nService().t('screen_text_code.help_text', fallback: 'Enter the code you received via SMS or email to validate it.')),
                                        Gap(AppDimensionsTheme.getLarge(context)),
                                        // Link: Invite trusted companies (test key dokumenteret)
                                        const CustomInviteTrustedCompaniesLink(),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),
                          // Fejl visning
                          ValueListenableBuilder<String?>(
                            valueListenable: searchError,
                            builder: (context, error, child) {
                              if (error != null && error.isNotEmpty) {
                                return Column(
                                  children: [
                                    CustomCodeValidation(
                                      content: I18nService().t('screen_text_code.error_code_box_not_valid', fallback: 'The code is invalid'),
                                      state: ValidationState.invalid,
                                    ),
                                    Gap(AppDimensionsTheme.getLarge(context)),
                                    Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF014459),
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
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
      },
    );
  }
}

// Created on 2024-12-19 at 14:00
