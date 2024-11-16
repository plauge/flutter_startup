import '../../exports.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/create_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
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
                  TabBar(
                    tabs: [
                      Tab(text: 'Login'),
                      Tab(text: 'Create'),
                    ],
                  ),
                  SizedBox(
                    height: 400, // Adjust height as needed
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
