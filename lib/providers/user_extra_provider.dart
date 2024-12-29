import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/supabase_service.dart';
import '../models/user_extra.dart';

part 'generated/user_extra_provider.g.dart';

@riverpod
class UserExtraNotifier extends _$UserExtraNotifier {
  @override
  Future<UserExtra?> build() async {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final (error, userExtra) = await supabaseService.fetchUserExtra();
    if (error != null) {
      throw Exception(error);
    }
    return userExtra;
  }
}
