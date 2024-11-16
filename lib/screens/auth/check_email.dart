import '../../exports.dart';
import '../../exports_unauthenticated.dart';
import '../../widgets/auth/check_email.dart';

class CheckEmailPage extends ConsumerStatefulWidget {
  const CheckEmailPage({super.key});

  @override
  ConsumerState<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends ConsumerState<CheckEmailPage> {
  @override
  Widget build(BuildContext context) {
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
