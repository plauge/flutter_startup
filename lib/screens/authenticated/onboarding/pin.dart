import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class OnboardingPINScreen extends AuthenticatedScreen {
  OnboardingPINScreen({super.key}) : super(pin_code_protected: false);

  static Future<OnboardingPINScreen> create() async {
    final screen = OnboardingPINScreen();
    return AuthenticatedScreen.create(screen);
  }

  void handleNextStep(BuildContext context, WidgetRef ref, TextEditingController pinController) {
    final pin = pinController.text;

    if (pin.isEmpty) {
      showAlert(context, 'Please enter PIN code');
      return;
    }

    if (pin.length != 6) {
      showAlert(context, 'PIN code must be 6 digits');
      return;
    }

    context.pushNamed('confirm-pin', extra: pin);
  }

  void handleBackStep(BuildContext context) {
    context.go(RoutePaths.onboardingBegin);
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert',
            style: AppTheme.getBodyLarge(context),
          ),
          content: Text(
            message,
            style: AppTheme.getBodyMedium(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return HookBuilder(
      builder: (context) {
        final pinController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());
        final isPinVisible = useState(false);

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Create PIN Code',
            backRoutePath: RoutePaths.onboardingBegin,
          ),
          body: GestureDetector(
            onTap: () {
              // Fjern focus fra alle input felter og luk keyboardet
              FocusScope.of(context).unfocus();
            },
            child: AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(AppDimensionsTheme.getLarge(context)),
                            const CustomText(
                              text: 'Step 1 of 5',
                              type: CustomTextType.bread,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            const CustomText(
                              text: 'Create Your PIN Code',
                              type: CustomTextType.head,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            const CustomText(
                              text: 'If the app is inactive for 5 minutes, you will need to use this PIN code to access your contacts.',
                              type: CustomTextType.bread,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CustomText(
                                  text: '',
                                  type: CustomTextType.info,
                                  alignment: CustomTextAlignment.left,
                                ),
                                IconButton(
                                  onPressed: () => isPinVisible.value = !isPinVisible.value,
                                  icon: Icon(
                                    isPinVisible.value ? Icons.visibility_off : Icons.visibility,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Gap(AppDimensionsTheme.getMedium(context)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getMedium(context)),
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: pinController,
                                obscureText: !isPinVisible.value,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Skjul knapperne når keyboardet er åbent
                    if (MediaQuery.of(context).viewInsets.bottom == 0)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensionsTheme.getMedium(context),
                          vertical: AppDimensionsTheme.getLarge(context),
                        ),
                        child: Column(
                          children: [
                            CustomButton(
                              onPressed: () => handleNextStep(context, ref, pinController),
                              text: 'Next',
                              buttonType: CustomButtonType.primary,
                            ),
                            Gap(AppDimensionsTheme.getMedium(context)),
                            CustomButton(
                              onPressed: () => handleBackStep(context),
                              text: 'Back',
                              buttonType: CustomButtonType.secondary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
