import '../../exports.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/config/env_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// TODO(temporary-network-guard): remove when moving to full gateway
class NoConnectionScreen extends UnauthenticatedScreen {
  NoConnectionScreen({super.key});

  static final log = scopedLogger(LogCategory.gui);

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityStreamProvider, (prev, next) {
      final results = next.valueOrNull ?? [];
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        _tryReconnect(context, ref);
      }
    });
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
            Gap(AppDimensionsTheme.getMedium(context)),
            Center(
              child: CustomText(
                text: I18nService().t('screen_app.brand', fallback: 'ID-Truster'),
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            Gap(AppDimensionsTheme.getMedium(context)),
            Gap(AppDimensionsTheme.getMedium(context)),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  //Center(
                  CustomText(
                    key: const Key('no_connection_message_text'),
                    text: I18nService().t(
                      'screen_no_connection.description',
                      fallback: 'We are currently unable to connect to the database.',
                    ),
                    type: CustomTextType.cardHead,
                    alignment: CustomTextAlignment.center,
                  ),
                  //),
                  const SizedBox(height: 10),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    key: const Key('action_context_button'),
                    onPressed: () => _tryReconnect(context, ref),
                    text: I18nService().t('screen_no_connection.try_again', fallback: 'Try again now'),
                    buttonType: CustomButtonType.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tryReconnect(BuildContext context, WidgetRef ref) async {
    try {
      final host = Uri.parse(EnvConfig.supabaseUrl).host;
      final socket = await Socket.connect(host, 443, timeout: const Duration(seconds: 5));
      socket.destroy();
      ref.read(networkOfflineProvider.notifier).state = false;
      final target = ref.read(lastLocationProvider) ?? RoutePaths.home;
      ref.read(lastLocationProvider.notifier).state = null;
      if (context.mounted) context.go(target);
    } catch (_) {
      log('[no_connection_screen.dart][_tryReconnect] Still offline');
    }
  }
}

// Created: 2025-10-31 10:05
