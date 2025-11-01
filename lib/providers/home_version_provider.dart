import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/constants/storage_constants.dart';
import '../exports.dart';

part 'generated/home_version_provider.g.dart';

@riverpod
class HomeVersion extends _$HomeVersion {
  static final log = scopedLogger(LogCategory.provider);

  @override
  Future<int> build() async {
    final storage = ref.read(storageProvider.notifier);
    final version = await storage.getInt(StorageConstants.homeVersion);
    // Default to version 1 if not set
    return version ?? 1;
  }

  Future<void> setVersion(int version) async {
    log('Setting home version to: $version');
    final storage = ref.read(storageProvider.notifier);
    await storage.saveInt(StorageConstants.homeVersion, version);
    state = AsyncValue.data(version);
  }
}

// Created on 2025-01-16 at 17:45

