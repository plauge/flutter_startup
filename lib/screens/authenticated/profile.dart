import '../../exports.dart';

class ProfilePage extends AuthenticatedScreen {
  ProfilePage({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<ProfilePage> create() async {
    final screen = ProfilePage();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const AuthenticatedAppBar(title: 'Profile'),
        body: Column(
          children: [
            // TabBar placeres øverst i body
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Security'),
                Tab(text: 'Settings'),
              ],
            ),
            // Expanded for at TabBarView kan fylde resten af pladsen
            Expanded(
              child: TabBarView(
                children: [
                  // Profile tab
                  AppTheme.getParentContainerStyle(context).applyToContainer(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go(RoutePaths.home),
                            style: AppTheme.getPrimaryButtonStyle(context),
                            child: Text(
                              'Go to Home',
                              style: AppTheme.getHeadingLarge(context),
                            ),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Text(
                            'Email',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getSmall(context)),
                          SelectableText(
                            auth.user.email ?? 'No email',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          Text(
                            'JWT Token',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getSmall(context)),
                          SelectableText(
                            auth.token != null
                                ? '${auth.token!.substring(0, 20)}...'
                                : 'No access token',
                            style: AppTheme.getBodyLarge(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Security tab
                  AppTheme.getParentContainerStyle(context).applyToContainer(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Settings',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          ListTile(
                            leading: const Icon(Icons.fingerprint),
                            title: const Text('Biometric Login'),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {
                                // TODO: Implement biometric
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.password),
                            title: const Text('Change Password'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // TODO: Implement password change
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Settings tab
                  AppTheme.getParentContainerStyle(context).applyToContainer(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Settings',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: const Text('Dark Mode'),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {
                                // TODO: Implement theme switching
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('Notifications'),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {
                                // TODO: Implement notifications
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
