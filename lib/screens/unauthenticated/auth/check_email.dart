import '../../../exports.dart';

class CheckEmailScreen extends UnauthenticatedScreen {
  const CheckEmailScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const CustomText(
                      text: 'Check your email',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                      selectable: false,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    const CustomText(
                      text:
                          'We have sent you a magic link to your email address. Please check your inbox and click the link to continue.',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                      selectable: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CustomButton(
              text: 'Back to Login',
              onPressed: () => context.go(RoutePaths.login),
              buttonType: CustomButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }
}
