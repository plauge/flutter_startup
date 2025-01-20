import '../../exports.dart';
import 'package:flutter/services.dart';

class SecurityKeyScreen extends AuthenticatedScreen {
  SecurityKeyScreen();

  static Future<SecurityKeyScreen> create() async {
    final screen = SecurityKeyScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    Future<void> handleCopySecurityKey() async {
      try {
        final storageData = await ref
            .read(storageProvider.notifier)
            .getUserStorageDataByEmail(state.user.email!);
        if (storageData == null) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const CustomText(
                  text: 'No Security Key Found',
                  type: CustomTextType.head,
                ),
                content: const CustomText(
                  text:
                      'Could not find your security key. Please try again later.',
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
          return;
        }

        final securityInfo = '''
Token: ${storageData.token}
Test Key: ${storageData.testkey}''';

        await Clipboard.setData(ClipboardData(text: securityInfo));

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText(
                text: 'Security Key Copied',
                type: CustomTextType.head,
              ),
              content: const CustomText(
                text:
                    'Your security key has been copied to clipboard. Please store it in a safe place.',
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
        title: 'Security Key',
        backRoutePath: RoutePaths.settings,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Keep your key in\na safe place',
                type: CustomTextType.head,
              ),
              const Gap(16),
              CustomText(
                text: 'Click the button to copy your Security Key',
                type: CustomTextType.bread,
              ),
              const Gap(24),
              CustomButton(
                onPressed: handleCopySecurityKey,
                text: 'Copy Security Key',
                buttonType: CustomButtonType.primary,
              ),
              const Gap(24),
              CustomButton(
                onPressed: () {
                  // Read about functionality will be added later
                },
                text: 'Read About Security Keys',
                buttonType: CustomButtonType.secondary,
                icon: Icons.info_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
