import '../exports.dart';
import '../services/profile_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  static final log = scopedLogger(LogCategory.gui);
  late final ProfileService _profileService;

  @override
  Future<Map<String, dynamic>> build() async {
    final supabaseService = SupabaseService();
    // Use the wrapped client which logs API calls
    _profileService = ProfileService(supabaseService.client);
    return _profileService.loadProfile();
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _profileService.loadProfile());
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String company,
    required String profileImage,
    String? ringtone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _profileService.updateProfile(
          firstName: firstName,
          lastName: lastName,
          company: company,
          profileImage: profileImage,
          ringtone: ringtone,
        ));
  }
}
