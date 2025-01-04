import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 150,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'En eller anden tekst som hjælper brugeren med at forstå hvad der sker',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const MagicLinkForm(),
          ],
        ),
      ),
    );
  }
}
