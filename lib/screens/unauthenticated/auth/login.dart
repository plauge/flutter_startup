import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  void _navigateToResetPassword(BuildContext context) {
    context.go(RoutePaths.resetPassword);
  }

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
                text: 'ID-Truster',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: const CustomText(
                text: 'Vælg adgang',
                type: CustomTextType.cardHead,
                alignment: CustomTextAlignment.center,
              ),
            ),
            // const SizedBox(height: 24),
            // const CustomText(
            //   text: 'Your trusted tool for secure identity verification. With ID-TRUSTER, you can verify identities quickly, reliably, and with complete peace of mind.',
            //   type: CustomTextType.bread,
            //   alignment: CustomTextAlignment.center,
            // ),
            const SizedBox(height: 24),

// her fra
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF005272), width: 1),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  //Center(
                  const CustomText(
                    text: 'Opret bruger eller login,\n\r uden brug af kodeord',
                    type: CustomTextType.label,
                    alignment: CustomTextAlignment.center,
                  ),
                  //),
                  //const SizedBox(height: 24),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    onPressed: () => context.go(RoutePaths.loginMagicLink),
                    text: 'Login (Anbefalet)',
                    buttonType: CustomButtonType.primary,
                  ),
                ],
              ),
            ),
// her til

            Gap(AppDimensionsTheme.getMedium(context)),
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
                    text: 'eller',
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

            Gap(AppDimensionsTheme.getMedium(context)),
            Gap(AppDimensionsTheme.getMedium(context)),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                //color: const Color.fromARGB(255, 241, 241, 241),
                color: Colors.white,
                border: Border.all(color: const Color(0xFF005272), width: 1),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  //Center(
                  const CustomText(
                    text: 'Opret bruger eller login,\n\r hvor du skal bruge kodeord',
                    type: CustomTextType.label,
                    alignment: CustomTextAlignment.center,
                  ),
                  //),
                  //const SizedBox(height: 24),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    onPressed: () => context.go(RoutePaths.loginEmailPassword),
                    text: 'Login med e-mail + kodeord',
                    buttonType: CustomButtonType.secondary,
                  ),
                ],
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Center(
              child: CustomButton(
                onPressed: () => _navigateToResetPassword(context),
                text: 'Glemt kodeord?',
                buttonType: CustomButtonType.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
