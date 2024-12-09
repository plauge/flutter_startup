import '../../exports.dart';
import '../../exports_unauthenticated.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/create_form.dart';
import '../../core/widgets/screens/unauthenticated_screen.dart';

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
                  TabBar(
                    tabs: [
                      Tab(text: 'Login'),
                      Tab(text: 'Create'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        LoginForm(),
                        CreateForm(),
                      ],
                    ),
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
