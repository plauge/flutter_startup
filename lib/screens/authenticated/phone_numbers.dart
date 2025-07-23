import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneNumbersScreen extends AuthenticatedScreen {
  PhoneNumbersScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneNumbersScreen> create() async {
    final screen = PhoneNumbersScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackPhoneNumbersEvent(WidgetRef ref, String eventType, String action, {Map<String, String>? additionalData}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = {
      'event_type': eventType,
      'action': action,
      'screen': 'phone_numbers',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (additionalData != null) {
      eventData.addAll(additionalData);
    }
    analytics.track('phone_numbers_event', eventData);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_numbers.title', fallback: 'Phone Numbers'),
        backRoutePath: '/settings',
        showSettings: false,
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('phone_numbers_add_button'),
        onPressed: () {
          _trackPhoneNumbersEvent(ref, 'ui_interaction', 'add_phone_button_pressed');
          _showAddPhoneNumberModal(context, ref);
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
                CustomText(
                  text: I18nService().t('screen_phone_numbers.description', fallback: 'Manage your phone numbers and configure how you receive verification codes.'),
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),

                // Phone numbers list
                Consumer(
                  builder: (context, ref, child) {
                    final phoneNumbersAsync = ref.watch(phoneNumbersProvider);

                    return RefreshIndicator(
                      onRefresh: () async {
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
                                  child: ListTile(
                                    title: CustomText(
                                      text: _formatPhoneNumber(phoneNumber.encryptedPhoneNumber),
                                      type: CustomTextType.cardHead,
                                    ),
                                    trailing: phoneNumber.primaryPhone ? Icon(Icons.star, color: AppColors.primaryColor(context)) : null,
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

  /// Shows modal to add new phone number
  void _showAddPhoneNumberModal(BuildContext context, WidgetRef ref) {
    _trackPhoneNumbersEvent(ref, 'modal', 'add_phone_modal_opened');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddPhoneNumberModal(),
    );
  }

  /// Shows confirmation dialog before deleting phone number
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, String phoneNumber) async {
    _trackPhoneNumbersEvent(ref, 'modal', 'delete_confirmation_dialog_opened');
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
              fallback: 'Are you sure you want to delete this phone number?\n\n${_formatPhoneNumber(phoneNumber)}',
              variables: {'phoneNumber': _formatPhoneNumber(phoneNumber)},
            ),
            type: CustomTextType.bread,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _trackPhoneNumbersEvent(ref, 'modal', 'delete_confirmation_cancelled');
                Navigator.of(context).pop(false);
              },
              child: CustomText(
                text: I18nService().t('button.cancel', fallback: 'Cancel'),
                type: CustomTextType.cardHead,
              ),
            ),
            TextButton(
              onPressed: () {
                _trackPhoneNumbersEvent(ref, 'modal', 'delete_confirmation_confirmed');
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
  Future<void> _deletePhoneNumber(BuildContext context, WidgetRef ref, String phoneNumber) async {
    _trackPhoneNumbersEvent(ref, 'phone_management', 'delete_phone_initiated');
    final log = scopedLogger(LogCategory.gui);
    log('[phone_numbers.dart][_deletePhoneNumber] Deleting phone number: $phoneNumber');

    try {
      final result = await ref.read(deletePhoneNumberProvider(
        inputPhoneNumber: phoneNumber,
      ).future);

      if (result) {
        _trackPhoneNumbersEvent(ref, 'phone_management', 'delete_phone_success');
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
        _trackPhoneNumbersEvent(ref, 'phone_management', 'delete_phone_failed', additionalData: {'error': 'service_returned_false'});
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
      _trackPhoneNumbersEvent(ref, 'phone_management', 'delete_phone_failed', additionalData: {'error': e.toString()});
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

/// Modal widget for adding phone numbers
class _AddPhoneNumberModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddPhoneNumberModal> createState() => _AddPhoneNumberModalState();
}

class _AddPhoneNumberModalState extends ConsumerState<_AddPhoneNumberModal> {
  static final log = scopedLogger(LogCategory.gui);
  late final TextEditingController _phoneController;
  late final TextEditingController _pinController;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'DK');
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneNumberValid = false;
  int _currentStep = 1; // 1 for phone input, 2 for PIN input

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _pinController = TextEditingController();

    // Add listener to filter non-digit characters
    _phoneController.addListener(() {
      final text = _phoneController.text;
      final filteredText = text.replaceAll(RegExp(r'[^0-9]'), '');

      if (text != filteredText) {
        _phoneController.value = _phoneController.value.copyWith(
          text: filteredText,
          selection: TextSelection.collapsed(offset: filteredText.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  /// Validates if a phone number is valid based on basic rules
  bool _isValidPhoneNumber(PhoneNumber phoneNumber) {
    final phoneNumberString = phoneNumber.phoneNumber;

    // Basic validation: must have phone number and not be null
    if (phoneNumberString == null || phoneNumberString.isEmpty) {
      return false;
    }

    // Must start with + and country code
    if (!phoneNumberString.startsWith('+')) {
      return false;
    }

    // Remove + and check if rest are digits
    final digits = phoneNumberString.substring(1);
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      return false;
    }

    // Get the dial code and national number
    final dialCode = phoneNumber.dialCode;
    if (dialCode == null || dialCode.isEmpty) {
      return false;
    }

    // Remove the dial code (without +) from the full number to get national number
    final dialCodeDigits = dialCode.substring(1); // Remove + from dial code
    if (!digits.startsWith(dialCodeDigits)) {
      return false;
    }

    final nationalNumber = digits.substring(dialCodeDigits.length);

    // Country-specific validation
    switch (phoneNumber.isoCode) {
      case 'DK': // Denmark
        return nationalNumber.length == 8;
      case 'AF': // Afghanistan
        return nationalNumber.length >= 7 && nationalNumber.length <= 9;
      case 'SE': // Sweden
        return nationalNumber.length >= 7 && nationalNumber.length <= 9;
      case 'NO': // Norway
        return nationalNumber.length == 8;
      case 'DE': // Germany
        return nationalNumber.length >= 10 && nationalNumber.length <= 11;
      case 'GB': // United Kingdom
        return nationalNumber.length == 10;
      case 'US': // United States
      case 'CA': // Canada
        return nationalNumber.length == 10;
      case 'FR': // France
        return nationalNumber.length == 9;
      case 'IT': // Italy
        return nationalNumber.length >= 8 && nationalNumber.length <= 10;
      case 'ES': // Spain
        return nationalNumber.length == 9;
      case 'NL': // Netherlands
        return nationalNumber.length == 9;
      case 'BE': // Belgium
        return nationalNumber.length == 8;
      case 'CH': // Switzerland
        return nationalNumber.length == 9;
      case 'AT': // Austria
        return nationalNumber.length >= 10 && nationalNumber.length <= 13;
      case 'PL': // Poland
        return nationalNumber.length == 9;
      case 'FI': // Finland
        return nationalNumber.length >= 6 && nationalNumber.length <= 8;
      case 'JP': // Japan
        return nationalNumber.length >= 10 && nationalNumber.length <= 11;
      case 'AU': // Australia
        return nationalNumber.length == 9;
      case 'CN': // China
        return nationalNumber.length == 11;
      case 'IN': // India
        return nationalNumber.length == 10;
      case 'BR': // Brazil
        return nationalNumber.length == 11;
      case 'MX': // Mexico
        return nationalNumber.length == 10;
      case 'RU': // Russia
        return nationalNumber.length == 10;
      default:
        // For unknown countries, use more lenient validation
        return nationalNumber.length >= 6 && nationalNumber.length <= 12;
    }
  }

  /// Returns validation error message for phone number or null if valid
  String? _getPhoneValidationError() {
    if (_phoneController.text.isEmpty) {
      return null; // Don't show error for empty field
    }

    if (!_isPhoneNumberValid) {
      return I18nService().t(
        'screen_phone_numbers.invalid_phone_format',
        fallback: 'Invalid phone number format for ${_phoneNumber.isoCode}',
        variables: {'country': _phoneNumber.isoCode ?? 'selected country'},
      );
    }

    return null;
  }

  /// Validates phone number format based on selected country
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return I18nService().t('screen_phone_numbers.phone_number_required', fallback: 'Phone number is required');
    }

    if (!_isPhoneNumberValid) {
      return I18nService().t(
        'screen_phone_numbers.invalid_phone_format',
        fallback: 'Invalid phone number format for ${_phoneNumber.isoCode}',
        variables: {'country': _phoneNumber.isoCode ?? 'selected country'},
      );
    }

    return null;
  }

  /// Confirm phone number and send PIN
  Future<void> _confirmPhoneNumber() async {
    // Validate phone number first
    final validationError = _validatePhoneNumber(_phoneController.text);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    if (_phoneNumber.phoneNumber == null || _phoneNumber.phoneNumber!.isEmpty) {
      setState(() {
        _errorMessage = I18nService().t('screen_phone_numbers.phone_number_required', fallback: 'Phone number is required');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      log('[phone_numbers.dart][_confirmPhoneNumber] Sending PIN for phone number validation: ${_phoneNumber.phoneNumber}');

      final result = await ref.read(sendPinForPhoneNumberValidationProvider.future);

      if (result) {
        log('[phone_numbers.dart][_confirmPhoneNumber] PIN sent successfully');
        setState(() {
          _currentStep = 2;
        });
      } else {
        log('[phone_numbers.dart][_confirmPhoneNumber] Failed to send PIN');
        _showAlert(I18nService().t('screen_phone_numbers.pin_send_error', fallback: 'Failed to send PIN. Please try again.'));
      }
    } catch (e) {
      log('[phone_numbers.dart][_confirmPhoneNumber] Exception sending PIN: $e');
      _showAlert(I18nService().t('screen_phone_numbers.pin_send_error', fallback: 'Failed to send PIN. Please try again.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show alert dialog
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('alert.title', fallback: 'Alert'),
            type: CustomTextType.cardHead,
          ),
          content: CustomText(
            text: message,
            type: CustomTextType.bread,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppDimensionsTheme.getLarge(context)),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            CustomText(
              text: _currentStep == 1 ? I18nService().t('screen_phone_numbers.add_phone_number', fallback: 'Add Phone Number') : I18nService().t('screen_phone_numbers.verify_phone_number', fallback: 'Verify Phone Number'),
              type: CustomTextType.cardHead,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),

            // Step 1: Phone number input
            if (_currentStep == 1) ..._buildStep1(),

            // Step 2: PIN input
            if (_currentStep == 2) ..._buildStep2(),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppDimensionsTheme.getMedium(context)),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // Action button
            _currentStep == 1
                ? CustomButton(
                    key: const Key('phone_numbers_confirm_number_button'),
                    text: I18nService().t('screen_phone_numbers.confirm_number', fallback: 'Confirm Number'),
                    onPressed: (_isLoading || !_isPhoneNumberValid || _phoneController.text.isEmpty) ? () {} : _confirmPhoneNumber,
                    enabled: !_isLoading && _isPhoneNumberValid && _phoneController.text.isNotEmpty,
                  )
                : CustomButton(
                    key: const Key('phone_numbers_save_button'),
                    text: I18nService().t('button.save', fallback: 'Save'),
                    onPressed: (_isLoading || _pinController.text.length != 6) ? () {} : _savePhoneNumber,
                    enabled: !_isLoading && _pinController.text.length == 6,
                  ),
          ],
        ),
      ),
    );
  }

  /// Build step 1 widgets (phone number input)
  List<Widget> _buildStep1() {
    return [
      // Country info
      if (_phoneNumber.isoCode != null)
        Padding(
          padding: EdgeInsets.only(bottom: AppDimensionsTheme.getSmall(context)),
          child: CustomText(
            text: I18nService().t(
              'screen_phone_numbers.selected_country',
              fallback: 'Selected country: ${_phoneNumber.isoCode} (+${_phoneNumber.dialCode})',
              variables: {
                'country': _phoneNumber.isoCode!,
                'dialCode': _phoneNumber.dialCode ?? '',
              },
            ),
            type: CustomTextType.small_bread,
            alignment: CustomTextAlignment.left,
          ),
        ),

      // Phone number input
      InternationalPhoneNumberInput(
        countries: const ['DK', 'SE', 'NO', 'FI'], // Danmark, Sverige, Norge, Finland
        onInputChanged: (PhoneNumber number) {
          log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number changed: ${number.phoneNumber}');
          log('[phone_numbers.dart][_AddPhoneNumberModal] Country: ${number.isoCode}, Dial code: ${number.dialCode}');
          setState(() {
            _phoneNumber = number;
            _errorMessage = null; // Clear error when user types
            // Use a more lenient validation approach
            _isPhoneNumberValid = _isValidPhoneNumber(number);
            log('[phone_numbers.dart][_AddPhoneNumberModal] Is valid: $_isPhoneNumberValid');
          });
        },
        onInputValidated: (bool value) {
          log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number validation callback: $value');
          // Note: This callback can be unreliable, so we handle validation ourselves
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          showFlags: true,
          setSelectorButtonAsPrefixIcon: true,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        selectorTextStyle: const TextStyle(fontSize: 16),
        textStyle: const TextStyle(fontSize: 16),
        initialValue: _phoneNumber,
        textFieldController: _phoneController,
        formatInput: true,
        keyboardType: TextInputType.number,
        inputDecoration: AppTheme.getTextFieldDecoration(context),
        onSaved: (PhoneNumber number) {
          log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number saved: ${number.phoneNumber}');
        },
      ),
      Gap(AppDimensionsTheme.getSmall(context)),

      // Validation status
      if (_phoneController.text.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(bottom: AppDimensionsTheme.getSmall(context)),
          child: Row(
            children: [
              Icon(
                _isPhoneNumberValid ? Icons.check_circle : Icons.error,
                color: _isPhoneNumberValid ? Colors.green : Colors.red,
                size: 20,
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              Expanded(
                child: Text(
                  _isPhoneNumberValid
                      ? I18nService().t('screen_phone_numbers.valid_phone_number', fallback: 'Valid phone number')
                      : I18nService().t(
                          'screen_phone_numbers.invalid_phone_format',
                          fallback: 'Invalid phone number format for ${_phoneNumber.isoCode}',
                          variables: {'country': _phoneNumber.isoCode ?? 'selected country'},
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isPhoneNumberValid ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),

      Gap(AppDimensionsTheme.getSmall(context)),
    ];
  }

  /// Build step 2 widgets (PIN input)
  List<Widget> _buildStep2() {
    return [
      // Description
      CustomText(
        text: I18nService().t(
          'screen_phone_numbers.pin_description',
          fallback: 'You will now receive an SMS with a PIN code, enter it here.',
        ),
        type: CustomTextType.bread,
        alignment: CustomTextAlignment.center,
      ),
      Gap(AppDimensionsTheme.getLarge(context)),

      // PIN input
      Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
        child: PinCodeTextField(
          key: const Key('phone_numbers_pin_field'),
          appContext: context,
          length: 6,
          controller: _pinController,
          obscureText: false,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(4),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            selectedFillColor: Colors.white,
            inactiveFillColor: Colors.white,
            activeColor: Theme.of(context).primaryColor,
            selectedColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey,
          ),
          enableActiveFill: true,
          onCompleted: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ),
      Gap(AppDimensionsTheme.getLarge(context)),
    ];
  }

  /// Save phone number using the provider
  Future<void> _savePhoneNumber() async {
    if (_pinController.text.length != 6) {
      setState(() {
        _errorMessage = I18nService().t('screen_phone_numbers.pin_required', fallback: 'PIN code is required');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      log('[phone_numbers.dart][_savePhoneNumber] Saving phone number with PIN: ${_phoneNumber.phoneNumber}');

      // TODO: We need to encrypt the phone number before saving
      // For now, using the plain phone number as both parameters
      final result = await ref.read(createPhoneNumberProvider(
        inputEncryptedPhoneNumber: _phoneNumber.phoneNumber!,
        inputPhoneNumber: _phoneNumber.phoneNumber!,
      ).future);

      if (result) {
        log('[phone_numbers.dart][_savePhoneNumber] Phone number saved successfully');
        // Close modal
        if (mounted) Navigator.of(context).pop();
        // Refresh phone numbers list
        ref.invalidate(phoneNumbersProvider);
      } else {
        log('[phone_numbers.dart][_savePhoneNumber] Failed to save phone number');
        setState(() {
          _errorMessage = I18nService().t('screen_phone_numbers.save_error', fallback: 'Error');
        });
      }
    } catch (e) {
      log('[phone_numbers.dart][_savePhoneNumber] Exception saving phone number: $e');
      setState(() {
        _errorMessage = I18nService().t('screen_phone_numbers.save_error', fallback: 'Error');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Created: 2024-12-30 09:00:00
