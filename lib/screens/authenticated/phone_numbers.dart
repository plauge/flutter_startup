import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/phone_numbers/add_phone_number_modal.dart';

class PhoneNumbersScreen extends AuthenticatedScreen {
  PhoneNumbersScreen({super.key}) : super(pin_code_protected: false);
  static final log = scopedLogger(LogCategory.gui);

  static Future<PhoneNumbersScreen> create() async {
    final screen = PhoneNumbersScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackScreenView(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('phone_numbers_screen_viewed', {
      'screen': 'phone_numbers',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackAction(WidgetRef ref, String action, {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = <String, dynamic>{
      'action': action,
      'screen': 'phone_numbers',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (properties != null) {
      eventData.addAll(properties);
    }
    analytics.track('phone_numbers_$action', eventData);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Track screen view
    _trackScreenView(ref);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_numbers.title', fallback: 'Phone Numbers'),
        backRoutePath: '/settings',
        showSettings: false,
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('phone_numbers_add_button'),
        onPressed: () {
          _trackAction(ref, 'add_phone_button_pressed');
          _handleAddPhoneNumberButtonPressed(context, ref);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SvgPicture.asset(
          'assets/icons/add-connection.svg',
          width: 65,
          height: 65,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Return to Phone calls button
                CustomButton(
                  key: const Key('phone_numbers_return_to_phone_calls_button'),
                  text: I18nService().t('screen_phone_numbers.return_to_phone_calls', fallback: 'Return to Phone calls'),
                  buttonType: CustomButtonType.secondary,
                  onPressed: () {
                    _trackAction(ref, 'return_to_phone_calls_pressed');
                    context.go('/phone-code');
                  },
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),

                CustomText(
                  text: I18nService().t('screen_phone_numbers.description', fallback: 'Click the plus sign to add your phone number.'),
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),

                // Phone numbers list
                Consumer(
                  builder: (context, ref, child) {
                    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);

                    return RefreshIndicator(
                      onRefresh: () async {
                        _trackAction(ref, 'refresh_phone_numbers');
                        // Invalidate the provider to force fresh data
                        ref.invalidate(phoneNumbersProvider);
                        // Wait for the new data to load
                        await ref.read(phoneNumbersProvider.future);
                      },
                      child: phoneNumbersAsync.when(
                        data: (responses) {
                          if (responses.isEmpty) {
                            return ListView(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
                                  child: CustomText(
                                    text: I18nService().t('screen_phone_numbers.no_phone_numbers', fallback: 'No phone numbers found.'),
                                    type: CustomTextType.bread,
                                    alignment: CustomTextAlignment.center,
                                  ),
                                ),
                              ],
                            );
                          }

                          final phoneNumbers = responses.first.data.payload;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: phoneNumbers.length,
                            itemBuilder: (context, index) {
                              final phoneNumber = phoneNumbers[index];
                              return Dismissible(
                                key: Key(phoneNumber.userPhoneNumbersId),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  _trackAction(ref, 'phone_number_swipe_delete_attempted', properties: {
                                    'phone_number_id': phoneNumber.userPhoneNumbersId,
                                    'is_primary': phoneNumber.primaryPhone,
                                  });
                                  final shouldDelete = await _showDeleteConfirmationDialog(context, ref, phoneNumber.encryptedPhoneNumber);
                                  if (shouldDelete == true) {
                                    await _deletePhoneNumber(context, ref, phoneNumber.encryptedPhoneNumber);
                                    return true;
                                  }
                                  return false;
                                },
                                onDismissed: (direction) {
                                  // Note: Don't call delete here as it causes rebuild conflicts
                                  // Delete is handled by confirmDismiss returning true
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                child: Card(
                                  margin: EdgeInsets.only(bottom: AppDimensionsTheme.getSmall(context)),
                                  child: FutureBuilder<String>(
                                    future: _decryptAndFormatPhoneNumber(phoneNumber.encryptedPhoneNumber, ref),
                                    builder: (context, snapshot) {
                                      String displayText;
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        displayText = 'Decrypting...';
                                      } else if (snapshot.hasError) {
                                        displayText = 'Error loading phone number';
                                      } else {
                                        displayText = snapshot.data ?? 'Unknown number';
                                      }

                                      return ListTile(
                                        title: CustomText(
                                          text: displayText,
                                          type: CustomTextType.cardHead,
                                        ),
                                        trailing: phoneNumber.primaryPhone ? Icon(Icons.star, color: AppColors.primaryColor(context)) : null,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => ListView(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Center(child: CircularProgressIndicator()),
                          ],
                        ),
                        error: (error, stack) => ListView(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
                              child: CustomText(
                                text: I18nService().t('screen_phone_numbers.error_loading', fallback: 'Error loading phone numbers: $error'),
                                type: CustomTextType.bread,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Decrypts and formats phone number to show country code in parentheses
  /// Example: +4549221438 becomes (+45) 49221438
  /// Handles country codes of 1-4 digits
  Future<String> _decryptAndFormatPhoneNumber(String encryptedPhoneNumber, WidgetRef ref) async {
    try {
      // Get token for decryption
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        return 'Error: No token available';
      }

      // Decrypt the phone number
      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, token);

      return _formatPhoneNumber(decryptedPhoneNumber);
    } catch (e) {
      log('[phone_numbers.dart][_decryptAndFormatPhoneNumber] Error decrypting phone number: $e');
      return 'Error decrypting phone number';
    }
  }

  /// Formats phone number to show country code in parentheses
  /// Example: +4549221438 becomes (+45) 49221438
  /// Handles country codes of 1-4 digits
  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return phoneNumber; // Return as-is if no country code
    }

    String digits = phoneNumber.substring(1); // Remove the '+'
    if (digits.isEmpty) return phoneNumber;

    // Try to find the country code by checking against known codes
    String? countryCode = _findCountryCode(digits);

    if (countryCode != null) {
      String restOfNumber = digits.substring(countryCode.length);
      return '(+$countryCode) $restOfNumber';
    }

    // Fallback: try common patterns
    // 1-digit codes (like +1 for USA/Canada)
    if (digits.length > 1 && _isValidSingleDigitCode(digits[0])) {
      return '(+${digits[0]}) ${digits.substring(1)}';
    }

    // 2-digit codes (most European countries)
    if (digits.length > 2) {
      return '(+${digits.substring(0, 2)}) ${digits.substring(2)}';
    }

    return phoneNumber; // Fallback to original
  }

  /// Finds the country code by checking against known country codes
  String? _findCountryCode(String digits) {
    // Known country codes - ordered by length (longest first for proper matching)
    Map<String, int> knownCodes = {
      // 4-digit codes (NANP regions)
      '1473': 4, '1767': 4, '1809': 4, '1829': 4, '1849': 4, '1868': 4, '1869': 4,
      '1876': 4, '1939': 4, '1345': 4, '1441': 4, '1664': 4, '1721': 4, '1758': 4,
      '1784': 4, '1787': 4, '1671': 4,

      // 3-digit codes
      '358': 3, '372': 3, '370': 3, '371': 3, '374': 3, '375': 3, '376': 3,
      '377': 3, '378': 3, '380': 3, '381': 3, '382': 3, '383': 3, '385': 3, '386': 3,
      '387': 3, '389': 3, '420': 3, '421': 3, '423': 3, '590': 3, '591': 3, '592': 3,
      '593': 3, '594': 3, '595': 3, '596': 3, '597': 3, '598': 3, '599': 3, '500': 3,
      '501': 3, '502': 3, '503': 3, '504': 3, '505': 3, '506': 3, '507': 3, '508': 3,
      '509': 3, '240': 3, '241': 3, '242': 3, '243': 3, '244': 3, '245': 3, '246': 3,
      '248': 3, '249': 3, '250': 3, '251': 3, '252': 3, '253': 3, '254': 3, '255': 3,
      '256': 3, '257': 3, '258': 3, '260': 3, '261': 3, '262': 3, '263': 3, '264': 3,
      '265': 3, '266': 3, '267': 3, '268': 3, '269': 3, '290': 3, '291': 3, '297': 3,
      '298': 3, '299': 3, '350': 3, '351': 3, '352': 3, '353': 3, '354': 3, '355': 3,
      '356': 3, '357': 3,

      // 2-digit codes
      '45': 2, '46': 2, '47': 2, '48': 2, '49': 2, '30': 2, '31': 2, '32': 2, '33': 2,
      '34': 2, '35': 2, '36': 2, '37': 2, '38': 2, '39': 2, '40': 2, '41': 2, '42': 2,
      '43': 2, '44': 2, '51': 2, '52': 2, '53': 2, '54': 2, '55': 2, '56': 2, '57': 2,
      '58': 2, '60': 2, '61': 2, '62': 2, '63': 2, '64': 2, '65': 2, '66': 2, '81': 2,
      '82': 2, '84': 2, '86': 2, '90': 2, '91': 2, '92': 2, '93': 2, '94': 2, '95': 2,
      '98': 2, '20': 2, '27': 2,

      // 1-digit codes
      '1': 1, '7': 1, // USA/Canada, Russia/Kazakhstan
    };

    // Check from longest to shortest to ensure proper matching
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

  /// Check if single digit is a valid country code
  bool _isValidSingleDigitCode(String digit) {
    return ['1', '7'].contains(digit); // USA/Canada, Russia/Kazakhstan
  }

  /// Handles add phone number button press - checks if user can add more numbers
  void _handleAddPhoneNumberButtonPressed(BuildContext context, WidgetRef ref) {
    final phoneNumbersAsync = ref.read(phoneNumbersProvider);

    phoneNumbersAsync.when(
      data: (responses) {
        if (responses.isNotEmpty && responses.first.data.payload.isNotEmpty) {
          // User already has phone numbers - show limitation dialog
          _trackAction(ref, 'add_phone_button_blocked_limit_reached');
          _showPhoneNumberLimitationDialog(context, ref);
        } else {
          // No phone numbers - allow adding
          _showAddPhoneNumberModal(context, ref);
        }
      },
      loading: () {
        // During loading, allow the action (worst case scenario)
        _showAddPhoneNumberModal(context, ref);
      },
      error: (error, stack) {
        // On error, allow the action (worst case scenario)
        _showAddPhoneNumberModal(context, ref);
      },
    );
  }

  /// Shows modal to add new phone number
  void _showAddPhoneNumberModal(BuildContext context, WidgetRef ref) {
    _trackAction(ref, 'add_phone_modal_opened');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPhoneNumberModal(trackAction: (action, {properties}) => _trackAction(ref, action, properties: properties)),
    );
  }

  /// Shows dialog informing user about phone number limitation
  void _showPhoneNumberLimitationDialog(BuildContext context, WidgetRef ref) {
    _trackAction(ref, 'phone_number_limitation_dialog_opened');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_phone_numbers.limitation_title', fallback: 'Phone Number Limit'),
            type: CustomTextType.cardHead,
          ),
          content: CustomText(
            text: I18nService().t('screen_phone_numbers.limitation_message', fallback: 'It is currently only possible to add one phone number.'),
            type: CustomTextType.bread,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _trackAction(ref, 'phone_number_limitation_dialog_closed');
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: I18nService().t('button.ok', fallback: 'OK'),
                type: CustomTextType.cardHead,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows confirmation dialog before deleting phone number
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, String encryptedPhoneNumber) async {
    _trackAction(ref, 'delete_confirmation_dialog_opened');

    // Decrypt the phone number for display
    final formattedPhoneNumber = await _decryptAndFormatPhoneNumber(encryptedPhoneNumber, ref);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_phone_numbers.delete_phone_number', fallback: 'Delete Phone Number'),
            type: CustomTextType.cardHead,
          ),
          content: CustomText(
            text: I18nService().t(
              'screen_phone_numbers.delete_confirmation',
              fallback: 'Are you sure you want to delete this phone number?\n\n$formattedPhoneNumber',
              variables: {'phoneNumber': formattedPhoneNumber},
            ),
            type: CustomTextType.bread,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _trackAction(ref, 'delete_confirmation_cancelled');
                Navigator.of(context).pop(false);
              },
              child: CustomText(
                text: I18nService().t('button.cancel', fallback: 'Cancel'),
                type: CustomTextType.cardHead,
              ),
            ),
            TextButton(
              onPressed: () {
                _trackAction(ref, 'delete_confirmation_confirmed');
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: CustomText(
                text: I18nService().t('button.delete', fallback: 'Delete'),
                type: CustomTextType.cardHead,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Deletes phone number using the provider
  Future<void> _deletePhoneNumber(BuildContext context, WidgetRef ref, String encryptedPhoneNumber) async {
    _trackAction(ref, 'delete_phone_initiated');
    log('[phone_numbers.dart][_deletePhoneNumber] Deleting phone number, first decrypting: $encryptedPhoneNumber');

    try {
      // Get token for decryption
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        throw Exception('Ingen token tilgængelig for dekryptering');
      }

      // Decrypt the phone number before sending to delete service
      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, token);
      log('[phone_numbers.dart][_deletePhoneNumber] Decrypted phone number for deletion: $decryptedPhoneNumber');

      final result = await ref.read(deletePhoneNumberProvider(
        inputPhoneNumber: decryptedPhoneNumber,
      ).future);

      if (result) {
        _trackAction(ref, 'delete_phone_success');
        log('[phone_numbers.dart][_deletePhoneNumber] Phone number deleted successfully');

        // Refresh phone numbers list after a small delay to avoid rebuild conflicts
        Future.microtask(() => ref.invalidate(phoneNumbersProvider));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: I18nService().t('screen_phone_numbers.delete_success', fallback: 'Phone number deleted successfully'),
              type: CustomTextType.bread,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _trackAction(ref, 'delete_phone_failed', properties: {'error': 'service_returned_false'});
        log('[phone_numbers.dart][_deletePhoneNumber] Failed to delete phone number');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: I18nService().t('screen_phone_numbers.delete_error', fallback: 'Error deleting phone number'),
              type: CustomTextType.bread,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _trackAction(ref, 'delete_phone_failed', properties: {'error': e.toString()});
      log('[phone_numbers.dart][_deletePhoneNumber] Exception deleting phone number: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: I18nService().t('screen_phone_numbers.delete_error', fallback: 'Error deleting phone number'),
            type: CustomTextType.bread,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Created: 2024-12-30 09:00:00
