import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumbersScreen extends AuthenticatedScreen {
  PhoneNumbersScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneNumbersScreen> create() async {
    final screen = PhoneNumbersScreen();
    return AuthenticatedScreen.create(screen);
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
        onPressed: () => _showAddPhoneNumberModal(context, ref),
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
                                  final shouldDelete = await _showDeleteConfirmationDialog(context, phoneNumber.encryptedPhoneNumber);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddPhoneNumberModal(),
    );
  }

  /// Shows confirmation dialog before deleting phone number
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String phoneNumber) async {
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
              onPressed: () => Navigator.of(context).pop(false),
              child: CustomText(
                text: I18nService().t('button.cancel', fallback: 'Cancel'),
                type: CustomTextType.cardHead,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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
    final log = scopedLogger(LogCategory.gui);
    log('[phone_numbers.dart][_deletePhoneNumber] Deleting phone number: $phoneNumber');

    try {
      final result = await ref.read(deletePhoneNumberProvider(
        inputPhoneNumber: phoneNumber,
      ).future);

      if (result) {
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
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'DK');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              text: I18nService().t('screen_phone_numbers.add_phone_number', fallback: 'Add Phone Number'),
              type: CustomTextType.cardHead,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),

            // Phone number input
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number changed: ${number.phoneNumber}');
                _phoneNumber = number;
              },
              onInputValidated: (bool value) {
                log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number valid: $value');
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
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              inputDecoration: AppTheme.getTextFieldDecoration(context),
              onSaved: (PhoneNumber number) {
                log('[phone_numbers.dart][_AddPhoneNumberModal] Phone number saved: ${number.phoneNumber}');
              },
            ),
            Gap(AppDimensionsTheme.getMedium(context)),

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

            // Save button
            CustomButton(
              text: I18nService().t('button.save', fallback: 'Save'),
              onPressed: _isLoading ? () {} : _savePhoneNumber,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
    );
  }

  /// Save phone number using the provider
  Future<void> _savePhoneNumber() async {
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
      log('[phone_numbers.dart][_savePhoneNumber] Saving phone number: ${_phoneNumber.phoneNumber}');

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
