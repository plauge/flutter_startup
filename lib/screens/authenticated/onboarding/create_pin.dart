import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import '../../../providers/supabase_service_provider.dart';

class CreatePinScreen extends AuthenticatedScreen {
  CreatePinScreen({super.key});

  static Future<CreatePinScreen> create() async {
    final screen = CreatePinScreen();
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
        final pinController = useTextEditingController();
        final confirmPinController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());

        void showAlert(String message) {
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

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Create PIN Code',
            backRoutePath: RoutePaths.info,
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
                      text: 'Step 1 of 3',
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
                    const CustomText(
                      text: 'Enter PIN Code',
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
                        controller: pinController,
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
                          onPressed: () {
                            final pin = pinController.text;
                            final confirmPin = confirmPinController.text;

                            if (pin.isEmpty || confirmPin.isEmpty) {
                              showAlert('Please enter both PIN codes');
                              return;
                            }

                            if (pin != confirmPin) {
                              showAlert('PIN codes do not match');
                              return;
                            }

                            if (pin.length != 6 || confirmPin.length != 6) {
                              showAlert('PIN codes must be 6 digits');
                              return;
                            }

                            ref
                                .read(supabaseServiceProvider)
                                .setOnboardingPincode(pin);

                            context.go(RoutePaths.personalInfo);
                            // Here you would typically save the PIN to secure storage
                          },
                          text: 'Save PIN Code',
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
