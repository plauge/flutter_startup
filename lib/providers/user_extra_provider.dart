import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/user_extra.dart';
import '../providers/supabase_service_provider.dart';

final userExtraNotifierProvider =
    AsyncNotifierProvider<UserExtraNotifier, UserExtra?>(() {
  return UserExtraNotifier();
});

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

  Future<bool> updateTermsConfirmed() async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      state = const AsyncValue.loading();
      final success = await supabaseService.updateTermsConfirmed();
      if (success) {
        // Refresh user extra data after successful update
        final updatedUserExtra = await supabaseService.getUserExtra();
        state = AsyncValue.data(updatedUserExtra);
      }
      return success;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<void> completeOnboarding(
      String firstName, String lastName, String company) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      state = const AsyncValue.loading();
      final response = await supabaseService.completeOnboarding(
          firstName, lastName, company);
      if (response['success'] == true) {
        // Refresh user extra data after successful onboarding
        final updatedUserExtra = await supabaseService.getUserExtra();
        state = AsyncValue.data(updatedUserExtra);
      } else {
        state = AsyncValue.error(response['message'], StackTrace.current);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}
