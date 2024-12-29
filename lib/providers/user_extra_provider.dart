import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/supabase_service.dart';
import '../models/user_extra.dart';
import '../providers/supabase_service_provider.dart';

part 'generated/user_extra_provider.g.dart';

@riverpod
class UserExtraNotifier extends AsyncNotifier<UserExtra?> {
  @override
  Future<UserExtra?> build() async {
    final supabaseService = ref.watch(supabaseServiceProvider);
    try {
      final userExtra = await supabaseService.getUserExtra();
      return userExtra;
    } catch (error) {
      print('Failed to fetch user extra: $error');
      return null;
    }
  }

  Future<void> updateUserExtra(UserExtra userExtra) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      state = const AsyncValue.loading();
      await supabaseService.updateUserExtra(userExtra);
      state = AsyncValue.data(userExtra);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}
