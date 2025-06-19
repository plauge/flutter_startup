import '../../../exports.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../providers/security_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/navigation_state_constants.dart';

class EnterPincodePage extends AuthenticatedScreen {
  EnterPincodePage({super.key}) : super(pin_code_protected: false);

  static Future<EnterPincodePage> create() async {
    final page = EnterPincodePage();
    return AuthenticatedScreen.create(page);
  }

  void _handleLogout(WidgetRef ref, BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }

  void handlePINValidation(BuildContext context, WidgetRef ref, TextEditingController pinController) async {
    final pin = pinController.text;

    if (pin.isEmpty) {
      showAlert(context, 'Please enter PIN code');
      return;
    }

    if (pin.length != 6) {
      showAlert(context, 'PIN code must be 6 digits');
      return;
    }

    final securityVerification = ref.read(securityVerificationProvider.notifier);
    final isValid = await securityVerification.verifyPincode(pin);

    if (!context.mounted) return;

    if (isValid) {
      // Hent den gemte sti og send brugeren tilbage, eller til Home hvis ingen sti er gemt
      final previousRoute = NavigationStateConstants.getPreviousRouteAndClear();
      context.go(previousRoute ?? RoutePaths.home);
    } else {
      showAlert(context, 'PIN code is wrong');
      pinController.clear();
    }
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
    AuthenticatedState auth,
  ) {
    return HookBuilder(
      builder: (context) {
        final pinController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());
        final isPinVisible = useState(false);
        final pinFocusNode = useFocusNode();

        useEffect(() {
          pinFocusNode.requestFocus();
          return null;
        }, []);

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            showSettings: false,
            title: 'Enter PIN Code',
            backRoutePath: RoutePaths.home,
          ),
          body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                          const CustomText(
                            text: 'Indtast PIN-kode',
                            type: CustomTextType.head,
                            alignment: CustomTextAlignment.center,
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
                          const CustomText(
                            text: 'If there has been no activity for 5 minutes, you must use your PIN code to unlock.',
                            type: CustomTextType.bread,
                            alignment: CustomTextAlignment.left,
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          CustomButton(
                            text: 'Log ud',
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
        );
      },
    );
  }
}
