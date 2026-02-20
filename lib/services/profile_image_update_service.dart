import '../exports.dart';

class ProfileImageUpdateService {
  static final log = scopedLogger(LogCategory.service);

  static Future<void> updateProfileImage(String profileImageUrl) async {
    log('lib/services/profile_image_update_service.dart:updateProfileImage - Updating profile image');

    try {
      final supabase = Supabase.instance.client;
      await supabase.rpc('public_profile_update_image', params: {'input_profile_image': profileImageUrl});
      log('lib/services/profile_image_update_service.dart:updateProfileImage - Profile image updated successfully');
    } catch (e) {
      log('lib/services/profile_image_update_service.dart:updateProfileImage - Error: $e');
      throw Exception('Failed to update profile image: $e');
    }
  }
}

// Created: 2025-02-19
