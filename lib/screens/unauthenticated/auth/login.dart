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
            const CustomText(
              text: 'Your trusted tool for secure identity verification. With ID-TRUSTER, you can verify identities quickly, reliably, and with complete peace of mind.',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            const SizedBox(height: 24),

            Center(
              child: const CustomText(
                text: 'Chose login method',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            const SizedBox(height: 24),
            const CustomText(
              text: 'Magic Link',
              type: CustomTextType.label,
              alignment: CustomTextAlignment.center,
            ),
            const CustomText(
              text: 'Recormend - fast and secure',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
            ),

            CustomButton(
              onPressed: () => context.go(RoutePaths.loginMagicLink),
              text: 'Login with Magic Link',
              buttonType: CustomButtonType.primary,
            ),

            Gap(AppDimensionsTheme.getMedium(context)),
            Row(
              children: [
                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getSmall(context)),
                  child: const CustomText(
                    text: 'or',
                    type: CustomTextType.label,
                    alignment: CustomTextAlignment.center,
                  ),
                ),
                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const CustomText(
              text: 'Standard Login',
              type: CustomTextType.label,
              alignment: CustomTextAlignment.center,
            ),
            const CustomText(
              text: 'Less secure',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            CustomButton(
              onPressed: () => context.go(RoutePaths.loginEmailPassword),
              text: 'Login with Email & Password',
              buttonType: CustomButtonType.primary,
            ),
            Gap(AppDimensionsTheme.getSmall(context)),
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
