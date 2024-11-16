import '../../exports.dart';
import '../../exports_unauthenticated.dart';
import '../../widgets/auth/check_email.dart';
import '../../core/widgets/screens/unauthenticated_screen.dart';

class CheckEmailPage extends UnauthenticatedScreen {
  const CheckEmailPage({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Check Email'),
        elevation: 0,
      ),
      body: const CheckEmail(),
    );
  }
}
