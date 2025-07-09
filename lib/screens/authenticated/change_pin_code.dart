import '../../exports.dart';

class ChangePinCodeScreen extends AuthenticatedScreen {
  ChangePinCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<ChangePinCodeScreen> create() async {
    final screen = ChangePinCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final securityPinCodeAsync = ref.watch(securityPinCodeNotifierProvider);

    Future<void> handleChangePinCode() async {
      try {
        await ref.read(securityPinCodeNotifierProvider.notifier).sendTemporaryPinCode();

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText(
                text: 'Check your email',
                type: CustomTextType.head,
              ),
              content: const CustomText(
                text: 'We have sent you instructions to change your PIN code. Please check your email.',
                type: CustomTextType.bread,
              ),
              actions: [
                CustomButton(
                  onPressed: () => context.pop(),
                  text: 'OK',
                  buttonType: CustomButtonType.secondary,
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText(
                text: 'Error',
                type: CustomTextType.head,
              ),
              content: CustomText(
                text: 'An error occurred: ${e.toString()}',
                type: CustomTextType.bread,
              ),
              actions: [
                CustomButton(
                  onPressed: () => context.pop(),
                  text: 'OK',
                  buttonType: CustomButtonType.secondary,
                ),
              ],
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Change PIN code',
        backRoutePath: RoutePaths.settings,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                      const CustomText(
                        text: 'Change PIN code',
                        type: CustomTextType.head,
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      const CustomText(
                        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        type: CustomTextType.bread,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      securityPinCodeAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => CustomButton(
                          onPressed: handleChangePinCode,
                          text: 'Change PIN code',
                          buttonType: CustomButtonType.primary,
                        ),
                        data: (statusCode) => CustomButton(
                          onPressed: handleChangePinCode,
                          text: 'Change PIN code',
                          buttonType: CustomButtonType.primary,
                        ),
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
  }
}

// Created: 2024-12-19 17:15:00
