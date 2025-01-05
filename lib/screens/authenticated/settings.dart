import '../../exports.dart';

class SettingsScreen extends AuthenticatedScreen {
  SettingsScreen({super.key});

  static Future<SettingsScreen> create() async {
    final screen = SettingsScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Settings',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              subtitle: const Text('Edit your name, image and other details'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Security Key'),
              subtitle: const Text('Keep your security key safe'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change PIN'),
              subtitle: const Text('Update your PIN code to access the app'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Support & Feedback'),
              subtitle: const Text(
                  'We welcome your feedback. Feel free to reach out to us anytime!'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete My Account'),
              subtitle: const Text(
                  'Deleting your account will remove all your data. You\'ll need to confirm to proceed.'),
              onTap: () {},
            ),
            const Spacer(),
            Text(
              'Secure your app with \'Lock with PIN\' for faster access next time, or log out completely to require your email and password for the next login.',
              style: AppTheme.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: AppTheme.getPrimaryButtonStyle(context),
              child: const Text('Lock with PIN'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
