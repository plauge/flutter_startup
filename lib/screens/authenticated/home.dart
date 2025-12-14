import 'package:supabase_flutter/supabase_flutter.dart';
import '../../exports.dart';
import '../../widgets/home/home_with_showcase.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key}) : super(pin_code_protected: false);

  static final log = scopedLogger(LogCategory.gui);

  /// Sæt til true for at vise showcase test-info i bunden af skærmen
  static const bool _showTestInfo = false;

  // Static create method - den eneste måde at instantiere siden
  static Future<HomePage> create() async {
    final page = HomePage();
    return AuthenticatedScreen.create(page);
  }

  /// Henter bruger-specifik storage-nøgle (samme som i provideren)
  String _getStorageKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return StorageConstants.showcaseCompleted;
    }
    return '${StorageConstants.showcaseCompleted}_$userId';
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.log(LogCategory.security, 'HomePage buildAuthenticatedWidget');

    if (!_showTestInfo) {
      return const HomeWithShowcase();
    }

    // TEST MODE: Viser showcase storage/provider værdier i bunden af skærmen
    final storageKey = _getStorageKey();
    return Stack(
      children: [
        const HomeWithShowcase(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FutureBuilder<bool?>(
            future: ref.read(storageProvider.notifier).getBool(storageKey),
            builder: (context, snapshot) {
              final storageValue = snapshot.data;
              final providerAsync = ref.watch(showcaseCompletedProvider);
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.yellow.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'TEST - Showcase Values (key: $storageKey):',
                      type: CustomTextType.info,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    CustomText(
                      text: 'Storage value: ${storageValue?.toString() ?? "null (new user)"}',
                      type: CustomTextType.bread,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    providerAsync.when(
                      data: (value) => CustomText(
                        text: 'Provider value: $value',
                        type: CustomTextType.bread,
                      ),
                      loading: () => const CustomText(
                        text: 'Provider value: loading...',
                        type: CustomTextType.bread,
                      ),
                      error: (error, stack) => CustomText(
                        text: 'Provider value: error: $error',
                        type: CustomTextType.bread,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
