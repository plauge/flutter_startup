import '../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TermsOfServiceScreen extends AuthenticatedScreen {
  TermsOfServiceScreen({super.key});

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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAgreed = useState(false);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Terms of Service'),
      drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service Agreement',
              style: AppTheme.getHeadingLarge(context),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
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
                  style: AppTheme.getBodyMedium(context),
                ),
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Row(
              children: [
                Checkbox(
                  value: hasAgreed.value,
                  onChanged: (value) => hasAgreed.value = value ?? false,
                ),
                Expanded(
                  child: Text(
                    'I have read and agree to the Terms of Service',
                    style: AppTheme.getBodyMedium(context),
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Center(
              child: ElevatedButton(
                onPressed:
                    hasAgreed.value ? () => context.go(RoutePaths.home) : null,
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(
                  'Agree',
                  style: AppTheme.getHeadingLarge(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
