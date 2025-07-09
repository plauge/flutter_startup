import '../../exports.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
          appBar: const AuthenticatedAppBar(
            title: 'Change PIN code',
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
              title: const CustomText(
                text: 'Error',
                type: CustomTextType.head,
              ),
              content: CustomText(
                text: 'An error occurred: ${e.toString()}',
                type: CustomTextType.bread,
              ),
              actions: [
                CustomButton(
                  onPressed: () => context.pop(),
                  text: 'OK',
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
        const CustomText(
          text: 'Change PIN code',
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        const CustomText(
          text: 'To change your PIN code, we will send you a temporary PIN code to your email address.',
          type: CustomTextType.bread,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        securityPinCodeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => CustomButton(
            onPressed: handleSendEmail,
            text: 'Change PIN code',
            buttonType: CustomButtonType.primary,
          ),
          data: (statusCode) => CustomButton(
            onPressed: handleSendEmail,
            text: 'Change PIN code',
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
        _showAlert(context, 'Please enter PIN code from email');
        return;
      }
      if (pin.length != 6) {
        _showAlert(context, 'PIN code must be 6 digits');
        return;
      }
      goToStep3();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        const CustomText(
          text: 'Insert PIN code from email',
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText(
              text: 'PIN Code from Email',
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
          text: 'Next',
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
        _showAlert(context, 'Please enter new PIN code');
        return;
      }
      if (newPin.length != 6) {
        _showAlert(context, 'PIN code must be 6 digits');
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
              const SnackBar(
                content: Text('Error in PIN code, please start over'),
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
            const SnackBar(
              content: Text('Error in PIN code'),
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
        const CustomText(
          text: 'Create new PIN code',
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText(
              text: 'New PIN Code',
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
            text: 'Update PIN code',
            buttonType: CustomButtonType.primary,
          ),
          data: (statusCode) => CustomButton(
            onPressed: handleUpdatePin,
            text: 'Update PIN code',
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
        const CustomText(
          text: 'PIN code updated successfully',
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        const CustomText(
          text: 'Your PIN code has been updated successfully. You can now use your new PIN code to access the app.',
          type: CustomTextType.bread,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          onPressed: () => context.go(RoutePaths.settings),
          text: 'Back to Settings',
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
          title: const CustomText(
            text: 'Alert',
            type: CustomTextType.head,
          ),
          content: CustomText(
            text: message,
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              onPressed: () => context.pop(),
              text: 'OK',
              buttonType: CustomButtonType.secondary,
            ),
          ],
        );
      },
    );
  }
}

// Created: 2024-12-19 17:15:00
