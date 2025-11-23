import '../exports.dart';
import '../services/logged_supabase_client.dart';

/// Provider that returns a LoggedSupabaseClient wrapper around SupabaseClient
/// This ensures all RPC calls are logged for debugging and test generation
final supabaseClientProvider = Provider<LoggedSupabaseClient>((ref) {
  // Return LoggedSupabaseClient to ensure all API calls are logged
  return LoggedSupabaseClient(Supabase.instance.client);
});
