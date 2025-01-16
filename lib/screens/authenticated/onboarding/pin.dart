import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class OnboardingPINScreen extends AuthenticatedScreen {
  OnboardingPINScreen({super.key});

  static Future<OnboardingPINScreen> create() async {
    final screen = OnboardingPINScreen();
    return AuthenticatedScreen.create(screen);
  }

  void handleNextStep(BuildContext context, WidgetRef ref,
      TextEditingController pinController) {
    final pin = pinController.text;

    if (pin.isEmpty) {
      showAlert(context, 'Please enter PIN code');
      return;
    }

    if (pin.length != 6) {
      showAlert(context, 'PIN code must be 6 digits');
      return;
    }

    context.go(RoutePaths.confirmPin, extra: pin);
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
          body: AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(AppDimensionsTheme.getLarge(context)),
                    const CustomText(
                      text: 'Step 1 of 4',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    const CustomText(
                      text:
                          'If there has been no activity for 5 minutes, you must use your PIN code to unlock.',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.left,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Enter PIN Code',
                          type: CustomTextType.info,
                          alignment: CustomTextAlignment.left,
                        ),
                        IconButton(
                          onPressed: () =>
                              isPinVisible.value = !isPinVisible.value,
                          icon: Icon(
                            isPinVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensionsTheme.getMedium(context)),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: pinController,
                        obscureText: !isPinVisible.value,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
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
                    Gap(AppDimensionsTheme.getLarge(context)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensionsTheme.getMedium(context)),
                      child: CustomButton(
                          onPressed: () =>
                              handleNextStep(context, ref, pinController),
                          text: 'Next',
                          buttonType: CustomButtonType.primary),
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
