import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../exports.dart';

class LoginLandingPage extends HookWidget {
  const LoginLandingPage({super.key});

  void _showTermsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms & Conditions',
              style: AppTheme.getHeadingMedium(context)),
          content: SingleChildScrollView(
            child: Text(
              'By accepting these terms and conditions, you agree to use our '
              'services in accordance with all applicable laws and regulations. '
              'We reserve the right to modify these terms at any time. '
              'Your continued use of our services constitutes acceptance of '
              'these terms.\n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: AppTheme.getBodyMedium(context)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final termsAccepted = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome', style: AppTheme.getHeadingMedium(context)),
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have been successfully registered!',
              style: AppTheme.getBodyLarge(context),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Row(
              children: [
                Checkbox(
                  value: termsAccepted.value,
                  onChanged: (bool? value) {
                    termsAccepted.value = value ?? false;
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTermsModal(context),
                    child: Text(
                      'Accept terms & conditions',
                      style: AppTheme.getBodyMedium(context)?.copyWith(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            ElevatedButton(
              onPressed: termsAccepted.value
                  ? () => context.go(RoutePaths.home)
                  : null,
              style: AppTheme.getPrimaryButtonStyle(context),
              child: Text(
                'Go to Home',
                style: AppTheme.getHeadingLarge(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
