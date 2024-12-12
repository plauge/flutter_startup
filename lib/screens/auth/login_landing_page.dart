import '../../exports.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/router/app_router.dart';
// import '../../core/widgets/screens/authenticated_screen.dart';
// import '../../core/auth/auth_state.dart';

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
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have been successfully registered!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
