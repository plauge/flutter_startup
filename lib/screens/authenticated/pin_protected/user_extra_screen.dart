import 'package:flutter/material.dart';
import '../../../exports.dart';
import '../../../providers/user_extra_provider.dart';

class UserExtraScreen extends AuthenticatedScreen {
  UserExtraScreen({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<UserExtraScreen> create() async {
    final screen = UserExtraScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
      BuildContext context, WidgetRef ref, AuthenticatedState state) {
    final userExtraAsyncValue = ref.watch(userExtraNotifierProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'User Extra'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: userExtraAsyncValue.when(
          data: (userExtra) => userExtra != null
              ? Text(
                  'User Extra: ${userExtra.email}',
                  style: AppTheme.getBodyMedium(context),
                )
              : Text(
                  'No user extra data found',
                  style: AppTheme.getBodyMedium(context),
                ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => SelectableText.rich(
            TextSpan(
              text: 'Error: $error',
              style:
                  AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
