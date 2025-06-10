import '../../exports.dart';
import 'dart:io' show Platform;

class MagicLinkForm extends ConsumerStatefulWidget {
  const MagicLinkForm({super.key});
  @override
  ConsumerState<MagicLinkForm> createState() => _MagicLinkFormState();
}

class _MagicLinkFormState extends ConsumerState<MagicLinkForm> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isDebugMode {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

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
        final emailToSend = _emailController.text;
        print('🔍 MagicLinkForm - Navigating to CheckEmailScreen with email: $emailToSend');
        context.go(RoutePaths.checkEmail, extra: emailToSend);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextFormField(
          //   controller: _emailController
          //     ..text = _isDebugMode ? 'lauge+1@pixelhuset.dk' : '',
          //   decoration: AppTheme.getTextFieldDecoration(
          //     context,
          //     //labelText: 'Email',
          //   ),
          //   keyboardType: TextInputType.emailAddress,
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter your email';
          //     }
          //     if (!value.contains('@') || !value.contains('.')) {
          //       return 'Please enter a valid email';
          //     }
          //     return null;
          //   },
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          // ),
          const CustomText(
            text: 'Email',
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            controller: _emailController..text = _isDebugMode ? 'lauge+1@pixelhuset.dk' : '',
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
            text: 'Send login-link',
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
