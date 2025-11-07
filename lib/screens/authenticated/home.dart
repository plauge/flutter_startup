import '../../exports.dart';
import '../../widgets/home/home_content_version_1_widget.dart';
import '../../widgets/home/home_content_version_2_widget.dart';
import '../../widgets/home/home_settings_version_1_widget.dart';
import '../../widgets/home/home_settings_version_2_widget.dart';
import '../../providers/home_version_provider.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.gui);

  // Static create method - den eneste måde at instantiere siden
  static Future<HomePage> create() async {
    final page = HomePage();
    //log('HomePage created ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️');
    return AuthenticatedScreen.create(page);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.log(LogCategory.security, 'HomePage buildAuthenticatedWidget');

    final homeVersionAsync = ref.watch(homeVersionProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(showSettings: false),
      resizeToAvoidBottomInset: false,
      //drawer: const MainDrawer(),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: homeVersionAsync.when(
          data: (version) => Container(
            padding: EdgeInsets.only(
              top: 0,
              left: AppDimensionsTheme.getParentContainerPadding(context),
              right: AppDimensionsTheme.getParentContainerPadding(context),
              bottom: AppDimensionsTheme.getParentContainerPadding(context),
            ),
            decoration: AppTheme.getParentContainerDecoration(context),
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 1200,
              minHeight: 100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: version == 1 ? const HomeContentVersion1Widget() : const HomeContentVersion2Widget(),
                  ),
                ),
                version == 1 ? const HomeSettingsVersion1Widget() : const HomeSettingsVersion2Widget(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Center(
              child: CustomText(
                text: I18nService().t(
                  'screen_home.error_loading_version',
                  fallback: 'Error loading version: $error',
                  variables: {'error 2': error.toString()},
                ),
                type: CustomTextType.info,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
