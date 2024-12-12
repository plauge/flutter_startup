import '../../exports.dart';
import '../../exports_unauthenticated.dart';

class LoginPage extends UnauthenticatedScreen {
  const LoginPage({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Login'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Gap(AppDimensionsTheme.getMedium(context)),
                  SizedBox(
                    height: 400,
                    child: MagicLinkForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
