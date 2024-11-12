import '../exports.dart';

final authProvider = StateProvider<bool>((ref) {
  print('⭐ Creating authProvider with initial value: false');
  return true;
});

// Tilføj denne nye provider for at tracke ændringer
final authListenerProvider = Provider((ref) {
  ref.listen(authProvider, (previous, next) {
    print('🔐 Auth state changed from $previous to $next');
    print('Stack trace:');
    print(StackTrace.current);
  });
  return null;
});
