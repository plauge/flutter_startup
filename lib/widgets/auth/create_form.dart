import '../../exports.dart';
//import '../../services/auth_service.dart';

class CreateForm extends ConsumerStatefulWidget {
  const CreateForm({super.key});

  @override
  ConsumerState<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends ConsumerState<CreateForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _createUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords matcher ikke')),
      );
      return;
    }

    try {
      final errorMessage = await ref.read(authProvider.notifier).createUser(
            _emailController.text,
            _passwordController.text,
          );

      if (!mounted) return;

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Der skete en fejl: $errorMessage')),
        );
      } else {
        if (!mounted) return;
        context.go('/login_check_email');
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
          controller: _emailController..text = 'lauge+1@pixelhuset.dk',
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        TextField(
          controller: _passwordController..text = '1234567890',
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        TextField(
          controller: _confirmPasswordController..text = '1234567890',
          decoration: const InputDecoration(labelText: 'Bekræft Password'),
          obscureText: true,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        GestureDetector(
          onTap: _createUser,
          child: Container(
            color: AppColors.primaryColor(context),
            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
            child: Text(
              'Opret Bruger',
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
