import '../exports.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //final _supabaseService = SupabaseService();

  Future<void> _login() async {
    try {
      // final errorMessage = await _supabaseService.login(
      //   _emailController.text,
      //   _passwordController.text,
      // );

      // Brug authProvider til at udføre login
      final errorMessage = await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );

      if (!mounted) return;

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        // Opdater auth state
        ref.read(authProvider.notifier).state = true;

        if (!mounted) return;
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Der skete en fejl: ${e.toString()}')),
      );
    }
  }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController
                    ..text = 'ingelaugehansen@gmail.com',
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                TextField(
                  controller: _passwordController..text = '123456',
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    color: AppColors.primaryColor(context),
                    padding:
                        EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                    child: Text(
                      'Login',
                      style: AppTheme.getHeadingLarge(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
