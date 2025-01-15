import '../../exports.dart';

class MagicLinkForm extends ConsumerStatefulWidget {
  const MagicLinkForm({super.key});
  @override
  ConsumerState<MagicLinkForm> createState() => _MagicLinkFormState();
}

class _MagicLinkFormState extends ConsumerState<MagicLinkForm> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

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
        context.go(RoutePaths.checkEmail);
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _emailController..text = 'lauge+1@pixelhuset.dk',
            decoration: AppTheme.getTextFieldDecoration(
              context,
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            onPressed: _sendMagicLink,
            text: 'Access',
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
