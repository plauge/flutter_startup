import '../../../exports.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../providers/security_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/navigation_state_constants.dart';
import '../../../utils/app_logger.dart';
import '../../../services/i18n_service.dart';

class EnterPincodePage extends AuthenticatedScreen {
  EnterPincodePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.security);

  static Future<EnterPincodePage> create() async {
    AppLogger.log(LogCategory.security, 'Creating EnterPincodePage - lib/screens/authenticated/security/enter_pincode.dart:create()');
    log('Creating EnterPincodePage - lib/screens/authenticated/security/enter_pincode.dart:create()');
    final page = EnterPincodePage();
    return AuthenticatedScreen.create(page);
  }

  void _trackEnterPincodeEvent(WidgetRef ref, String eventType, String action, {Map<String, String>? additionalData}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = {
      'event_type': eventType,
      'action': action,
      'screen': 'enter_pincode',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (additionalData != null) {
      eventData.addAll(additionalData);
    }
    analytics.track('enter_pincode_event', eventData);
  }

  void _handleLogout(WidgetRef ref, BuildContext context) async {
    _trackEnterPincodeEvent(ref, 'authentication', 'logout_button_pressed');
    AppLogger.log(LogCategory.security, 'Logout initiated - lib/screens/authenticated/security/enter_pincode.dart:_handleLogout()');
    log('Logout initiated - lib/screens/authenticated/security/enter_pincode.dart:_handleLogout()');
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      _trackEnterPincodeEvent(ref, 'authentication', 'logout_success');
      log('Navigating to login after logout - lib/screens/authenticated/security/enter_pincode.dart:_handleLogout()');
      context.go(RoutePaths.login);
    }
  }

  void handlePINValidation(BuildContext context, WidgetRef ref, TextEditingController pinController) async {
    _trackEnterPincodeEvent(ref, 'pin_validation', 'pin_entry_completed');
    AppLogger.log(LogCategory.security, 'PIN validation started - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
    log('PIN validation started - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
    final pin = pinController.text;

    if (pin.isEmpty) {
      _trackEnterPincodeEvent(ref, 'pin_validation', 'validation_failed', additionalData: {'error': 'empty_pin'});
      log('PIN validation failed: empty PIN - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
      showAlert(context, I18nService().t('screen_enter_pincode.enter_pincode_missing_pin_code', fallback: 'Please enter PIN code'));
      return;
    }

    if (pin.length != 6) {
      _trackEnterPincodeEvent(ref, 'pin_validation', 'validation_failed', additionalData: {'error': 'invalid_length'});
      log('PIN validation failed: incorrect length - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
      showAlert(context, I18nService().t('screen_enter_pincode.enter_pincode_incorrect_length', fallback: 'PIN code must be 6 digits'));
      return;
    }

    final securityVerification = ref.read(securityVerificationProvider.notifier);
    final isValid = await securityVerification.verifyPincode(pin);

    if (!context.mounted) return;

    if (isValid) {
      _trackEnterPincodeEvent(ref, 'pin_validation', 'validation_success');
      log('PIN validation successful - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
      // Hent den gemte sti og send brugeren tilbage, eller til Home hvis ingen sti er gemt
      final previousRoute = NavigationStateConstants.getPreviousRouteAndClear();
      AppLogger.log(LogCategory.security, 'Previous route: $previousRoute - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
      // Hvis previousRoute er null eller er enterPincode, så send til home
      if (previousRoute == null || previousRoute == RoutePaths.enterPincode) {
        _trackEnterPincodeEvent(ref, 'navigation', 'redirected_to_home');
        log('Navigating to home - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
        context.go(RoutePaths.home);
      } else {
        _trackEnterPincodeEvent(ref, 'navigation', 'redirected_to_previous_route', additionalData: {'route': previousRoute});
        log('Navigating to previous route: $previousRoute - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
        context.go(previousRoute);
      }
    } else {
      _trackEnterPincodeEvent(ref, 'pin_validation', 'validation_failed', additionalData: {'error': 'incorrect_pin'});
      log('PIN validation failed: incorrect PIN - lib/screens/authenticated/security/enter_pincode.dart:handlePINValidation()');
      showAlert(context, I18nService().t('screen_enter_pincode.enter_pincode_incorrect_pin', fallback: 'PIN code is wrong'));
      pinController.clear();
    }
  }

  void showAlert(BuildContext context, String message) {
    AppLogger.log(LogCategory.security, 'Showing alert: $message - lib/screens/authenticated/security/enter_pincode.dart:showAlert()');
    log('Showing alert: $message - lib/screens/authenticated/security/enter_pincode.dart:showAlert()');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            I18nService().t('screen_enter_pincode.enter_pincode_alert_title', fallback: 'Alert'),
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
                I18nService().t('screen_enter_pincode.enter_pincode_ok_button', fallback: 'OK'),
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
    AuthenticatedState auth,
  ) {
    AppLogger.log(LogCategory.security, 'Building EnterPincodePage UI - lib/screens/authenticated/security/enter_pincode.dart:buildAuthenticatedWidget()');
    log('Building EnterPincodePage UI - lib/screens/authenticated/security/enter_pincode.dart:buildAuthenticatedWidget()');

    return HookBuilder(
      builder: (context) {
        final pinController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());
        final isPinVisible = useState(false);
        final pinFocusNode = useFocusNode();

        useEffect(() {
          log('PIN input field focused - lib/screens/authenticated/security/enter_pincode.dart:useEffect()');
          pinFocusNode.requestFocus();
          return null;
        }, []);

        return Scaffold(
          appBar: AuthenticatedAppBar(
            showSettings: false,
            title: I18nService().t('screen_enter_pincode.enter_pincode_header', fallback: 'Enter PIN Code'),
            backRoutePath: RoutePaths.home,
          ),
          body: GestureDetector(
            onTap: () {
              // Fjern focus fra alle input felter og luk keyboardet
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(AppDimensionsTheme.getLarge(context)),
                            SvgPicture.asset(
                              'assets/images/id-truster-badge.svg',
                              height: 100,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomText(
                              text: I18nService().t('screen_enter_pincode.enter_pincode_description', fallback: 'Enter your PIN code to access your account'),
                              type: CustomTextType.head,
                              alignment: CustomTextAlignment.center,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: I18nService().t('screen_enter_pincode.enter_pincode_button', fallback: 'Enter PIN Code'),
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
                                onCompleted: (_) => handlePINValidation(
                                  context,
                                  ref,
                                  pinController,
                                ),
                                onChanged: (_) {},
                                focusNode: pinFocusNode,
                              ),
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomText(
                              text: I18nService().t('screen_enter_pincode.enter_pincode_if_no_activity', fallback: 'If there has been no activity for 5 minutes, you must use your PIN code to unlock.'),
                              type: CustomTextType.bread,
                              alignment: CustomTextAlignment.left,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomButton(
                              key: const Key('enter_pincode_change_pin_button'),
                              text: I18nService().t('screen_enter_pincode.change_pin_code_button', fallback: 'Change PIN code'),
                              onPressed: () {
                                _trackEnterPincodeEvent(ref, 'navigation', 'change_pin_button_pressed');
                                context.go(RoutePaths.changePinCode);
                              },
                              buttonType: CustomButtonType.secondary,
                            ),
                            Gap(AppDimensionsTheme.getLarge(context)),
                            CustomButton(
                              key: const Key('enter_pincode_logout_button'),
                              text: I18nService().t('screen_enter_pincode.enter_pincode_log_out_button', fallback: 'Log out'),
                              onPressed: () => _handleLogout(ref, context),
                              buttonType: CustomButtonType.secondary,
                              icon: Icons.logout,
                            ),
                          ],
                        ),
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
