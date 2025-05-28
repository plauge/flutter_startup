import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';

class LoginEmailPasswordScreen extends UnauthenticatedScreen {
  const LoginEmailPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Email & Password Login',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/id-truster-badge.svg',
                height: 150,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: const CustomText(
                text: 'Welcome to ID-Truster',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            const SizedBox(height: 24),

            const EmailPasswordForm(),
            // Gap(AppDimensionsTheme.getLarge(context)),
            // Align(
            //   alignment: Alignment.center,
            //   child: CustomInfoButton(
            //     onPressed: () => context.go(RoutePaths.home),
            //     text: 'View intro vidoe',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 15:30
