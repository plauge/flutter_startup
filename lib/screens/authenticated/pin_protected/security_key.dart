import '../../../exports.dart';
import 'package:flutter/services.dart';

class SecurityKeyScreen extends AuthenticatedScreen {
  SecurityKeyScreen({super.key}) : super(pin_code_protected: true, face_id_protected: true);

  static Future<SecurityKeyScreen> create() async {
    final screen = SecurityKeyScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackSecurityKeyEvent(WidgetRef ref, String eventType, String action, {Map<String, String>? additionalData}) {
    final analytics = ref.read(analyticsServiceProvider);
    final eventData = {
      'event_type': eventType,
      'action': action,
      'screen': 'security_key',
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (additionalData != null) {
      eventData.addAll(additionalData);
    }
    analytics.track('security_key_event', eventData);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    Future<void> handleCopySecurityKey() async {
      _trackSecurityKeyEvent(ref, 'security_key_action', 'copy_button_pressed');
      try {
        final storageData = await ref.read(storageProvider.notifier).getUserStorageDataByEmail(state.user.email!);
        if (storageData == null) {
          _trackSecurityKeyEvent(ref, 'security_key_action', 'copy_failed', additionalData: {'error': 'no_storage_data'});
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const CustomText(
                  text: 'No Security Key Found',
                  type: CustomTextType.head,
                ),
                content: const CustomText(
                  text: 'Could not find your security key. Please try again later.',
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

//         final securityInfo = '''
// Token: ${storageData.token}
// Test Key: ${storageData.testkey}''';

        final securityInfo = storageData.token;

        await Clipboard.setData(ClipboardData(text: securityInfo));
        _trackSecurityKeyEvent(ref, 'security_key_action', 'copy_success');

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText(
                text: 'Security Key Copied',
                type: CustomTextType.head,
              ),
              content: const CustomText(
                text: 'Your security key has been copied to clipboard. Please store it in a safe place.',
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
        _trackSecurityKeyEvent(ref, 'security_key_action', 'copy_failed', additionalData: {'error': e.toString()});
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
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                      key: const Key('security_key_copy_button'),
                      onPressed: handleCopySecurityKey,
                      text: 'Copy Security Key',
                      buttonType: CustomButtonType.primary,
                    ),
                  ],
                ),
              ),
            ),
            // Builder(
            //   builder: (context) {
            //     final readAboutButton = Padding(
            //       padding: const EdgeInsets.only(bottom: 20),
            //       child: CustomButton(
            //         key: const Key('security_key_read_about_button'),
            //         onPressed: () {
            //           _trackSecurityKeyEvent(ref, 'navigation', 'read_about_pressed');
            //           // Read about functionality will be added later
            //         },
            //         text: 'Read About Security Keys',
            //         buttonType: CustomButtonType.secondary,
            //         icon: Icons.info_outline,
            //       ),
            //     );

            //     return Platform.isAndroid ? SafeArea(top: false, child: readAboutButton) : readAboutButton;
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
