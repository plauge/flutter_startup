import '../../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io' show Platform;

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  void _onForgotPasswordPressed(BuildContext context) {
    context.go(RoutePaths.forgotPassword);
  }

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: DefaultTabController(
            length: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              'assets/images/id-truster-badge.svg',
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: const CustomText(
                              text: 'ID-Truster',
                              type: CustomTextType.helper,
                              alignment: CustomTextAlignment.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Platform.isAndroid ? const AndroidWidget() : const IOSWidget(),
                          const SizedBox(height: 24),
                          LoginCreateAccountTabs(
                            onForgotPassword: () => _onForgotPasswordPressed(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

