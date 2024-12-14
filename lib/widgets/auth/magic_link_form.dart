import '../../exports.dart';

class MagicLinkForm extends ConsumerStatefulWidget {
  const MagicLinkForm({super.key});
  @override
  ConsumerState<MagicLinkForm> createState() => _MagicLinkFormState();
}

class _MagicLinkFormState extends ConsumerState<MagicLinkForm> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendMagicLink() async {
    try {
      final errorMessage = await ref.read(authProvider.notifier).sendMagicLink(
            _emailController.text,
          );
      if (!mounted) return;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        if (!mounted) return;
        context.go('/check-email');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: AppTheme.getTextFieldDecoration(
            context,
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        ElevatedButton(
          onPressed: _sendMagicLink,
          style: AppTheme.getPrimaryButtonStyle(context),
          child: Text(
            'Login',
            style: AppTheme.getHeadingLarge(context),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
