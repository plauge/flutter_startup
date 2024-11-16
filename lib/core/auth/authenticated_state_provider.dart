import '../../exports.dart';
import 'authenticated_state.dart';

final authenticatedStateProvider = Provider<AuthenticatedState>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) {
    throw UnauthorizedException('Ingen bruger er logget ind');
  }

  final token = Supabase.instance.client.auth.currentSession?.accessToken;

  return AuthenticatedState(
    user: user,
    token: token,
  );
});

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}
