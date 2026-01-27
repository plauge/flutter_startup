import '../../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/i18n_service.dart';
import '../../../core/constants/app_version_constants.dart';
import '../../../widgets/auth/login_pin_form.dart';
import '../../../widgets/auth/login_pin_form_v_2.dart';
import 'dart:io' show Platform;

final _loginPinStepProvider = StateProvider<LoginPinStep?>((ref) => null);
final _loginPinStepV2Provider = StateProvider<LoginPinStepV2?>((ref) => null);
final _loginPinBackCallbackProvider = StateProvider<VoidCallback?>((ref) => null);

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  void _onForgotPasswordPressed(BuildContext context) {
    context.go(RoutePaths.forgotPassword);
  }

  Widget _buildMagicLinkContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            I18nService().t('screen_login.login_description', fallback: 'Create account or login without password (recommended)'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF014459),
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            key: const Key('login_main_button'),
            onPressed: () => context.go(RoutePaths.loginMagicLink),
            text: I18nService().t('screen_login.login_button', fallback: 'Login'),
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            I18nService().t('screen_login.login_description_with_password', fallback: 'Create user or login, where you need to use a password'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF014459),
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            key: const Key('login_with_password_button'),
            onPressed: () => context.go(RoutePaths.loginEmailPassword),
            text: I18nService().t('screen_login.login_button_with_password', fallback: 'Login with email + password'),
            buttonType: CustomButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final appStatusAsync = ref.watch(securityAppStatusProvider);

    // NOTE: Login option order swapping for Apple Store review
    // We swap the order of magic link and password login options based on app version
    // compared to minimumRequiredVersion from Supabase. When appVersionInt > minimumRequiredVersion,
    // password login is shown first (on top) to potentially speed up Apple Store review process.
    // This will remain until minimumRequiredVersion is updated in Supabase to match or exceed appVersionInt.
    return Builder(
      builder: (context) {
        final appStatus = appStatusAsync.value;
        if (appStatus == null) {
          return const SizedBox.shrink();
        }
        final appVersionInt = AppVersionConstants.appVersionInt;
        final minimumRequiredVersion = appStatus.data.payload.minimumRequiredVersion;
        final phoneIphoneStatus = appStatus.data.payload.phoneIphone;
        final phoneAndroidStatus = appStatus.data.payload.phoneAndroid;
        final phoneStatus = Platform.isAndroid ? phoneAndroidStatus : phoneIphoneStatus;
        final shouldSwapOrder = appVersionInt > minimumRequiredVersion;
        final appFeatureFlag1 = appStatus.data.payload.appFeatureFlag1;

        if (shouldSwapOrder && phoneStatus == 'production_fallback') {
          return Column(
            children: [
              Center(
                child: const CustomText(
                  text: 'ID-Truster',
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16.0 : 24.0),
              Center(
                child: CustomText(
                  text: I18nService().t('screen_login.login_header', fallback: 'Select access'),
                  type: CustomTextType.cardHead,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16.0 : 24.0),
              _buildPasswordContainer(context),
              Gap(AppDimensionsTheme.getMedium(context)),
              Gap(AppDimensionsTheme.getMedium(context)),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getSmall(context)),
                    child: CustomText(
                      text: I18nService().t('screen_login.login_or', fallback: 'or'),
                      type: CustomTextType.label,
                      alignment: CustomTextAlignment.center,
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              Gap(AppDimensionsTheme.getMedium(context)),
              _buildMagicLinkContainer(context)
            ],
          );
        } else if (shouldSwapOrder && phoneStatus == 'in_review') {
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Center(
                  child: const CustomText(
                    text: 'ID-Truster',
                    type: CustomTextType.helper,
                    alignment: CustomTextAlignment.center,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                LoginCreateAccountTabs(
                  onForgotPassword: () => _onForgotPasswordPressed(context),
                ),
              ],
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appFeatureFlag1
                  ? LoginPinFormV2(
                      onStepChanged: (step) {
                        ref.read(_loginPinStepV2Provider.notifier).state = step;
                      },
                      onBackCallbackReady: (callback) {
                        ref.read(_loginPinBackCallbackProvider.notifier).state = callback;
                      },
                    )
                  : LoginPinForm(
                      onStepChanged: (step) {
                        ref.read(_loginPinStepProvider.notifier).state = step;
                      },
                      onBackCallbackReady: (callback) {
                        ref.read(_loginPinBackCallbackProvider.notifier).state = callback;
                      },
                    ),
            ],
          );
        }
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(_loginPinStepProvider);
    final currentStepV2 = ref.watch(_loginPinStepV2Provider);
    final backCallback = ref.read(_loginPinBackCallbackProvider);

    // Only show AppBar when LoginPinForm or LoginPinFormV2 is displayed
    if (currentStep == null && currentStepV2 == null) {
      return null;
    }

    // Handle LoginPinForm (V1)
    if (currentStep != null) {
      // Step 1: No back button
      if (currentStep == LoginPinStep.emailInput) {
        return const AuthenticatedAppBar();
      }

      // Step 2: Back button that goes back to step 1
      if (currentStep == LoginPinStep.pinInput) {
        return AuthenticatedAppBar(
          backRoutePath: RoutePaths.login,
          onBeforeBack: backCallback != null
              ? () async {
                  backCallback();
                }
              : null,
        );
      }
    }

    // Handle LoginPinFormV2
    if (currentStepV2 != null) {
      // Step 1: No back button
      if (currentStepV2 == LoginPinStepV2.emailInput) {
        return const AuthenticatedAppBar();
      }

      // Step 2: Back button that goes back to step 1
      if (currentStepV2 == LoginPinStepV2.pinInput) {
        return AuthenticatedAppBar(
          backRoutePath: RoutePaths.login,
          onBeforeBack: backCallback != null
              ? () async {
                  backCallback();
                }
              : null,
        );
      }
    }

    return null;
  }

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    final isSmallScreen = AppDimensionsTheme.isSmallScreen(context);
    final appBar = _buildAppBar(context, ref);

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensionsTheme.getMedium(context),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).viewInsets.top - 
                           MediaQuery.of(context).viewInsets.bottom -
                           (appBar?.preferredSize.height ?? 0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSmallScreen) Gap(AppDimensionsTheme.getLarge(context)),
                  if (!isSmallScreen) Gap(AppDimensionsTheme.getLarge(context)),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/id-truster-badge.svg',
                      height: isSmallScreen ? 100.0 : 125.0,
                    ),
                  ),
                  Gap(isSmallScreen ? AppDimensionsTheme.getMedium(context) : AppDimensionsTheme.getLarge(context)),
                  _buildLoginContent(context, ref, isSmallScreen),
                  Gap(AppDimensionsTheme.getLarge(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// File created: 2025-01-27
