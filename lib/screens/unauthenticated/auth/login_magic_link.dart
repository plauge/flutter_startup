import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';
import '../../../services/i18n_service.dart';

class LoginMagicLinkScreen extends UnauthenticatedScreen {
  const LoginMagicLinkScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_login_magic_link.login_magic_link_header', fallback: 'Link Login'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                // Center(
                //   child: const CustomText(
                //     text: 'Email only login',
                //     type: CustomTextType.head,
                //     alignment: CustomTextAlignment.center,
                //   ),
                // ),

                CustomHelpText(
                  text: I18nService().t('screen_login_magic_link.login_magic_link_description', fallback: 'Enter your email – we will automatically create your account and send you a login link.'),
                  type: CustomTextType.label,
                  alignment: CustomTextAlignment.left,
                ),

                const SizedBox(height: 24),

                const MagicLinkForm(),
                Gap(AppDimensionsTheme.getMedium(context)),

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
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 15:30
