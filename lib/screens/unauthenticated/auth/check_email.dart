import '../../../exports.dart';

class CheckEmailScreen extends UnauthenticatedScreen {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    print('🔍 CheckEmailScreen - Received email: "$email"');
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
                    const CustomText(text: 'Tjek din e-mail', type: CustomTextType.head, alignment: CustomTextAlignment.center),
                    const SizedBox(height: 24),
                    CustomText(
                      text: 'Vi har sendt et login-link til $email.\n\nTjek din indbakke og klik på linket for at fortsætte.',
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
              text: 'Tilbage til login',
              onPressed: () => context.go(RoutePaths.login),
              buttonType: CustomButtonType.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
