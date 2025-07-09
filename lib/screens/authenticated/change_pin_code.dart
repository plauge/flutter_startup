import '../../exports.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../services/i18n_service.dart';

enum ChangePinStep {
  sendEmail,
  enterEmailPin,
  createNewPin,
  success,
}

class ChangePinCodeScreen extends AuthenticatedScreen {
  ChangePinCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<ChangePinCodeScreen> create() async {
    final screen = ChangePinCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return HookBuilder(
      builder: (context) {
        final currentStep = useState(ChangePinStep.sendEmail);
        final emailPinController = useTextEditingController();
        final newPinController = useTextEditingController();
        final emailPinFocusNode = useFocusNode();
        final newPinFocusNode = useFocusNode();
        final isEmailPinVisible = useState(false);
        final isNewPinVisible = useState(false);
        // Add a key for the new PIN field to force reset when step changes
        final newPinFieldKey = useMemoized(() => ValueKey('newPin_${currentStep.value}'), [currentStep.value]);

        // Clear the new PIN controller when entering step 3
        useEffect(() {
          if (currentStep.value == ChangePinStep.createNewPin) {
            newPinController.clear();
          }
          return null;
        }, [currentStep.value]);

        return Scaffold(
          appBar: AuthenticatedAppBar(
            title: I18nService().t('screen_change_pin_code.title', fallback: 'Change PIN code'),
            backRoutePath: RoutePaths.settings,
          ),
          body: GestureDetector(
            onTap: () {
              // Fjern focus fra alle input felter og luk keyboardet
              FocusScope.of(context).unfocus();
            },
            child: AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildCurrentStep(
                        context,
                        ref,
                        currentStep.value,
                        () => currentStep.value = ChangePinStep.enterEmailPin,
                        () {
                          // Clear the new PIN controller and force widget rebuild
                          newPinController.clear();
                          currentStep.value = ChangePinStep.createNewPin;
                        },
                        () => currentStep.value = ChangePinStep.success,
                        emailPinController,
                        newPinController,
                        emailPinFocusNode,
                        newPinFocusNode,
                        isEmailPinVisible,
                        isNewPinVisible,
                        newPinFieldKey,
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

  Widget _buildCurrentStep(
    BuildContext context,
    WidgetRef ref,
    ChangePinStep currentStep,
    VoidCallback goToStep2,
    VoidCallback goToStep3,
    VoidCallback goToStep4,
    TextEditingController emailPinController,
    TextEditingController newPinController,
    FocusNode emailPinFocusNode,
    FocusNode newPinFocusNode,
    ValueNotifier<bool> isEmailPinVisible,
    ValueNotifier<bool> isNewPinVisible,
    Key newPinFieldKey,
  ) {
    switch (currentStep) {
      case ChangePinStep.sendEmail:
        return _buildStep1(context, ref, goToStep2);
      case ChangePinStep.enterEmailPin:
        return _buildStep2(context, ref, goToStep3, emailPinController, emailPinFocusNode, isEmailPinVisible);
      case ChangePinStep.createNewPin:
        return _buildStep3(context, ref, goToStep4, emailPinController, newPinController, newPinFocusNode, isNewPinVisible, newPinFieldKey);
      case ChangePinStep.success:
        return _buildStep4(context);
    }
  }

  Widget _buildStep1(BuildContext context, WidgetRef ref, VoidCallback goToStep2) {
    final securityPinCodeAsync = ref.watch(securityPinCodeNotifierProvider);

    Future<void> handleSendEmail() async {
      try {
        await ref.read(securityPinCodeNotifierProvider.notifier).sendTemporaryPinCode();
        goToStep2();
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: CustomText(
                text: I18nService().t('screen_change_pin_code.error_title', fallback: 'Error'),
                type: CustomTextType.head,
              ),
              content: CustomText(
                text: 'An error occurred: ${e.toString()}',
                type: CustomTextType.bread,
              ),
              actions: [
                CustomButton(
                  onPressed: () => context.pop(),
                  text: I18nService().t('screen_change_pin_code.error_button', fallback: 'OK'),
                  buttonType: CustomButtonType.secondary,
                ),
              ],
            ),
          );
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step1_title', fallback: 'Change PIN code'),
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step1_description', fallback: 'To change your PIN code, we will send you a temporary PIN code to your email address.'),
          type: CustomTextType.bread,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        securityPinCodeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => CustomButton(
            onPressed: handleSendEmail,
            text: I18nService().t('screen_change_pin_code.step1_button', fallback: 'Change PIN code'),
            buttonType: CustomButtonType.primary,
          ),
          data: (statusCode) => CustomButton(
            onPressed: handleSendEmail,
            text: I18nService().t('screen_change_pin_code.step1_button', fallback: 'Change PIN code'),
            buttonType: CustomButtonType.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(
    BuildContext context,
    WidgetRef ref,
    VoidCallback goToStep3,
    TextEditingController emailPinController,
    FocusNode emailPinFocusNode,
    ValueNotifier<bool> isEmailPinVisible,
  ) {
    void handleNext() {
      final pin = emailPinController.text;
      if (pin.isEmpty) {
        _showAlert(context, I18nService().t('screen_change_pin_code.step2_error_empty', fallback: 'Please enter PIN code from email'));
        return;
      }
      if (pin.length != 6) {
        _showAlert(context, I18nService().t('screen_change_pin_code.step2_error_length', fallback: 'PIN code must be 6 digits'));
        return;
      }
      goToStep3();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step2_title', fallback: 'Insert PIN code from email'),
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: I18nService().t('screen_change_pin_code.step2_subtitle', fallback: 'PIN Code from Email'),
              type: CustomTextType.info,
              alignment: CustomTextAlignment.left,
            ),
            IconButton(
              onPressed: () => isEmailPinVisible.value = !isEmailPinVisible.value,
              icon: Icon(
                isEmailPinVisible.value ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: emailPinController,
            obscureText: !isEmailPinVisible.value,
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
            onCompleted: (_) {},
            onChanged: (_) {},
            focusNode: emailPinFocusNode,
          ),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          onPressed: handleNext,
          text: I18nService().t('screen_change_pin_code.step2_button', fallback: 'Next'),
          buttonType: CustomButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildStep3(
    BuildContext context,
    WidgetRef ref,
    VoidCallback goToStep4,
    TextEditingController emailPinController,
    TextEditingController newPinController,
    FocusNode newPinFocusNode,
    ValueNotifier<bool> isNewPinVisible,
    Key newPinFieldKey,
  ) {
    final securityPinCodeUpdateAsync = ref.watch(securityPinCodeUpdateProvider);

    Future<void> handleUpdatePin() async {
      final newPin = newPinController.text;
      final emailPin = emailPinController.text;

      if (newPin.isEmpty) {
        _showAlert(context, I18nService().t('screen_change_pin_code.step3_error_empty', fallback: 'Please enter new PIN code'));
        return;
      }
      if (newPin.length != 6) {
        _showAlert(context, I18nService().t('screen_change_pin_code.step3_error_length', fallback: 'PIN code must be 6 digits'));
        return;
      }

      try {
        final success = await ref.read(securityPinCodeUpdateProvider.notifier).updatePinCode(
              newPinCode: newPin,
              temporaryPinCode: emailPin,
            );

        if (success) {
          goToStep4();
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(I18nService().t('screen_change_pin_code.step3_error_snackbar', fallback: 'Error in PIN code, please start over')),
                backgroundColor: Colors.red,
              ),
            );
            // Genindlæs siden efter snackbar
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.go(RoutePaths.changePinCode);
              }
            });
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(I18nService().t('screen_change_pin_code.step3_error_snackbar', fallback: 'Error in PIN code, please start over')),
              backgroundColor: Colors.red,
            ),
          );
          // Genindlæs siden efter snackbar
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.go(RoutePaths.changePinCode);
            }
          });
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step3_title', fallback: 'Create new PIN code'),
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: I18nService().t('screen_change_pin_code.step3_subtitle', fallback: 'New PIN Code'),
              type: CustomTextType.info,
              alignment: CustomTextAlignment.left,
            ),
            IconButton(
              onPressed: () => isNewPinVisible.value = !isNewPinVisible.value,
              icon: Icon(
                isNewPinVisible.value ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: newPinController,
            obscureText: !isNewPinVisible.value,
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
            onCompleted: (_) {},
            onChanged: (_) {},
            focusNode: newPinFocusNode,
            key: newPinFieldKey,
          ),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        securityPinCodeUpdateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => CustomButton(
            onPressed: handleUpdatePin,
            text: I18nService().t('screen_change_pin_code.step3_button', fallback: 'Update PIN code'),
            buttonType: CustomButtonType.primary,
          ),
          data: (statusCode) => CustomButton(
            onPressed: handleUpdatePin,
            text: I18nService().t('screen_change_pin_code.step3_button', fallback: 'Update PIN code'),
            buttonType: CustomButtonType.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep4(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step4_title', fallback: 'PIN code updated successfully'),
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        CustomText(
          text: I18nService().t('screen_change_pin_code.step4_description', fallback: 'Your PIN code has been updated successfully. You can now use your new PIN code to access the app.'),
          type: CustomTextType.bread,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          onPressed: () => context.go(RoutePaths.settings),
          text: I18nService().t('screen_change_pin_code.step4_button', fallback: 'Back to Settings'),
          buttonType: CustomButtonType.primary,
        ),
      ],
    );
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_change_pin_code.alert_title', fallback: 'Alert'),
            type: CustomTextType.head,
          ),
          content: CustomText(
            text: message,
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              onPressed: () => context.pop(),
              text: I18nService().t('screen_change_pin_code.alert_button', fallback: 'OK'),
              buttonType: CustomButtonType.secondary,
            ),
          ],
        );
      },
    );
  }
}

// Created: 2024-12-19 17:15:00
