import '../exports.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  Future<String?> login(String email, String password) async {
    try {
      return await _ref.read(authProvider.notifier).login(email, password);
    } on AuthException catch (e) {
      throw AuthServiceException(message: e.message);
    }
  }

  Future<String?> createUser(String email, String password) async {
    try {
      return await _ref.read(authProvider.notifier).createUser(email, password);
    } on AuthException catch (e) {
      throw AuthServiceException(message: e.message);
    }
  }

  Future<void> logout() async {
    await _ref.read(authProvider.notifier).signOut();
  }

  bool get isAuthenticated => _ref.read(authProvider) != null;

  AppUser? get currentUser => _ref.read(authProvider);
}

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException({required this.message});

  @override
  String toString() => message;
}
