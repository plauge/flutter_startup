import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: AppTheme.getHeadingMedium(context)),
        elevation: 0,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MagicLinkForm(),
          ],
        ),
      ),
    );
  }
}
