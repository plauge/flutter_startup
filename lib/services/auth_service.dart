import '../exports.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  Future<String?> login(String email, String password) async {
    return _ref.read(authProvider.notifier).login(email, password);
  }

  Future<String?> createUser(String email, String password) async {
    return _ref.read(authProvider.notifier).createUser(email, password);
  }
}
