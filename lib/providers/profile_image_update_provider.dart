import '../exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/profile_image_update_service.dart';

part 'generated/profile_image_update_provider.g.dart';

@riverpod
class ProfileImageUpdate extends _$ProfileImageUpdate {
  static final log = scopedLogger(LogCategory.provider);

  @override
  FutureOr<bool?> build() {
    log('lib/providers/profile_image_update_provider.dart:build - Initializing ProfileImageUpdate provider');
    return null;
  }

  Future<bool> updateProfileImage(String profileImageUrl) async {
    log('lib/providers/profile_image_update_provider.dart:updateProfileImage - Starting profile image update');
    try {
      await ProfileImageUpdateService.updateProfileImage(profileImageUrl);
      log('lib/providers/profile_image_update_provider.dart:updateProfileImage - Profile image updated successfully');
      return true;
    } catch (e) {
      log('lib/providers/profile_image_update_provider.dart:updateProfileImage - Error: $e');
      return false;
    }
  }
}

// Created: 2025-02-19
