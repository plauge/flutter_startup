import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/storage_constants.dart';
import 'storage_provider.dart';

part 'app_settings_provider.g.dart';

@riverpod
class AppSettings extends _$AppSettings {
  @override
  FutureOr<void> build() async {}

  Future<void> saveThemeMode(String mode) async {
    await ref
        .read(storageProvider.notifier)
        .saveString(StorageConstants.themeMode, mode);
  }

  Future<String?> getThemeMode() async {
    return ref
        .read(storageProvider.notifier)
        .getString(StorageConstants.themeMode);
  }
}
