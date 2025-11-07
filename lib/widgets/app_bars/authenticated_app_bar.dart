import '../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthenticatedAppBar extends StatelessWidget implements PreferredSizeWidget {
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

  /// Track back button interaction analytics
  void _trackBackButtonPressed(WidgetRef ref, String? destination) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_back_button_pressed', {
      'destination': destination ?? 'unknown',
      'screen_title': title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track home navigation analytics (double tap)
  void _trackHomeNavigationPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_home_navigation_pressed', {
      'action': 'double_tap_back_button',
      'screen_title': title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track settings button analytics
  void _trackSettingsButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_settings_button_pressed', {
      'screen_title': title ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track help button analytics
  void _trackHelpButtonPressed(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('app_bar_help_button_pressed', {
      'screen_title': title ?? 'unknown',
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
            leadingWidth: backRoutePath != null ? (40 + AppDimensionsTheme.getParentContainerPadding(context)) : 0,
            leading: backRoutePath != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: AppDimensionsTheme.getParentContainerPadding(context),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          _trackBackButtonPressed(ref, backRoutePath);
                          if (context.mounted) {
                            if (onBeforeBack != null) {
                              await onBeforeBack!();
                            }
                            context.go(backRoutePath!);
                          }
                        },
                        onDoubleTap: () async {
                          _trackHomeNavigationPressed(ref);
                          if (context.mounted) {
                            if (onBeforeHome != null) {
                              await onBeforeHome!();
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
            title: title != null
                ? Text(
                    title!,
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
            actions: showSettings
                ? [
                    Padding(
                      padding: EdgeInsets.only(
                        right: AppDimensionsTheme.getParentContainerPadding(context),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _trackSettingsButtonPressed(ref);
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
                  ]
                : showHelp
                    ? [
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
                                if (context.mounted) {
                                  context.go('/settings');
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/images/questionmark.svg',
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
                        ),
                      ]
                    : null,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
