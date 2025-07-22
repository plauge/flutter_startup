import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import '../../../providers/supabase_service_provider.dart';
import '../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class OnboardingPINConfirmScreen extends AuthenticatedScreen {
  final String pinToConfirm;

  OnboardingPINConfirmScreen({
    super.key,
    required this.pinToConfirm,
  }) : super(pin_code_protected: false);

  static Future<OnboardingPINConfirmScreen> create({required String pinToConfirm}) async {
    final screen = OnboardingPINConfirmScreen(pinToConfirm: pinToConfirm);
    return AuthenticatedScreen.create(screen);
  }

  void handleConfirmPinCode(BuildContext context, WidgetRef ref, TextEditingController confirmPinController) {
    final confirmPin = confirmPinController.text;

    if (confirmPin.isEmpty) {
      showAlert(context, I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_missing_pin_code', fallback: 'Please enter the PIN code'));
      return;
    }

    if (confirmPin.length != 6) {
      showAlert(context, I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_incorrect_length', fallback: 'PIN code must be 6 digits'));
      return;
    }

    if (confirmPin != pinToConfirm) {
      showAlert(context, I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_incorrect_pin', fallback: 'PIN codes do not match'));
      return;
    }

    ref.read(supabaseServiceProvider).setOnboardingPincode(confirmPin);
    //context.go(RoutePaths.profileImage);
    context.go(RoutePaths.personalInfo);
  }

  void handleBackStep(BuildContext context) {
    context.go(RoutePaths.createPin);
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_alert_title', fallback: 'Alert'),
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
                I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_ok_button', fallback: 'OK'),
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
        final isPinVisible = useState(false);

        return Scaffold(
          appBar: AuthenticatedAppBar(
            title: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_header', fallback: 'Confirm PIN Code'),
            backRoutePath: RoutePaths.createPin,
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
                            CustomText(
                              text: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_step', fallback: 'Step 2 of 5'),
                              type: CustomTextType.bread,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomText(
                              text: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_header', fallback: 'Confirm PIN Code'),
                              type: CustomTextType.head,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomText(
                              text: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_description', fallback: 'Please re-enter the PIN code to confirm it matches your intended input.'),
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
                                controller: confirmPinController,
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
                      Builder(
                        builder: (context) {
                          final confirmButtons = Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensionsTheme.getMedium(context),
                              vertical: AppDimensionsTheme.getLarge(context),
                            ),
                            child: Column(
                              children: [
                                CustomButton(
                                  key: const Key('onboarding_pin_confirm_button'),
                                  onPressed: () => handleConfirmPinCode(context, ref, confirmPinController),
                                  text: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_button', fallback: 'Confirm PIN Code'),
                                  buttonType: CustomButtonType.primary,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomButton(
                                  key: const Key('onboarding_pin_confirm_back_button'),
                                  onPressed: () => handleBackStep(context),
                                  text: I18nService().t('screen_onboarding_pin_confirm.onboarding_pin_confirm_back_button', fallback: 'Back'),
                                  buttonType: CustomButtonType.secondary,
                                ),
                              ],
                            ),
                          );

                          return Platform.isAndroid ? SafeArea(top: false, child: confirmButtons) : confirmButtons;
                        },
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
