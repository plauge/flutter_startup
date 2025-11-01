import '../../../exports.dart';
import '../../../widgets/phone_code/phone_code_history_button.dart';
import '../../../widgets/phone_code/phone_code_content_widget.dart';

class PhoneCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  PhoneCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneCodeScreen> create() async {
    final screen = PhoneCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_code.title', fallback: 'Phone calls'),
        backRoutePath: RoutePaths.home,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: const PhoneCodeContentWidget(),
                ),
              ),
              // History knap - kun vis når der ikke er aktive opkald og telefonnumre findes
              const PhoneCodeHistoryButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2025-01-16 14:45:00
