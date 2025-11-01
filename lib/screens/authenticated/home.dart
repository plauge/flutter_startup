import '../../exports.dart';
import '../../widgets/home/home_content_version_1_widget.dart';
import '../../widgets/home/home_content_version_2_widget.dart';
import '../../widgets/home/home_settings_version_1_widget.dart';
import '../../widgets/home/home_settings_version_2_widget.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.gui);

  // Change this value to switch between versions (1 or 2)
  static const int _homeVersion = 1;

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

    return Scaffold(
      appBar: const AuthenticatedAppBar(showSettings: false),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _homeVersion == 1 ? const HomeContentVersion1Widget() : const HomeContentVersion2Widget(),
              ),
            ),
            _homeVersion == 1 ? const HomeSettingsVersion1Widget() : const HomeSettingsVersion2Widget(),
          ],
        ),
      ),
    );
  }
}
