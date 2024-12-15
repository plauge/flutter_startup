import '../../exports.dart';

class LoginLandingPage extends AuthenticatedScreen {
  const LoginLandingPage({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState? auth,
  ) {
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
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
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
