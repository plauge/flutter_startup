import 'package:flutter/material.dart';
import '../../exports.dart';
import '../../providers/user_extra_provider.dart';

class UserExtraScreen extends AuthenticatedScreen {
  const UserExtraScreen({Key? key}) : super(key: key);

  @override
  Widget buildAuthenticatedWidget(
      BuildContext context, WidgetRef ref, AuthenticatedState state) {
    final userExtraAsyncValue = ref.watch(userExtraProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'User Extra'),
      body: userExtraAsyncValue.when(
        data: (userExtra) => userExtra != null
            ? Text('User Extra: ${userExtra.email}')
            : const Text('No user extra data found'),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => SelectableText.rich(
          TextSpan(
            text: 'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
