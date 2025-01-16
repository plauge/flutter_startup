import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import '../../../providers/supabase_service_provider.dart';

class OnboardingPINConfirmScreen extends AuthenticatedScreen {
  final String pinToConfirm;

  OnboardingPINConfirmScreen({
    super.key,
    required this.pinToConfirm,
  });

  static Future<OnboardingPINConfirmScreen> create(
      {required String pinToConfirm}) async {
    final screen = OnboardingPINConfirmScreen(pinToConfirm: pinToConfirm);
    return AuthenticatedScreen.create(screen);
  }

  void handleConfirmPinCode(BuildContext context, WidgetRef ref,
      TextEditingController confirmPinController) {
    final confirmPin = confirmPinController.text;

    if (confirmPin.isEmpty) {
      showAlert(context, 'Please enter the PIN code');
      return;
    }

    if (confirmPin.length != 6) {
      showAlert(context, 'PIN code must be 6 digits');
      return;
    }

    if (confirmPin != pinToConfirm) {
      showAlert(context, 'PIN codes do not match');
      return;
    }

    ref.read(supabaseServiceProvider).setOnboardingPincode(confirmPin);
    context.go(RoutePaths.personalInfo);
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
        final confirmPinController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Confirm PIN Code',
            backRoutePath: RoutePaths.createPin,
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
                      text: 'Step 2 of 4',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    const CustomText(
                      text: 'Please confirm your PIN code to proceed.',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.left,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    const CustomText(
                      text: 'Confirm PIN Code',
                      type: CustomTextType.info,
                      alignment: CustomTextAlignment.left,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensionsTheme.getMedium(context)),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: confirmPinController,
                        obscureText: true,
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
                          onPressed: () => handleConfirmPinCode(
                              context, ref, confirmPinController),
                          text: 'Confirm PIN Code',
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
