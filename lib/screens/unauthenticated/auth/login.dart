import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/id-truster-badge.svg',
              height: 150,
            ),
            const SizedBox(height: 24),
            const CustomText(
              text: 'Welcome to ID-Truster',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            const SizedBox(height: 24),
            const CustomText(
              text:
                  'Your trusted tool for secure identity verification. With ID-TRUSTER, you can verify identities quickly, reliably, and with complete peace of mind.',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            const SizedBox(height: 24),
            const MagicLinkForm(),
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
