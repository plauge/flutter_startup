import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 150,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const CustomText(
              text: 'Welcome to Vaka',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            const SizedBox(height: 24),
            const MagicLinkForm(),
            Gap(AppDimensionsTheme.getLarge(context)),
          ],
        ),
      ),
    );
  }
}
