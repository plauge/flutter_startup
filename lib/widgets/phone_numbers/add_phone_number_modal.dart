import '../../exports.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Reusable modal widget for adding phone numbers with two-step verification
/// Step 1: Enter and validate phone number
/// Step 2: Enter PIN code received via SMS
class AddPhoneNumberModal extends ConsumerStatefulWidget {
  final Function(String action, {Map<String, dynamic>? properties}) trackAction;

  const AddPhoneNumberModal({super.key, required this.trackAction});

  @override
  ConsumerState<AddPhoneNumberModal> createState() => _AddPhoneNumberModalState();
}

class _AddPhoneNumberModalState extends ConsumerState<AddPhoneNumberModal> {
  static final log = scopedLogger(LogCategory.gui);
  late final TextEditingController _phoneController;
  late final TextEditingController _pinController;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'DK');
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneNumberValid = false;
  bool _isPinVisible = false;
  int _currentStep = 1; // 1 for phone input, 2 for PIN input

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _pinController = TextEditingController();

    // Track modal opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.trackAction('add_phone_modal_viewed', properties: {
        'step': _currentStep,
      });
    });

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
    widget.trackAction('confirm_phone_number_pressed', properties: {
      'phone_number_length': _phoneController.text.length,
      'country_code': _phoneNumber.isoCode,
      'is_valid': _isPhoneNumberValid,
    });

    // Validate phone number first
    final validationError = _validatePhoneNumber(_phoneController.text);
    if (validationError != null) {
      widget.trackAction('phone_number_validation_failed', properties: {
        'error': validationError,
      });
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
      log('[add_phone_number_modal.dart][_confirmPhoneNumber] Sending PIN for phone number validation: ${_phoneNumber.phoneNumber}');

      final result = await ref.read(sendPinForPhoneNumberValidationProvider(
        inputPhoneNumber: _phoneNumber.phoneNumber!,
      ).future);

      if (result) {
        log('[add_phone_number_modal.dart][_confirmPhoneNumber] PIN sent successfully');
        widget.trackAction('pin_send_success', properties: {
          'phone_number': _phoneNumber.phoneNumber!,
        });
        setState(() {
          _currentStep = 2;
        });
        widget.trackAction('step_changed', properties: {
          'from_step': 1,
          'to_step': 2,
        });
      } else {
        log('[add_phone_number_modal.dart][_confirmPhoneNumber] Failed to send PIN');
        widget.trackAction('pin_send_failed', properties: {
          'error': 'service_returned_false',
        });
        _showAlert(I18nService().t('screen_phone_numbers.pin_send_error', fallback: 'Failed to send PIN. Please try again.'));
      }
    } catch (e) {
      log('[add_phone_number_modal.dart][_confirmPhoneNumber] Exception sending PIN: $e');
      widget.trackAction('pin_send_failed', properties: {
        'error': e.toString(),
      });
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
      height: MediaQuery.of(context).size.height * 0.7, // Increased from 0.6 to 0.8
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
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
      Consumer(
        builder: (context, ref, child) {
          final appStatusAsync = ref.watch(securityAppStatusProvider);

          List<String> supportedCountries = ['DK']; // Fallback til Danmark

          appStatusAsync.whenData((appStatus) {
            supportedCountries = appStatus.data.payload.supportedCountryCodes;
          });

          return InternationalPhoneNumberInput(
            countries: supportedCountries,
            onInputChanged: (PhoneNumber number) {
              final wasValid = _isPhoneNumberValid;
              setState(() {
                _phoneNumber = number;
                _errorMessage = null; // Clear error when user types
                // Use a more lenient validation approach
                _isPhoneNumberValid = _isValidPhoneNumber(number);

                // Only log when validation status changes
                if (wasValid != _isPhoneNumberValid) {
                  log('[add_phone_number_modal.dart][_AddPhoneNumberModal] Phone validation changed: ${_isPhoneNumberValid ? "valid" : "invalid"} for ${number.isoCode}');
                  widget.trackAction('phone_number_validation_changed', properties: {
                    'is_valid': _isPhoneNumberValid,
                    'country_code': number.isoCode,
                    'phone_length': number.phoneNumber?.length ?? 0,
                  });
                }
              });
            },
            onInputValidated: (bool value) {
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
              log('[add_phone_number_modal.dart][_AddPhoneNumberModal] Phone number saved: ${number.phoneNumber}');
            },
          );
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
        alignment: CustomTextAlignment.left,
      ),
      Gap(AppDimensionsTheme.getLarge(context)),

      // Enter PIN code text and visibility toggle (same design as pin_confirm.dart)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: I18nService().t('screen_phone_numbers.enter_pin_code', fallback: 'Enter PIN code'),
            type: CustomTextType.info,
            alignment: CustomTextAlignment.left,
          ),
          IconButton(
            onPressed: () {
              widget.trackAction('pin_visibility_toggled', properties: {
                'from_visible': _isPinVisible,
                'to_visible': !_isPinVisible,
              });
              setState(() => _isPinVisible = !_isPinVisible);
            },
            icon: Icon(
              _isPinVisible ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      Gap(AppDimensionsTheme.getMedium(context)),

      // PIN input (same design as pin_confirm.dart)
      Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
        child: PinCodeTextField(
          key: const Key('phone_numbers_pin_field'),
          appContext: context,
          length: 6,
          controller: _pinController,
          obscureText: !_isPinVisible,
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
    ];
  }

  /// Save phone number using the provider
  Future<void> _savePhoneNumber() async {
    widget.trackAction('save_phone_number_pressed', properties: {
      'pin_length': _pinController.text.length,
      'phone_number': _phoneNumber.phoneNumber!,
    });

    if (_pinController.text.length != 6) {
      widget.trackAction('save_phone_number_validation_failed', properties: {
        'error': 'pin_length_invalid',
        'pin_length': _pinController.text.length,
      });
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
      log('[add_phone_number_modal.dart][_savePhoneNumber] Saving phone number with PIN: ${_phoneNumber.phoneNumber}');

      // Get token for encryption
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();
      if (token == null) {
        throw Exception('Ingen token tilgængelig for kryptering');
      }

      // Encrypt the phone number
      final encryptedPhoneNumber = await AESGCMEncryptionUtils.encryptString(_phoneNumber.phoneNumber!, token);

      final result = await ref.read(createPhoneNumberProvider(
        inputEncryptedPhoneNumber: encryptedPhoneNumber,
        inputPhoneNumber: _phoneNumber.phoneNumber!,
        inputPinCode: _pinController.text,
      ).future);

      if (result) {
        log('[add_phone_number_modal.dart][_savePhoneNumber] Phone number saved successfully');
        widget.trackAction('save_phone_number_success', properties: {
          'phone_number': _phoneNumber.phoneNumber!,
        });
        // Close modal
        if (mounted) Navigator.of(context).pop();
        // Refresh phone numbers list
        ref.invalidate(phoneNumbersProvider);
      } else {
        log('[add_phone_number_modal.dart][_savePhoneNumber] Failed to save phone number');
        widget.trackAction('save_phone_number_failed', properties: {
          'error': 'service_returned_false',
        });
        setState(() {
          _errorMessage = I18nService().t('screen_phone_numbers.save_error', fallback: 'PIN code is incorrect');
        });
      }
    } catch (e) {
      log('[add_phone_number_modal.dart][_savePhoneNumber] Exception saving phone number: $e');
      widget.trackAction('save_phone_number_failed', properties: {
        'error': e.toString(),
      });
      setState(() {
        _errorMessage = I18nService().t('screen_phone_numbers.save_error', fallback: 'PIN code is incorrect - or error occured');
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

// Created: 2024-10-15 (Extracted from phone_numbers.dart for reusability)
