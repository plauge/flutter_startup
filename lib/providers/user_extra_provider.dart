import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/user_extra.dart';
import '../providers/supabase_service_provider.dart';
import '../providers/auth_provider.dart';
import '../exports.dart';

final userExtraNotifierProvider = AsyncNotifierProvider<UserExtraNotifier, UserExtra?>(() {
  return UserExtraNotifier();
});

class UserExtraNotifier extends AsyncNotifier<UserExtra?> {
  static final log = scopedLogger(LogCategory.provider);
  Timer? _cacheTimer;

  @override
  Future<UserExtra?> build() async {
    ref.watch(authProvider);

    // Cancel existing timer
    _cacheTimer?.cancel();

    // Set 10-minute cache expiry - auto-invalidate after 10 minutes
    _cacheTimer = Timer(const Duration(minutes: 10), () {
      try {
        log('Cache expired after 10 minutes - invalidating userExtraNotifierProvider');
        ref.invalidateSelf();
      } catch (e) {
        // Provider might be disposed, ignore error
        log('Provider already disposed during cache invalidation: $e');
      }
    });

    // Cleanup timer when provider is disposed
    ref.onDispose(() {
      _cacheTimer?.cancel();
    });

    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      final userExtra = await supabaseService.getUserExtra();
      log('Fresh user_extra data loaded from Supabase');
      return userExtra;
    } catch (error) {
      log('Failed to fetch user extra: $error');
      return null;
    }
  }

  // TODO: Can be deleted after 2026-03-01 if no errors are reported.
  // Commented out because updateUserExtra calls user_extra table directly without RPC.
  // Future<void> updateUserExtra(UserExtra userExtra) async {
  //   final supabaseService = ref.read(supabaseServiceProvider);
  //   try {
  //     state = const AsyncValue.loading();
  //     await supabaseService.updateUserExtra(userExtra);
  //     state = AsyncValue.data(userExtra);
  //   } catch (error) {
  //     state = AsyncValue.error(error, StackTrace.current);
  //   }
  // }

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

  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String company,
    required String encryptedFirstName,
    required String encryptedLastName,
    required String encryptedCompany,
  }) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      //state = const AsyncValue.loading();
      final response = await supabaseService.completeOnboarding(
        firstName: firstName,
        lastName: lastName,
        company: company,
        encryptedFirstName: encryptedFirstName,
        encryptedLastName: encryptedLastName,
        encryptedCompany: encryptedCompany,
      );

      final List<dynamic> responseList = response as List<dynamic>;
      if (responseList.isEmpty) {
        throw Exception('Empty response from server');
      }

      final Map<String, dynamic> firstRow = responseList[0] as Map<String, dynamic>;
      final Map<String, dynamic> data = firstRow['data'] as Map<String, dynamic>;

      if (data['success'] == true) {
        final updatedUserExtra = await supabaseService.getUserExtra();
        state = AsyncValue.data(updatedUserExtra);
      } else {
        state = AsyncValue.error(data['message'] ?? 'Unknown error', StackTrace.current);
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<bool> setOnboardingPincode(String pincode) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      state = const AsyncValue.loading();
      final success = await supabaseService.setOnboardingPincode(pincode);
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

  Future<bool> updateEncryptedMasterkeyCheckValue(String checkValue) async {
    final supabaseService = ref.read(supabaseServiceProvider);
    try {
      state = const AsyncValue.loading();
      final success = await supabaseService.updateEncryptedMasterkeyCheckValue(checkValue);

      if (success) {
        // Refresh user extra data after successful update
        final updatedUserExtra = await supabaseService.getUserExtra();
        state = AsyncValue.data(updatedUserExtra);
      } else {
        // Keep previous state but mark as error
        state = AsyncValue.error('Failed to update masterkey check value', StackTrace.current);
      }

      return success;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}
