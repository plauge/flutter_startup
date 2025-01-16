import '../exports.dart';
import '../services/profile_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  late final ProfileService _profileService;

  @override
  Future<Map<String, dynamic>> build() async {
    _profileService = ProfileService(ref.read(supabaseClientProvider));
    return _profileService.loadProfile();
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _profileService.loadProfile());
  }
}
