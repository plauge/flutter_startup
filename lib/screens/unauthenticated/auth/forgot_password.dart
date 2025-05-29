import '../../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordScreen extends UnauthenticatedScreen {
  const ForgotPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Forgot password',
        backRoutePath: RoutePaths.loginEmailPassword,
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/id-truster-badge.svg',
                height: 150,
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Center(
              child: const CustomText(
                text: 'Forgot password',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            Center(
              child: const CustomText(
                text: 'Enter your email address and we\'ll send you a link to reset your password',
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ForgotPasswordForm(),
            ),
          ],
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 17:15
