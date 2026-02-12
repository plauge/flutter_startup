import '../../../exports.dart';

class AuthCallbackScreen extends UnauthenticatedScreen {
  const AuthCallbackScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    AppLogger.logSeparator('AuthCallbackScreen buildUnauthenticatedWidget');
    final log = scopedLogger(LogCategory.other);
    final location = GoRouterState.of(context).location;

    log('Auth Callback Screen - Processing URL: $location');

    // Convert the location to a proper URI and add any missing query parameters
    final uri = Uri.parse('idtruster://$location');
    log('Auth Callback Screen - Converted URI: $uri');

    // Handle the auth callback
    Future(() async {
      try {
        log('Auth Callback Screen - Starting auth callback handling');
        await ref.read(authProvider.notifier).handleAuthRedirect(uri);

        if (context.mounted) {
          log('Auth Callback Screen - Success, navigating to home');
          context.go(RoutePaths.home);
        }
      } catch (e) {
        log('Auth Callback Screen - Error: $e');
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            text: 'Login fejlede: ${e.toString()}',
            variant: CustomSnackBarVariant.error,
          );
          context.go(RoutePaths.login);
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Gap(16),
            Text('Logger ind...'),
          ],
        ),
      ),
    );
  }
}
