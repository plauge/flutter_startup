import '../exports.dart';

class ProfilePage extends AuthenticatedScreen {
  const ProfilePage({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: AppTheme.getHeadingMedium(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
        body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                  auth.token ?? 'No access token',
                  style: AppTheme.getBodyLarge(context),
                ),
              ],
            ),
          ),
        ));
  }
}
