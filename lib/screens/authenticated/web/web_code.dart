import '../../../exports.dart';
import '../../../widgets/web/web_code_text.dart';
import '../../../widgets/web/web_domain_search.dart';

class WebCodeScreen extends AuthenticatedScreen {
  WebCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<WebCodeScreen> create() async {
    final screen = WebCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Web Code',
        backRoutePath: RoutePaths.home,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap(AppDimensionsTheme.getLarge(context)),
                    //const WebCodeText(),
                    const WebDomainSearch(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Created: 2023-08-08 16:10:00
