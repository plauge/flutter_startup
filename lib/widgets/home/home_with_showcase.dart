import '../../exports.dart';
import '../../widgets/home/home_showcase_widget.dart';
import '../../widgets/app_bars/authenticated_app_bar.dart';
import '../../widgets/home/home_content_version_3_widget.dart';
import '../../widgets/home/home_settings_version_3_widget.dart';
import '../../providers/home_version_provider.dart';

class HomeWithShowcase extends ConsumerStatefulWidget {
  const HomeWithShowcase({super.key});

  @override
  ConsumerState<HomeWithShowcase> createState() => _HomeWithShowcaseState();
}

class _HomeWithShowcaseState extends ConsumerState<HomeWithShowcase> {
  static final log = scopedLogger(LogCategory.gui);

  // GlobalKeys for showcase targets
  late final GlobalKey _settingsKey = GlobalKey();
  late final GlobalKey _helpKey = GlobalKey();
  late final GlobalKey _inputFieldKey = GlobalKey();
  late final GlobalKey _insertButtonKey = GlobalKey();
  late final GlobalKey _addContactButtonKey = GlobalKey();
  bool _showcaseStarted = false;

  @override
  void initState() {
    super.initState();
  }

  void _checkAndStartShowcase() {
    if (_showcaseStarted) {
      return;
    }

    final showcaseCompletedAsync = ref.read(showcaseCompletedProvider);
    showcaseCompletedAsync.when(
      data: (completed) {
        if (!completed && mounted && !_showcaseStarted) {
          _showcaseStarted = true;
          log('[home_with_showcase.dart][_checkAndStartShowcase] Starting showcase - completed: $completed');
          // Wait a bit for widgets to be fully built
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && _showcaseStarted) {
              try {
                log('[home_with_showcase.dart][_checkAndStartShowcase] Attempting to start showcase with keys: settings=${_settingsKey.currentContext != null}, help=${_helpKey.currentContext != null}, input=${_inputFieldKey.currentContext != null}, addContact=${_addContactButtonKey.currentContext != null}');
                startHomeShowcase(context, [
                  _settingsKey,
                  _helpKey,
                  _inputFieldKey,
                  _addContactButtonKey,
                ]);
                log('[home_with_showcase.dart][_checkAndStartShowcase] Showcase started successfully');
              } catch (e, stackTrace) {
                log('[home_with_showcase.dart][_checkAndStartShowcase] Error starting showcase: $e');
                log('[home_with_showcase.dart][_checkAndStartShowcase] Stack trace: $stackTrace');
                _showcaseStarted = false;
              }
            } else {
              log('[home_with_showcase.dart][_checkAndStartShowcase] Not mounted or showcase already started, skipping');
            }
          });
        } else {
          log('[home_with_showcase.dart][_checkAndStartShowcase] Showcase already completed or started: completed=$completed, started=$_showcaseStarted');
        }
      },
      loading: () {
        log('[home_with_showcase.dart][_checkAndStartShowcase] Showcase provider still loading');
      },
      error: (error, stack) {
        log('[home_with_showcase.dart][_checkAndStartShowcase] Error reading showcase completed: $error');
      },
    );
  }

  void _onShowcaseComplete() {
    log('[home_with_showcase.dart][_onShowcaseComplete] Showcase completed');
    ref.read(showcaseCompletedProvider.notifier).setCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    final homeVersionAsync = ref.watch(homeVersionProvider);
    final showcaseCompletedAsync = ref.watch(showcaseCompletedProvider);

    // Listen to showcase completed changes and reset _showcaseStarted when showcase is re-enabled
    showcaseCompletedAsync.when(
      data: (completed) {
        // If showcase is re-enabled (completed = false) and we've already started it, reset the flag
        if (!completed && _showcaseStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              log('[home_with_showcase.dart][build] Showcase re-enabled, resetting _showcaseStarted flag');
              _showcaseStarted = false;
            }
          });
        }
        // Check and start showcase when provider is ready
        if (!_showcaseStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_showcaseStarted && mounted) {
              _checkAndStartShowcase();
            }
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    return Scaffold(
      appBar: AuthenticatedAppBar(
        showSettings: true,
        showHelp: true,
        settingsKey: _settingsKey,
        helpKey: _helpKey,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: HomeContentVersion3Widget(
                    inputFieldKey: _inputFieldKey,
                    insertButtonKey: _insertButtonKey,
                    showcaseKey: _inputFieldKey,
                    isLastShowcase: false,
                  ),
                ),
                HomeSettingsVersion3Widget(
                  addContactButtonKey: _addContactButtonKey,
                  isLastShowcase: true,
                  onShowcaseComplete: _onShowcaseComplete,
                ),
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
                  variables: {'error': error.toString()},
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

// Created on 2025-12-14 at 05:15:00
