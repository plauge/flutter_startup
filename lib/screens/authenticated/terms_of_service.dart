import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/i18n_service.dart';
import '../../core/widgets/screens/authenticated_screen_helpers/generate_and_persist_user_token.dart';

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
    await generateAndPersistUserToken(ref);

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

  void _showTermsOfService(BuildContext context, WidgetRef ref, AsyncValue<SecurityAppStatusResponse> appStatusAsync) {
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
            child: appStatusAsync.when(
              data: (response) => CustomText(
                text: response.data.payload.terms,
                type: CustomTextType.bread,
              ),
              loading: () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomText(
                    text: I18nService().t('screen_terms_of_service.terms_of_service_loading_text', fallback: 'Loading Terms of Service...'),
                    type: CustomTextType.bread,
                  ),
                ],
              ),
              error: (error, stack) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: I18nService().t('screen_terms_of_service.terms_of_service_error_loading', fallback: 'Failed to load Terms of Service. Please try again later.'),
                    type: CustomTextType.bread,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  CustomText(
                    text: "Error: $error",
                    type: CustomTextType.bread,
                  ),
                ],
              ),
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
    final appStatusAsync = ref.watch(securityAppStatusProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        showSettings: false,
        title: I18nService().t('screen_terms_of_service.terms_of_service_link_text', fallback: 'Terms of Service'),
      ),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_header', fallback: 'Your Email is confirmed'),
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_terms_of_service.terms_of_service_description', fallback: 'Before you start using our service, please read and agree to our Terms of Service.'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Row(
              children: [
                GestureDetector(
                  onTap: () => hasAgreed.value = !hasAgreed.value,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasAgreed.value ? Theme.of(context).primaryColor : Colors.grey,
                        width: 2,
                      ),
                      color: hasAgreed.value ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: hasAgreed.value
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTermsOfService(context, ref, appStatusAsync),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: I18nService().t('screen_terms_of_service.terms_of_service_pre_text', fallback: 'I have read and agree to the '),
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: I18nService().t('screen_terms_of_service.terms_of_service_link_text', fallback: 'Terms of Service'),
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
