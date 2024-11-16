import '../../models/user.dart' as app_user;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticatedState {
  final app_user.User user;
  final String? token;

  const AuthenticatedState({
    required this.user,
    required this.token,
  });
}
