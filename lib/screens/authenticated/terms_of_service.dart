import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/i18n_service.dart';

class TermsOfServiceScreen extends AuthenticatedScreen {
  TermsOfServiceScreen({super.key}) : super(pin_code_protected: false);

  // Static create method - den eneste måde at instantiere siden
  static Future<TermsOfServiceScreen> create() async {
    final screen = TermsOfServiceScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return _TermsOfServiceContent();
  }
}

class _TermsOfServiceContent extends HookConsumerWidget {
  const _TermsOfServiceContent();

  Future<void> _handleAgreeButtonPress(BuildContext context, WidgetRef ref) async {
    final userExtraNotifier = ref.read(userExtraNotifierProvider.notifier);
    final success = await userExtraNotifier.updateTermsConfirmed();

    if (context.mounted) {
      if (success) {
        context.go(RoutePaths.home);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_error_title', fallback: 'Error'),
              type: CustomTextType.head,
            ),
            content: CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_error_message', fallback: 'Failed to update terms agreement. Please try again.'),
              type: CustomTextType.bread,
            ),
            actions: [
              CustomElevatedButton(
                onPressed: () => Navigator.pop(context),
                text: I18nService().t('screen_terms_of_service.terms_of_service_ok_button', fallback: 'OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: I18nService().t('screen_terms_of_service.terms_of_service_header', fallback: 'Terms of Service Agreement'),
          type: CustomTextType.head,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: CustomText(
              text: '''
1. Introduction
Welcome to our service. By using our service, you agree to these terms.

2. User Responsibilities
You are responsible for maintaining the confidentiality of your account.

3. Privacy Policy
We collect and use your information as described in our Privacy Policy.

4. Service Modifications
We reserve the right to modify or discontinue our service at any time.

5. Termination
We may terminate your access to our service for any reason.

6. Limitation of Liability
We are not liable for any indirect, incidental, or consequential damages.

7. Governing Law
These terms are governed by applicable law.

8. Changes to Terms
We may update these terms at any time.

9. Contact Information
For questions about these terms, please contact us.

10. Acceptance
By using our service, you accept these terms.''',
              type: CustomTextType.bread,
            ),
          ),
        ),
        actions: [
          CustomElevatedButton(
            onPressed: () => Navigator.pop(context),
            text: I18nService().t('screen_terms_of_service.terms_of_service_cancel_button', fallback: 'Close'),
          ),
        ],
      ),
    );
  }

  void _doNothing() {
    // Tom funktion til deaktiveret knap
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAgreed = useState(false);

    return Scaffold(
      appBar: const AuthenticatedAppBar(showSettings: false, title: 'Terms of Service'),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_description', fallback: 'Your Email is confirmed'),
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_description', fallback: 'Before you start using our service, please read and agree to our Terms of Service.'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Row(
              children: [
                Checkbox(
                  value: hasAgreed.value,
                  onChanged: (value) => hasAgreed.value = value ?? false,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTermsOfService(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: I18nService().t('screen_terms_of_service.terms_of_service_button', fallback: 'I have read and agree to the '),
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: I18nService().t('screen_terms_of_service.terms_of_service_button', fallback: 'Terms of Service'),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Center(
              child: Opacity(
                opacity: hasAgreed.value ? 1.0 : 0.5,
                child: CustomButton(
                  onPressed: hasAgreed.value ? () => _handleAgreeButtonPress(context, ref) : _doNothing,
                  text: I18nService().t('screen_terms_of_service.terms_of_service_button', fallback: 'Agree'),
                  buttonType: CustomButtonType.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
