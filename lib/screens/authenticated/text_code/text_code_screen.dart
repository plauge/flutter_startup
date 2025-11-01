import '../../../exports.dart';
import '../../../widgets/text_code/custom_text_code_search_widget.dart';

class TextCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  TextCodeScreen({super.key}) : super(pin_code_protected: false);

  static Future<TextCodeScreen> create() async {
    final screen = TextCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackScreenView(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('text_code_screen_viewed', {
      'screen': 'text_code',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Track screen view
    _trackScreenView(ref);
    return const _TextCodeScreenContent();
  }
}

class _TextCodeScreenContent extends StatefulWidget {
  const _TextCodeScreenContent();

  @override
  _TextCodeScreenContentState createState() => _TextCodeScreenContentState();
}

class _TextCodeScreenContentState extends State<_TextCodeScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AuthenticatedAppBar(
            title: I18nService().t('screen_text_code.title', fallback: 'Email & Text Messages'),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: CustomTextCodeSearchWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Created on 2024-12-19 at 14:00
