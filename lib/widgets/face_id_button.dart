import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

class FaceIdButton extends ConsumerWidget {
  const FaceIdButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => _authenticateWithFaceId(context, ref),
          icon: const Icon(Icons.face),
          label: const Text('Godkend med Face ID'),
        ),
      ],
    );
  }

  Future<void> _authenticateWithFaceId(
      BuildContext context, WidgetRef ref) async {
    final LocalAuthentication auth = ref.read(localAuthProvider);
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (context.mounted) {
          _showMessage(context, 'Enheden understøtter ikke Face ID');
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Godkend venligst med Face ID',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (context.mounted) {
        _showMessage(
          context,
          didAuthenticate ? 'Godkendt' : 'Fejl ved godkendelse',
        );
      }
    } catch (e) {
      if (context.mounted) {
        //_showMessage(context, 'Fejl: ${e.toString()}');
        _showMessage(context, 'Fejl');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message.contains('Godkendt') ? Colors.green : Colors.red,
      ),
    );
  }
}
