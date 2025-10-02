import '../../../exports.dart';
import '../../../widgets/phone_codes/phone_call_widget.dart';
import '../../../widgets/phone_codes/phone_call_user_widget.dart' as UserWidget;
import '../../../widgets/custom/custom_invite_trusted_companies_link.dart';
import '../../../providers/contact_provider.dart';
import 'dart:io'; // Added for Platform detection

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackScreenView(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('text_code_screen_viewed', {
      'screen': 'text_code',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackAction(WidgetRef ref, String action, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('text_code_action', {
      ...properties,
      'action': action,
      'screen': 'text_code',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Track screen view
    _trackScreenView(ref);
    return _TextCodeScreenContent(trackAction: (action, properties) => _trackAction(ref, action, properties));
  }
}

class _TextCodeScreenContent extends StatefulWidget {
  final Function(String action, Map<String, dynamic> properties) trackAction;

  const _TextCodeScreenContent({required this.trackAction});

  @override
  _TextCodeScreenContentState createState() => _TextCodeScreenContentState();
}

class _TextCodeScreenContentState extends State<_TextCodeScreenContent> {
  late final TextEditingController searchController;
  late final FocusNode searchFocusNode;
  late final ValueNotifier<bool> isSearchEnabled;
  late final ValueNotifier<TextCodesReadResponse?> searchResult;
  late final ValueNotifier<String?> searchError;
  late final ValueNotifier<bool> isInputFocused;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    isSearchEnabled = ValueNotifier<bool>(false);
    searchResult = ValueNotifier<TextCodesReadResponse?>(null);
    searchError = ValueNotifier<String?>(null);
    isInputFocused = ValueNotifier<bool>(false);

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

    // Lyt til focus ændringer for at detektere keyboard
    searchFocusNode.addListener(() {
      isInputFocused.value = searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    isSearchEnabled.dispose();
    searchResult.dispose();
    searchError.dispose();
    isInputFocused.dispose();
    super.dispose();
  }

  void _onSearchPressed(String searchValue, WidgetRef ref, BuildContext context, ValueNotifier<TextCodesReadResponse?> resultNotifier, ValueNotifier<String?> errorNotifier) {
    TextCodeScreen.log('_onSearchPressed: Search pressed with value: $searchValue from lib/screens/authenticated/text_code/text_code_screen.dart');

    widget.trackAction('search_pressed', {
      'search_value': searchValue,
      'search_length': searchValue.length,
    });

    // Luk keyboardet når søgningen starter
    FocusScope.of(context).unfocus();

    // Valider at koden starter med "idt"
    if (!searchValue.toLowerCase().startsWith('idt')) {
      TextCodeScreen.log('_onSearchPressed: Code does not start with "idt"');
      widget.trackAction('search_failed', {
        'reason': 'invalid_format',
        'search_value': searchValue,
      });
      resultNotifier.value = null;
      errorNotifier.value = I18nService().t('screen_text_code.error_code_invalid_format', fallback: 'The code is not valid');
      return;
    }

    ref.read(readTextCodeByConfirmCodeProvider(searchValue).future).then(
      (results) {
        TextCodeScreen.log('_onSearchPressed: Received results: ${results.length} items');

        if (results.isNotEmpty && results.first.statusCode == 200) {
          TextCodeScreen.log('_onSearchPressed: Success - status code 200');
          widget.trackAction('search_success', {
            'search_value': searchValue,
            'status_code': results.first.statusCode,
          });
          resultNotifier.value = results.first;
          errorNotifier.value = null;
        } else {
          TextCodeScreen.log('_onSearchPressed: Failed - status code: ${results.isNotEmpty ? results.first.statusCode : 'no results'}');
          widget.trackAction('search_failed', {
            'reason': 'invalid_code',
            'search_value': searchValue,
            'status_code': results.isNotEmpty ? results.first.statusCode : 'no_results',
          });
          resultNotifier.value = null;
          errorNotifier.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
        }
      },
      onError: (error) {
        TextCodeScreen.log('_onSearchPressed: Error occurred: $error');
        widget.trackAction('search_error', {
          'error': error.toString(),
          'search_value': searchValue,
        });
        resultNotifier.value = null;
        errorNotifier.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
      },
    );
  }

  void _onGetDemoEmailPressed(WidgetRef ref, BuildContext context) async {
    TextCodeScreen.log('_onGetDemoEmailPressed: Get demo email button pressed from lib/screens/authenticated/text_code/text_code_screen.dart');

    widget.trackAction('get_demo_email_pressed', {});

    try {
      TextCodeScreen.log('_onGetDemoEmailPressed: Getting notifier instance');
      final notifier = ref.read(securityDemoTextCodeNotifierProvider.notifier);

      TextCodeScreen.log('_onGetDemoEmailPressed: Calling sendDemoTextCode()');
      final success = await notifier.sendDemoTextCode();

      TextCodeScreen.log('_onGetDemoEmailPressed: sendDemoTextCode() returned: $success');

      if (!mounted) {
        TextCodeScreen.log('_onGetDemoEmailPressed: Widget not mounted, skipping UI updates');
        return;
      }

      if (success) {
        TextCodeScreen.log('_onGetDemoEmailPressed: Success - showing green snackbar');
        widget.trackAction('get_demo_email_success', {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18nService().t('screen_text_code.demo_email_success', fallback: 'Check your email')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        TextCodeScreen.log('_onGetDemoEmailPressed: Failed - success was false, showing red snackbar');
        widget.trackAction('get_demo_email_failed', {'reason': 'api_returned_false'});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18nService().t('screen_text_code.demo_email_error', fallback: 'An error occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      TextCodeScreen.log('_onGetDemoEmailPressed: Exception caught - $e');
      TextCodeScreen.log('_onGetDemoEmailPressed: Stack trace - $stackTrace');

      widget.trackAction('get_demo_email_failed', {
        'reason': 'exception',
        'error': e.toString(),
      });

      if (!mounted) {
        TextCodeScreen.log('_onGetDemoEmailPressed: Widget not mounted after exception, skipping UI updates');
        return;
      }

      TextCodeScreen.log('_onGetDemoEmailPressed: Showing error snackbar due to exception');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nService().t('screen_text_code.demo_email_error', fallback: 'An error occurred')),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  focusNode: searchFocusNode,
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
                                        // CustomCodeValidation(
                                        //   content: I18nService().t('screen_text_code.error_code_box_valid', fallback: 'The code is valid'),
                                        //   state: ValidationState.valid,
                                        // ),
                                        // Gap(AppDimensionsTheme.getLarge(context)),
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
                                        // Conditional widget based on textCodesType using if statements
                                        Builder(
                                          builder: (context) {
                                            Widget widget;
                                            // Vælg widget baseret på text_code_type
                                            // Note: contactId is now available as result.data.payload.initiatorInfo?.contactId
                                            if (result.data.payload.textCodesType == 'user') {
                                              final contactId = result.data.payload.initiatorInfo?.contactId;
                                              if (contactId != null) {
                                                TextCodeScreen.log('Building UserWidget with contactId: $contactId');
                                                TextCodeScreen.log('initiatorInfo data: ${result.data.payload.initiatorInfo?.toJson()}');

                                                // Use Consumer to listen for the contact data from loadContactLight
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
                                                          TextCodeScreen.log('Loaded contact from loadContactLight: ${contact.toJson()}');
                                                          return UserWidget.PhoneCallUserWidget(
                                                            initiatorName: '${contact.firstName} ${contact.lastName}',
                                                            initiatorCompany: contact.company,
                                                            initiatorPhone: null,
                                                            createdAt: result.data.payload.createdAt,
                                                            history: true,
                                                            action: result.data.payload.action,
                                                            phoneCodesId: result.data.payload.textCodesId,
                                                            viewType: UserWidget.ViewType.Text,
                                                          );
                                                        } else {
                                                          return const CustomText(text: 'No contact found', type: CustomTextType.info);
                                                        }
                                                      },
                                                      loading: () => const CustomText(text: 'Loading contact...', type: CustomTextType.info),
                                                      error: (error, stackTrace) {
                                                        TextCodeScreen.log('Error loading contact: $error');
                                                        return CustomText(text: 'Error: $error', type: CustomTextType.info);
                                                      },
                                                    );
                                                  },
                                                );
                                              } else {
                                                TextCodeScreen.log('No contactId found in initiatorInfo');
                                                widget = const SizedBox.shrink();
                                              }
                                            } else if (result.data.payload.textCodesType == 'customer') {
                                              widget = PhoneCallWidget(
                                                initiatorName: result.data.payload.initiatorInfo?.name ?? 'Unknown',
                                                confirmCode: result.data.payload.confirmCode,
                                                initiatorCompany: result.data.payload.initiatorInfo?.company ?? 'Unknown Company',
                                                initiatorEmail: result.data.payload.initiatorInfo?.email ?? 'unknown@email.com',
                                                initiatorPhone: result.data.payload.initiatorInfo?.phone ?? 'Unknown Phone',
                                                viewType: ViewType.Text,
                                                initiatorAddress: {
                                                  'street': result.data.payload.initiatorInfo?.address?.street ?? 'Unknown Street',
                                                  'postal_code': result.data.payload.initiatorInfo?.address?.postalCode ?? '0000',
                                                  'city': result.data.payload.initiatorInfo?.address?.city ?? 'Unknown City',
                                                  'region': result.data.payload.initiatorInfo?.address?.region ?? 'Unknown Region',
                                                  'country': result.data.payload.initiatorInfo?.address?.country ?? 'Unknown Country',
                                                },
                                                createdAt: result.data.payload.createdAt,
                                                lastControlDateAt: result.data.payload.initiatorInfo?.lastControl ?? DateTime.now(),
                                                history: true,
                                                action: result.data.payload.action,
                                                phoneCodesId: result.data.payload.textCodesId,
                                                logoPath: result.data.payload.initiatorInfo?.logoPath,
                                                websiteUrl: result.data.payload.initiatorInfo?.websiteUrl,
                                              );
                                            } else {
                                              widget = const SizedBox.shrink();
                                            }

                                            return widget;
                                          },
                                        ),
                                      ],
                                    );
                                  } else if (searchController.text.isEmpty && (error == null || error.isEmpty)) {
                                    // Vis CustomHelpText når inputfeltet er tomt som hjælpetekst (og ingen fejl)
                                    return Column(
                                      children: [
                                        CustomHelpText(text: I18nService().t('screen_text_code.help_text', fallback: 'Enter the code you received via SMS or email to validate it.')),
                                        Gap(AppDimensionsTheme.getLarge(context)),
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
                                    Gap(AppDimensionsTheme.getLarge(context)),
                                    CustomCodeValidation(
                                      content: I18nService().t('screen_text_code.error_code_box_not_valid', fallback: 'The code is invalid'),
                                      state: ValidationState.invalid,
                                    ),
                                    // Gap(AppDimensionsTheme.getLarge(context)),
                                    // Text(
                                    //   error,
                                    //   textAlign: TextAlign.center,
                                    //   style: const TextStyle(
                                    //     color: Color(0xFF014459),
                                    //     fontFamily: 'Poppins',
                                    //     fontSize: 16,
                                    //     fontStyle: FontStyle.normal,
                                    //     fontWeight: FontWeight.w400,
                                    //   ),
                                    // ),
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
                  ValueListenableBuilder<bool>(
                    valueListenable: isInputFocused,
                    builder: (context, isFocused, child) {
                      // Skjul knappen når input feltet har focus (keyboard er synligt)
                      if (isFocused) {
                        return const SizedBox.shrink();
                      }

                      final button = Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CustomButton(
                          key: const Key('get_demo_email_button'),
                          onPressed: () => _onGetDemoEmailPressed(ref, context),
                          buttonType: CustomButtonType.secondary,
                          text: I18nService().t('screen_text_code.get_demo_email', fallback: 'Get demo email'),
                        ),
                      );

                      return Platform.isAndroid ? SafeArea(top: false, child: button) : button;
                    },
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
