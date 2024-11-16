import '../../models/app_user.dart';

class AuthenticatedState {
  final AppUser user;
  final String? token;

  const AuthenticatedState({
    required this.user,
    required this.token,
  });
}
