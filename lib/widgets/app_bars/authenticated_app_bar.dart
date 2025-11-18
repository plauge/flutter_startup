import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthenticatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final String? backRoutePath;
  final bool showSettings;
  final bool showHelp;
  final Future<void> Function()? onBeforeBack;
  final Future<void> Function()? onBeforeHome;

  const AuthenticatedAppBar({
    super.key,
    this.title,
    this.backRoutePath,
    this.showSettings = false,
    this.showHelp = false,
    this.onBeforeBack,
    this.onBeforeHome,
  });

  @override
  State<AuthenticatedAppBar> createState() => _AuthenticatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _AuthenticatedAppBarState extends State<AuthenticatedAppBar> {
  /// Track back button interaction analytics
  void _trackBackButtonPressed(WidgetRef ref, String? destination) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_back_button_pressed', {
      'destination': destination ?? 'unknown',
      'screen_title': widget.title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track home navigation analytics (double tap)
  void _trackHomeNavigationPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_home_navigation_pressed', {
      'action': 'double_tap_back_button',
      'screen_title': widget.title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track settings button analytics
  void _trackSettingsButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_settings_button_pressed', {
      'screen_title': widget.title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track help button analytics
  void _trackHelpButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_help_button_pressed', {
      'screen_title': widget.title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: const Color(0xFFECECEC),
      color: const Color(0xFFE5E5E5),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) => AppBar(
            backgroundColor: const Color(0xFFE5E5E5),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true, // Sørger for at titel centreres på alle platforme
            // titleSpacing: Afstanden mellem title og leading/trailing widgets (20 pixels)
            // leadingWidth: Bredden af leading widget - 70px hvis der er en back-knap, ellers 20px
            titleSpacing: 0,
            leadingWidth: widget.backRoutePath != null ? (40 + AppDimensionsTheme.getParentContainerPadding(context)) : 0,
            leading: widget.backRoutePath != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: AppDimensionsTheme.getParentContainerPadding(context),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          _trackBackButtonPressed(ref, widget.backRoutePath);
                          ApiLoggingService().logGuiInteraction(
                            itemType: 'app_bar_back',
                            itemId: widget.backRoutePath ?? 'unknown',
                            metadata: {
                              'screen_title': widget.title ?? 'unknown',
                            },
                          );
                          if (context.mounted) {
                            if (widget.onBeforeBack != null) {
                              await widget.onBeforeBack!();
                            }
                            context.go(widget.backRoutePath!);
                          }
                        },
                        onDoubleTap: () async {
                          _trackHomeNavigationPressed(ref);
                          ApiLoggingService().logGuiInteraction(
                            itemType: 'app_bar_home',
                            itemId: 'double_tap_back',
                            metadata: {
                              'screen_title': widget.title ?? 'unknown',
                            },
                          );
                          if (context.mounted) {
                            if (widget.onBeforeHome != null) {
                              await widget.onBeforeHome!();
                            }
                            context.go(RoutePaths.home);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/images/back-arrow.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            title: widget.title != null
                ? Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            elevation: 0,
            actions: _buildActions(context, ref),
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, WidgetRef ref) {
    final List<Widget> actionWidgets = [];

    if (widget.showSettings) {
      actionWidgets.add(
        Padding(
          padding: EdgeInsets.only(
            right: widget.showHelp ? 0 : AppDimensionsTheme.getParentContainerPadding(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _trackSettingsButtonPressed(ref);
                ApiLoggingService().logGuiInteraction(
                  itemType: 'app_bar_settings',
                  itemId: 'settings_button',
                  metadata: {
                    'screen_title': widget.title ?? 'unknown',
                  },
                );
                if (context.mounted) {
                  context.go('/settings');
                }
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.settings,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.showHelp) {
      final helpActiveState = ref.watch(helpActiveProvider);
      final helpActive = helpActiveState.value ?? true; // Default til true hvis loading
      actionWidgets.add(
        Padding(
          padding: EdgeInsets.only(
            right: AppDimensionsTheme.getParentContainerPadding(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _trackHelpButtonPressed(ref);
                ApiLoggingService().logGuiInteraction(
                  itemType: 'app_bar_help',
                  itemId: 'help_button',
                  metadata: {
                    'screen_title': widget.title ?? 'unknown',
                    'help_active': helpActive,
                  },
                );
                ref.read(helpActiveProvider.notifier).toggle();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: helpActive ? 0.7 : 1.0,
                  child: SvgPicture.asset(
                    'assets/images/questionmark.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      helpActive ? const Color(0xFF808080) : const Color(0xFF000000),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }
}
