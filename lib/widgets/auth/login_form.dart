import '../../exports.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController..text = 'ingelaugehansen@gmail.com',
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
            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
            child: Text(
              'Login du',
              style: AppTheme.getHeadingLarge(context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
