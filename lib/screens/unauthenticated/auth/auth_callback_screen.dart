import '../../../exports.dart';

class AuthCallbackScreen extends UnauthenticatedScreen {
  const AuthCallbackScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).location;
    print('Auth Callback Screen - Processing URL: $location');

    // Convert the location to a proper URI and add any missing query parameters
    final uri = Uri.parse('idtruster://$location');
    print('Auth Callback Screen - Converted URI: $uri');

    // Handle the auth callback
    Future(() async {
      try {
        print('Auth Callback Screen - Starting auth callback handling');
        await ref.read(authProvider.notifier).handleAuthRedirect(uri);

        if (context.mounted) {
          print('Auth Callback Screen - Success, navigating to home');
          context.go(RoutePaths.home);
        }
      } catch (e) {
        print('Auth Callback Screen - Error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login fejlede: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
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
