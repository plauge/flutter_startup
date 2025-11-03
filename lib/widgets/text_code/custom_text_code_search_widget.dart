import '../../exports.dart';
import '../../widgets/phone_codes/phone_call_widget.dart';
import '../../widgets/phone_codes/phone_call_user_widget.dart' as UserWidget;
import '../../widgets/custom/custom_invite_trusted_companies_link.dart';
import '../../providers/contact_provider.dart';
import '../../providers/text_code_search_result_provider.dart';
import 'custom_demo_email_button.dart';
import 'package:flutter/services.dart';

class CustomTextCodeSearchWidget extends ConsumerStatefulWidget {
  const CustomTextCodeSearchWidget({
    super.key,
  });

  @override
  ConsumerState<CustomTextCodeSearchWidget> createState() => _CustomTextCodeSearchWidgetState();
}

class _CustomTextCodeSearchWidgetState extends ConsumerState<CustomTextCodeSearchWidget> {
  static final log = scopedLogger(LogCategory.gui);

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
        // Reset provider when text is cleared
        ref.read(textCodeSearchResultProvider.notifier).setHasResult(false);
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

  void _trackAction(String action, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('text_code_action', {
      ...properties,
      'action': action,
      'screen': 'text_code',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onInsertPressed(BuildContext context) async {
    log('_onInsertPressed: Insert pressed from lib/widgets/text_code/custom_text_code_search_widget.dart');

    _trackAction('insert_pressed', {});

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardTextRaw = clipboardData?.text;
      final clipboardTextTrimmed = clipboardTextRaw?.trim();
      final clipboardText = clipboardTextTrimmed?.replaceAll(RegExp(r'\s+'), '');

      log('_onInsertPressed: Clipboard raw: "$clipboardTextRaw"');
      log('_onInsertPressed: Clipboard trimmed: "$clipboardTextTrimmed"');
      log('_onInsertPressed: Clipboard no-whitespace: "$clipboardText"');

      if (clipboardText != null && clipboardText.isNotEmpty) {
        searchController.text = clipboardText;
        log('_onInsertPressed: Clipboard value inserted into input field: $clipboardText');
        _trackAction('insert_success', {
          'clipboard_length': clipboardText.length,
        });
      } else {
        log('_onInsertPressed: Clipboard was empty');
        _trackAction('insert_failed', {
          'reason': 'empty_clipboard',
        });
      }
    } catch (e) {
      log('_onInsertPressed: Error reading clipboard: $e');
      _trackAction('insert_error', {
        'error': e.toString(),
      });
    }
  }

  void _onResetPressed(BuildContext context) {
    log('_onResetPressed: Reset pressed from lib/widgets/text_code/custom_text_code_search_widget.dart');

    _trackAction('reset_pressed', {});

    // Luk keyboardet
    FocusScope.of(context).unfocus();

    // Ryd input feltet
    searchController.clear();

    // Ryd resultat og fejl
    searchResult.value = null;
    searchError.value = null;

    // Reset provider
    ref.read(textCodeSearchResultProvider.notifier).setHasResult(false);
  }

  void _onSearchPressed(String searchValue, BuildContext context) {
    log('_onSearchPressed: Search pressed with value: $searchValue from lib/widgets/text_code/custom_text_code_search_widget.dart');

    _trackAction('search_pressed', {
      'search_value': searchValue,
      'search_length': searchValue.length,
    });

    // Luk keyboardet når søgningen starter
    FocusScope.of(context).unfocus();

    // Valider at koden starter med "idt"
    if (!searchValue.toLowerCase().startsWith('idt')) {
      log('_onSearchPressed: Code does not start with "idt"');
      _trackAction('search_failed', {
        'reason': 'invalid_format',
        'search_value': searchValue,
      });
      searchResult.value = null;
      searchError.value = I18nService().t('screen_text_code.error_code_invalid_format', fallback: 'The code is not valid');
      // Reset provider when validation fails
      ref.read(textCodeSearchResultProvider.notifier).setHasResult(false);
      return;
    }

    ref.read(readTextCodeByConfirmCodeProvider(searchValue).future).then(
      (results) {
        log('_onSearchPressed: Received results: ${results.length} items');

        if (results.isNotEmpty && results.first.statusCode == 200) {
          log('_onSearchPressed: Success - status code 200');
          _trackAction('search_success', {
            'search_value': searchValue,
            'status_code': results.first.statusCode,
          });
          searchResult.value = results.first;
          searchError.value = null;
          // Set provider when result is found
          ref.read(textCodeSearchResultProvider.notifier).setHasResult(true);
        } else {
          log('_onSearchPressed: Failed - status code: ${results.isNotEmpty ? results.first.statusCode : 'no results'}');
          _trackAction('search_failed', {
            'reason': 'invalid_code',
            'search_value': searchValue,
            'status_code': results.isNotEmpty ? results.first.statusCode : 'no_results',
          });
          searchResult.value = null;
          searchError.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
          // Reset provider when search fails
          ref.read(textCodeSearchResultProvider.notifier).setHasResult(false);
        }
      },
      onError: (error) {
        log('_onSearchPressed: Error occurred: $error');
        _trackAction('search_error', {
          'error': error.toString(),
          'search_value': searchValue,
        });
        searchResult.value = null;
        searchError.value = I18nService().t('screen_text_code.error_code_not_valid', fallback: 'The code cannot be used and may be fraud.');
        // Reset provider when error occurs
        ref.read(textCodeSearchResultProvider.notifier).setHasResult(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getMedium(context)),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: I18nService().t('screen_text_code.search_hint', fallback: 'Enter code to validate'),
                showClearButton: true,
              ),
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            ValueListenableBuilder<TextCodesReadResponse?>(
              valueListenable: searchResult,
              builder: (context, result, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isSearchEnabled,
                  builder: (context, isEnabled, child) {
                    // Bestem knappens tilstand: Reset (hvis resultat), Verify (hvis tekst), eller Insert (hvis tom)
                    final hasResult = result != null;
                    final hasText = isEnabled;

                    String buttonText;
                    CustomButtonType buttonType;
                    VoidCallback? onPressed;

                    if (hasResult) {
                      // Reset tilstand: Rød knap
                      buttonText = I18nService().t('screen_text_code.reset_button', fallback: 'Reset');
                      buttonType = CustomButtonType.alert;
                      onPressed = () => _onResetPressed(context);
                    } else if (hasText) {
                      // Verify tilstand: Blå knap
                      buttonText = I18nService().t('screen_text_code.search_button', fallback: 'Verify');
                      buttonType = CustomButtonType.primary;
                      onPressed = () => _onSearchPressed(searchController.text, context);
                    } else {
                      // Insert tilstand: Samme som Verify
                      buttonText = I18nService().t('screen_text_code.insert_button', fallback: 'Insert');
                      buttonType = CustomButtonType.primary;
                      onPressed = () => _onInsertPressed(context);
                    }

                    return SizedBox(
                      width: 100,
                      child: CustomButton(
                        key: const Key('text_code_search_verify_insert_button'),
                        onPressed: onPressed,
                        buttonType: buttonType,
                        text: buttonText,
                        enabled: true,
                      ),
                    );
                  },
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
                              log('Building UserWidget with contactId: $contactId');
                              log('initiatorInfo data: ${result.data.payload.initiatorInfo?.toJson()}');

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
                                        log('Loaded contact from loadContactLight: ${contact.toJson()}');
                                        return UserWidget.PhoneCallUserWidget(
                                          initiatorName: '${contact.firstName} ${contact.lastName}',
                                          initiatorCompany: contact.company,
                                          initiatorPhone: null,
                                          createdAt: result.data.payload.createdAt,
                                          history: true,
                                          action: result.data.payload.action,
                                          phoneCodesId: result.data.payload.textCodesId,
                                          viewType: UserWidget.ViewType.Text,
                                          customerUserId: result.data.payload.customerUserId,
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
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Demo email button (skjules når keyboard er synligt)
        if (false)
          ValueListenableBuilder<bool>(
            valueListenable: isInputFocused,
            builder: (context, isFocused, child) {
              // Skjul button når input feltet har focus (keyboard er synligt)
              if (isFocused) {
                return const SizedBox.shrink();
              }
              return const CustomDemoEmailButton();
            },
          ),
      ],
    );
  }
}

// Created on 2025-11-01 at 15:12
